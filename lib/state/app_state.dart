import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/card_data.dart';
import '../data/quiz_data.dart';
import '../models/quiz_model.dart';
import '../services/sound_service.dart';

enum AppScreen {
  home,
  intro,
  mapA,
  stopA,
  mapB,
  stopB,
  mapC,
  stopC,
  complete,
  quizSelect,
  quizRunner,
  quizResult,
  library,
  survey,
}

class AppState extends ChangeNotifier {
  AppScreen _currentScreen = AppScreen.home;
  AppScreen? _previousScreenForLibrary;
  AppScreen? _previousScreenForSurvey;

  final Set<String> _unlockedCardIds = {};
  final Map<String, int> _bestScores = {}; // 'explorer': 5, etc.
  final Map<String, bool> _questionResults = {}; // 'apprentice_q6': true, etc.
  
  // Pending card unlocks queue for newly unlocked cards
  final List<String> _cardUnlockQueue = [];
  String? _currentlyRevealingCardId;
  bool _congratsShown = false;

  // Selected Quiz
  QuizDifficulty _selectedDifficulty = QuizDifficulty.explorer;
  int _currentQuizScore = 0;

  // Getters
  AppScreen get currentScreen => _currentScreen;
  Set<String> get unlockedCardIds => _unlockedCardIds;
  Map<String, int> get bestScores => _bestScores;
  Map<String, bool> get questionResults => _questionResults;
  List<String> get cardUnlockQueue => _cardUnlockQueue;
  String? get currentlyRevealingCardId => _currentlyRevealingCardId;
  bool get congratsShown => _congratsShown;
  QuizDifficulty get selectedDifficulty => _selectedDifficulty;
  int get currentQuizScore => _currentQuizScore;
  int get totalCardsCount => CardData.cards.length;
  int get unlockedCardsCount => _unlockedCardIds.length;

  bool isCardUnlocked(String cardId) => _unlockedCardIds.contains(cardId);

  AppState() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cardsList = prefs.getStringList('unlocked_cards') ?? [];
      _unlockedCardIds.addAll(cardsList);

      final scoresStr = prefs.getString('best_scores');
      if (scoresStr != null) {
        final Map<String, dynamic> decoded = jsonDecode(scoresStr);
        decoded.forEach((key, value) {
          if (value is int) _bestScores[key] = value;
        });
      }

      final resultsStr = prefs.getString('question_results');
      if (resultsStr != null) {
        final Map<String, dynamic> decoded = jsonDecode(resultsStr);
        decoded.forEach((key, value) {
          if (value is bool) _questionResults[key] = value;
        });
      }

