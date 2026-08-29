import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/card_data.dart';
import '../data/quiz_data.dart';
import '../models/card_model.dart';
import '../models/quiz_model.dart';
import '../services/analytics_service.dart';

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
  final List<AppScreen> _history = [];

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
  List<AppScreen> get history => _history;
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
  bool get hasPendingUnlocks => _cardUnlockQueue.isNotEmpty;

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
    if (_currentScreen != screen) {
      _history.add(_currentScreen);
      _currentScreen = screen;
      AnalyticsService.instance.logEvent('screen_view', {'screen_name': screen.name});
      notifyListeners();
    }
  }

  void goBack() {
    if (_history.isNotEmpty) {
      _currentScreen = _history.removeLast();
    } else {
      // Fallback hierarchy
      switch (_currentScreen) {
        case AppScreen.intro:
          _currentScreen = AppScreen.home;
          break;
        case AppScreen.mapA:
          _currentScreen = AppScreen.intro;
          break;
        case AppScreen.stopA:
          _currentScreen = AppScreen.mapA;
          break;
        case AppScreen.mapB:
          _currentScreen = AppScreen.stopA;
          break;
        case AppScreen.stopB:
          _currentScreen = AppScreen.mapB;
          break;
        case AppScreen.mapC:
          _currentScreen = AppScreen.stopB;
          break;
        case AppScreen.stopC:
          _currentScreen = AppScreen.mapC;
          break;
        case AppScreen.complete:
          _currentScreen = AppScreen.stopC;
          break;
        case AppScreen.quizSelect:
          _currentScreen = AppScreen.complete;
          break;
        case AppScreen.quizRunner:
          _currentScreen = AppScreen.quizSelect;
          break;
        case AppScreen.quizResult:
          _currentScreen = AppScreen.quizSelect;
          break;
        case AppScreen.library:
        case AppScreen.survey:
          _currentScreen = AppScreen.home;
          break;
        case AppScreen.home:
          break;
      }
    }
    notifyListeners();
  }

  void goBackFromLibrary() {
    goBack();
  }

  void goBackFromSurvey() {
    goBack();
  }

  void selectQuizDifficulty(QuizDifficulty difficulty) {
    _selectedDifficulty = difficulty;
    AnalyticsService.instance.logQuizStarted(difficulty.id);
    navigateTo(AppScreen.quizRunner);
  }

  void recordQuestionResult(String questionId, bool isCorrect) {
    _questionResults[questionId] = isCorrect;
    AnalyticsService.instance.logEvent('quiz_question_answered', {
      'question_id': questionId,
      'is_correct': isCorrect,
      'current_difficulty': _selectedDifficulty?.id ?? 'unknown',
    });
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
    final totalQ = QuizData.levels[difficulty]?.questions.length ?? 5;
    AnalyticsService.instance.logQuizCompleted(
      difficulty: difficulty.id,
      score: score,
      totalQuestions: totalQ,
      isPerfect: score == totalQ,
    );
    _checkAndQueueUnlocks();
    _saveToPrefs();
    navigateTo(AppScreen.quizResult);
  }

  bool unlockStoryCard(String cardId) {
    if (!_unlockedCardIds.contains(cardId)) {
      _unlockedCardIds.add(cardId);
      _cardUnlockQueue.remove(cardId); // ensure unique
      AnalyticsService.instance.logCardUnlocked(
        cardId: cardId,
        cardName: CardData.cards[cardId]?.name ?? cardId,
        rarity: CardData.cards[cardId]?.rarity.name ?? 'story',
        triggerReason: 'story_progress',
      );
      _saveToPrefs();
      _checkAndQueueUnlocks();
      notifyListeners();
      return true; // Newly unlocked!
    }
    return false; // Already unlocked previously
  }

  void _checkAndQueueUnlocks() {
    // 1. Mary: Unlocked after intro
    // (Handled via unlockStoryCard('mary'))

    // 2. Bobby: Complete any Explorer quiz
    if (!_unlockedCardIds.contains('bobby') && _bestScores.containsKey('explorer')) {
      _unlockCard('bobby');
    }

    // 3. Charles I: Unlocked after Covenanters' Prison stop or story
    // (Handled via unlockStoryCard('charles'))

    // 4. Burke: Apprentice Q6 answered correctly
    if (!_unlockedCardIds.contains('burke') &&
        (_questionResults['apprentice_q6'] == true || _questionResults['apprentice_q5'] == true)) {
      _unlockCard('burke');
    }

    // 5. Hare: Historian Q2 answered correctly
    if (!_unlockedCardIds.contains('hare') &&
        (_questionResults['historian_q2'] == true || _questionResults['historian_q3'] == true)) {
      _unlockCard('hare');
    }

    // 6. Margaret: Burke + Hare unlocked + Scholar Margaret question correct
    if (!_unlockedCardIds.contains('margaret') &&
        _unlockedCardIds.contains('burke') &&
        _unlockedCardIds.contains('hare') &&
        (_questionResults['scholar_q12'] == true || _questionResults['scholar_q13'] == true)) {
      _unlockCard('margaret');
    }

    // 7. McKenzie: Scholar McKenzie question answered correctly
    if (!_unlockedCardIds.contains('mckenzie') &&
        (_questionResults['scholar_q7'] == true || _questionResults['scholar_q8'] == true)) {
      _unlockCard('mckenzie');
    }

    // 8. Henrietta: Charles I unlocked + Scholar Henrietta question correct
    if (!_unlockedCardIds.contains('henrietta') &&
        _unlockedCardIds.contains('charles') &&
        (_questionResults['scholar_q4'] == true || _questionResults['scholar_q5'] == true)) {
      _unlockCard('henrietta');
    }

    // 9. Poltergeist: 100% score on all 4 levels
    if (!_unlockedCardIds.contains('poltergeist')) {
      final e = (_bestScores['explorer'] ?? 0) ==
          QuizData.levels[QuizDifficulty.explorer]!.questions.length;
      final a = (_bestScores['apprentice'] ?? 0) ==
          QuizData.levels[QuizDifficulty.apprentice]!.questions.length;
      final h = (_bestScores['historian'] ?? 0) ==
          QuizData.levels[QuizDifficulty.historian]!.questions.length;
      final s = (_bestScores['scholar'] ?? 0) ==
          QuizData.levels[QuizDifficulty.scholar]!.questions.length;
      if (e && a && h && s) {
        _unlockCard('poltergeist');
      }
    }

    // 10. Knox: All Burke & Hare related questions answered correctly
    if (!_unlockedCardIds.contains('knox')) {
      final qApp2 = _questionResults['apprentice_q2'] == true;
      final qApp3 = _questionResults['apprentice_q3'] == true;
      final qApp6 = _questionResults['apprentice_q6'] == true;
      final qHist2 = _questionResults['historian_q2'] == true;
      final qHist3 = _questionResults['historian_q3'] == true;
      final qSch1 = _questionResults['scholar_q1'] == true;
      final qSch2 = _questionResults['scholar_q2'] == true;
      if (qApp2 && qApp3 && qApp6 && qHist2 && qHist3 && qSch1 && qSch2) {
        _unlockCard('knox');
      }
    }
  }

  void _unlockCard(String cardId) {
    _unlockedCardIds.add(cardId);
    if (!_cardUnlockQueue.contains(cardId)) {
      _cardUnlockQueue.add(cardId);
    }
    AnalyticsService.instance.logCardUnlocked(
      cardId: cardId,
      cardName: CardData.cards[cardId]?.name ?? cardId,
      rarity: CardData.cards[cardId]?.rarity.name ?? 'quiz',
      triggerReason: 'quiz_achievement',
    );
  }

  String? popNextCardToReveal() {
    if (_cardUnlockQueue.isNotEmpty) {
      _currentlyRevealingCardId = _cardUnlockQueue.removeAt(0);
      _saveToPrefs();
      notifyListeners();
      return _currentlyRevealingCardId;
    }
    _currentlyRevealingCardId = null;
    return null;
  }

  void markCongratsShown() {
    _congratsShown = true;
    _saveToPrefs();
    notifyListeners();
  }

  void resetAllProgress() async {
    _unlockedCardIds.clear();
    _bestScores.clear();
    _questionResults.clear();
    _cardUnlockQueue.clear();
    _currentlyRevealingCardId = null;
    _congratsShown = false;
    _currentScreen = AppScreen.home;
    _history.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
