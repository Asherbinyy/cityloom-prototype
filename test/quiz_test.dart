import 'package:flutter_test/flutter_test.dart';
import 'package:cityloom_prototype/data/card_data.dart';
import 'package:cityloom_prototype/data/quiz_data.dart';
import 'package:cityloom_prototype/data/tour_data.dart';
import 'package:cityloom_prototype/models/quiz_model.dart';
import 'package:cityloom_prototype/state/app_state.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Tour & Card Data Tests', () {
    test('All 4 tour stops are defined with audio and scripts', () {
      expect(TourData.stops.length, 4);
      for (final stop in TourData.stops) {
        expect(stop.audioAsset.isNotEmpty, true);
        expect(stop.storyScript.isNotEmpty, true);
      }
    });

    test('All 10 character cards are defined in CardData', () {
      expect(CardData.cards.length, 10);
      expect(CardData.cards.containsKey('mary'), true);
      expect(CardData.cards.containsKey('bobby'), true);
      expect(CardData.cards.containsKey('charles'), true);
      expect(CardData.cards.containsKey('burke'), true);
      expect(CardData.cards.containsKey('hare'), true);
      expect(CardData.cards.containsKey('margaret'), true);
      expect(CardData.cards.containsKey('mckenzie'), true);
      expect(CardData.cards.containsKey('henrietta'), true);
      expect(CardData.cards.containsKey('poltergeist'), true);
      expect(CardData.cards.containsKey('knox'), true);
    });

    test('All 4 quiz difficulty tiers have correct question counts', () {
      expect(QuizData.levels[QuizDifficulty.explorer]?.questions.length, 5);
      expect(QuizData.levels[QuizDifficulty.apprentice]?.questions.length, 7);
      expect(QuizData.levels[QuizDifficulty.historian]?.questions.length, 10);
      expect(QuizData.levels[QuizDifficulty.scholar]?.questions.length, 14);
    });
  });

  group('AppState and Card Unlock Logic', () {
    test('Story unlocks Mary and Charles', () {
      final appState = AppState();
      appState.unlockStoryCard('mary');
      expect(appState.isCardUnlocked('mary'), true);

      appState.unlockStoryCard('charles');
      expect(appState.isCardUnlocked('charles'), true);
    });

    test('Bobby unlocks after finishing Explorer quiz', () {
      final appState = AppState();
      expect(appState.isCardUnlocked('bobby'), false);

      appState.finishQuiz(QuizDifficulty.explorer, 5);
      expect(appState.isCardUnlocked('bobby'), true);
    });

    test('Burke unlocks when apprentice_q6 is answered correctly', () {
      final appState = AppState();
      expect(appState.isCardUnlocked('burke'), false);

      appState.recordQuestionResult('apprentice_q6', true);
      expect(appState.isCardUnlocked('burke'), true);
    });

    test('Hare unlocks when historian_q2 is answered correctly', () {
      final appState = AppState();
      expect(appState.isCardUnlocked('hare'), false);

      appState.recordQuestionResult('historian_q2', true);
      expect(appState.isCardUnlocked('hare'), true);
    });

    test('Margaret unlocks when Burke, Hare, and scholar_q12 are correct', () {
      final appState = AppState();
      expect(appState.isCardUnlocked('margaret'), false);

      appState.recordQuestionResult('apprentice_q6', true); // unlocks Burke
      appState.recordQuestionResult('historian_q2', true); // unlocks Hare
      appState.recordQuestionResult('scholar_q12', true); // trigger

      expect(appState.isCardUnlocked('margaret'), true);
    });

    test('McKenzie unlocks when scholar_q7 is answered correctly', () {
      final appState = AppState();
      expect(appState.isCardUnlocked('mckenzie'), false);

      appState.recordQuestionResult('scholar_q7', true);
      expect(appState.isCardUnlocked('mckenzie'), true);
    });

    test('Poltergeist unlocks when all 4 levels have 100% score', () {
      final appState = AppState();
      expect(appState.isCardUnlocked('poltergeist'), false);

      appState.finishQuiz(QuizDifficulty.explorer, 5);
      appState.finishQuiz(QuizDifficulty.apprentice, 7);
      appState.finishQuiz(QuizDifficulty.historian, 10);
      expect(appState.isCardUnlocked('poltergeist'), false);

      appState.finishQuiz(QuizDifficulty.scholar, 14);
      expect(appState.isCardUnlocked('poltergeist'), true);
    });

    test('Explorer Q5 (Fill Gap Single) correctly evaluates church as index 1', () {
      final q5 = QuizData.levels[QuizDifficulty.explorer]!.questions
          .firstWhere((q) => q.id == 'explorer_q5');
      expect(q5.type, QuestionType.fillGapSingle);
      expect(q5.correct, 1);
      final correctStr = (q5.correct is int)
          ? q5.options[q5.correct as int]
          : q5.correct.toString();
      expect(correctStr, 'church');
      expect(q5.options.contains('church'), true);
    });

    test('Stop B and C coordinates are aligned to markers', () {
      final stopB = TourData.stops.firstWhere((s) => s.id == 'stop-b');
      final stopC = TourData.stops.firstWhere((s) => s.id == 'stop-c');

      expect(stopB.mapCoordinate.dx, closeTo(0.405, 0.01));
      expect(stopB.mapCoordinate.dy, closeTo(0.11, 0.01));

      expect(stopC.mapCoordinate.dx, closeTo(0.41, 0.01));
      expect(stopC.mapCoordinate.dy, closeTo(0.55, 0.01));
    });
  });
}