      _congratsShown = prefs.getBool('congrats_shown') ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading saved state: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('unlocked_cards', _unlockedCardIds.toList());
      await prefs.setString('best_scores', jsonEncode(_bestScores));
      await prefs.setString('question_results', jsonEncode(_questionResults));
      await prefs.setBool('congrats_shown', _congratsShown);
    } catch (e) {
      debugPrint('Error saving state: $e');
    }
  }

  void navigateTo(AppScreen screen) {
    if (screen == AppScreen.library && _currentScreen != AppScreen.library) {
      _previousScreenForLibrary = _currentScreen;
    }
    if (screen == AppScreen.survey && _currentScreen != AppScreen.survey) {
      _previousScreenForSurvey = _currentScreen;
    }
    _currentScreen = screen;
    notifyListeners();
  }

  void goBackFromLibrary() {
    if (_previousScreenForLibrary != null) {
      _currentScreen = _previousScreenForLibrary!;
      _previousScreenForLibrary = null;
    } else {
      _currentScreen = AppScreen.home;
    }
    notifyListeners();
  }

  void goBackFromSurvey() {
    if (_previousScreenForSurvey != null) {
      _currentScreen = _previousScreenForSurvey!;
      _previousScreenForSurvey = null;
    } else {
      _currentScreen = AppScreen.complete;
    }
    notifyListeners();
  }

  void selectQuizDifficulty(QuizDifficulty difficulty) {
    _selectedDifficulty = difficulty;
    _currentScreen = AppScreen.quizRunner;
    notifyListeners();
  }

  void recordQuestionResult(String questionId, bool isCorrect) {
    _questionResults[questionId] = isCorrect;
    _checkAndQueueUnlocks();
    _saveToPrefs();
  }

  void finishQuiz(QuizDifficulty difficulty, int score) {
    _currentQuizScore = score;
    final key = difficulty.id;
    final prevBest = _bestScores[key] ?? 0;
    if (score > prevBest) {
      _bestScores[key] = score;
    }
    _checkAndQueueUnlocks();
    _saveToPrefs();
    _currentScreen = AppScreen.quizResult;
    notifyListeners();
  }

  bool unlockStoryCard(String cardId) {
    if (!_unlockedCardIds.contains(cardId)) {
      _unlockedCardIds.add(cardId);
      _cardUnlockQueue.remove(cardId); // ensure unique
      _saveToPrefs();
      _checkAndQueueUnlocks();
      notifyListeners();
      return true; // Newly unlocked!
    }
    return false; // Already unlocked previously
  }

  List<String> _checkAndQueueUnlocks() {
    final List<String> newlyUnlocked = [];

    void tryUnlock(String cardId, bool condition) {
      if (condition && !_unlockedCardIds.contains(cardId)) {
        _unlockedCardIds.add(cardId);
        if (!_cardUnlockQueue.contains(cardId)) {
          _cardUnlockQueue.add(cardId);
          newlyUnlocked.add(cardId);
        }
      }
    }

    // Bobby: Complete any Explorer quiz
    tryUnlock('bobby', _bestScores.containsKey('explorer'));

    // Burke: Apprentice Q6 correct (person to fate match)
    tryUnlock('burke', _questionResults['apprentice_q6'] == true);

    // Hare: Historian Q2 correct (Burke and Hare Irish immigrants - TF)
    tryUnlock('hare', _questionResults['historian_q2'] == true);

    // Margaret: Burke AND Hare unlocked + Scholar Q12 correct
    tryUnlock(
      'margaret',
      _unlockedCardIds.contains('burke') &&
          _unlockedCardIds.contains('hare') &&
          _questionResults['scholar_q12'] == true,
    );

    // McKenzie: Scholar Q7 100% correct (select all that apply)
    tryUnlock('mckenzie', _questionResults['scholar_q7'] == true);

    // Henrietta: Charles I unlocked + Scholar Q4 correct
    tryUnlock(
      'henrietta',
      _unlockedCardIds.contains('charles') && _questionResults['scholar_q4'] == true,
    );

    // Knox: All Burke & Hare questions answered correctly
    final knoxQuestions = [
      'apprentice_q2',
      'apprentice_q3',
      'apprentice_q6',
      'historian_q2',
      'historian_q3',
      'scholar_q1',
      'scholar_q2',
    ];
    final allKnoxCorrect = knoxQuestions.every((q) => _questionResults[q] == true);
    tryUnlock('knox', allKnoxCorrect);

    // Poltergeist: 100% score on all four difficulty levels
    bool all100 = true;
    for (final diff in QuizDifficulty.values) {
      final total = QuizData.levels[diff]?.questions.length ?? 0;
      final best = _bestScores[diff.id];
      if (best == null || best < total) {
        all100 = false;
        break;
      }
    }
    tryUnlock('poltergeist', all100);

    return newlyUnlocked;
  }

  String? popNextCardToReveal() {
    if (_cardUnlockQueue.isNotEmpty) {
      final cardId = _cardUnlockQueue.removeAt(0);
      _currentlyRevealingCardId = cardId;
      return cardId;
    }
    _currentlyRevealingCardId = null;
    return null;
  }

  void dismissRevealedCard() {
    _currentlyRevealingCardId = null;
    notifyListeners();
  }

  void markCongratsShown() {
    _congratsShown = true;
    _saveToPrefs();
    SoundService.playCongrats();
    notifyListeners();
  }

  void resetProgress() {
    _unlockedCardIds.clear();
    _bestScores.clear();
    _questionResults.clear();
    _cardUnlockQueue.clear();
    _currentlyRevealingCardId = null;
    _congratsShown = false;
    _currentScreen = AppScreen.home;
    _saveToPrefs();
    notifyListeners();
  }
}
