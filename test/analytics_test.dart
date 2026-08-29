import 'package:flutter_test/flutter_test.dart';
import 'package:cityloom_prototype/services/analytics_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AnalyticsService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initializes with unique userId and sessionId', () async {
      final service = AnalyticsService.instance;
      await service.init();

      expect(service.userId.isNotEmpty, true);
      expect(service.userId.startsWith('cl_usr_'), true);
      expect(service.sessionId.isNotEmpty, true);
      expect(service.sessionId.startsWith('cl_ses_'), true);
      expect(service.totalSessions >= 1, true);
    });

    test('Tracks survey click count', () async {
      final service = AnalyticsService.instance;
      await service.init();

      final initialClicks = service.surveyClicks;
      service.logSurveyClick('test_screen');
      expect(service.surveyClicks, initialClicks + 1);
    });

    test('Tracks quiz completion and score history', () async {
      final service = AnalyticsService.instance;
      await service.init();

      final initialQuizzes = service.quizzesPlayed;
      service.logQuizCompleted(
        difficulty: 'explorer',
        score: 5,
        totalQuestions: 5,
        isPerfect: true,
      );

      expect(service.quizzesPlayed, initialQuizzes + 1);
      expect(service.scoresHistory.isNotEmpty, true);
      final lastRecord = service.scoresHistory.last;
      expect(lastRecord['difficulty'], 'explorer');
      expect(lastRecord['score'], 5);
      expect(lastRecord['accuracy_pct'], 100);
      expect(lastRecord['is_perfect'], true);
    });
  });
}
