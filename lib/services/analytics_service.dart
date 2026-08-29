import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Background Firebase Analytics and Telemetry Service for CityLoom.
/// All events and stats are logged asynchronously without blocking the UI.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  static AnalyticsService get instance => _instance;

  AnalyticsService._internal();

  static const String _prefUserId = 'cityloom_analytics_user_id';
  static const String _prefTotalSessions = 'cityloom_analytics_total_sessions';
  static const String _prefSurveyClicks = 'cityloom_analytics_survey_clicks';
  static const String _prefQuizzesPlayed = 'cityloom_analytics_quizzes_played';
  static const String _prefScoresHistory = 'cityloom_analytics_scores_history';
  static const String _prefPendingEvents = 'cityloom_analytics_pending_events';

  // Configurable Firebase project endpoint (or fallback collector)
  String _firebaseProjectId = 'cityloomprototype-4a07a';
  String _firebaseApiKey = 'AIzaSyAqyaaDltoRbBh8emSv5GRByz_i4rkVZxk';

  String? _userId;
  String? _sessionId;
  bool _initialized = false;
  int _sessionStartTime = 0;

  int _totalSessions = 0;
  int _surveyClicks = 0;
  int _quizzesPlayed = 0;
  final List<Map<String, dynamic>> _scoresHistory = [];

  String get userId => _userId ?? 'unknown_user';
  String get sessionId => _sessionId ?? 'unknown_session';
  int get totalSessions => _totalSessions;
  int get surveyClicks => _surveyClicks;
  int get quizzesPlayed => _quizzesPlayed;
  List<Map<String, dynamic>> get scoresHistory => List.unmodifiable(_scoresHistory);

  /// Configure Firebase credentials if available
  void configure({required String projectId, String apiKey = ''}) {
    _firebaseProjectId = projectId;
    _firebaseApiKey = apiKey;
  }

  /// Initialize the analytics engine asynchronously
  Future<void> init() async {
    if (_initialized) return;
    _sessionStartTime = DateTime.now().millisecondsSinceEpoch;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Retrieve or generate unique User ID
      _userId = prefs.getString(_prefUserId);
      if (_userId == null || _userId!.isEmpty) {
        _userId = 'cl_usr_${_generateRandomId()}';
        await prefs.setString(_prefUserId, _userId!);
      }

      // Generate unique Session ID for this run
      _sessionId = 'cl_ses_${_generateRandomId()}';

      // Load accumulated stats
      _totalSessions = (prefs.getInt(_prefTotalSessions) ?? 0) + 1;
      await prefs.setInt(_prefTotalSessions, _totalSessions);

      _surveyClicks = prefs.getInt(_prefSurveyClicks) ?? 0;
      _quizzesPlayed = prefs.getInt(_prefQuizzesPlayed) ?? 0;

      final rawScores = prefs.getString(_prefScoresHistory);
      if (rawScores != null && rawScores.isNotEmpty) {
        try {
          final list = jsonDecode(rawScores) as List;
          _scoresHistory.addAll(list.cast<Map<String, dynamic>>());
        } catch (_) {}
      }

      _initialized = true;

      // Log session start in background
      logEvent('session_start', {
        'session_number': _totalSessions,
        'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Flush any queued pending events
      _flushPendingEvents(prefs);
    } catch (e) {
      debugPrint('[AnalyticsService] Init failed (safe fallback active): $e');
      _userId ??= 'cl_usr_${_generateRandomId()}';
      _sessionId ??= 'cl_ses_${_generateRandomId()}';
      _initialized = true;
    }
  }

  /// Log any custom event with parameters (Non-blocking)
  void logEvent(String eventName, [Map<String, dynamic>? parameters]) {
    unawaited(_logEventInternal(eventName, parameters));
  }

  Future<void> _logEventInternal(
      String eventName, Map<String, dynamic>? parameters) async {
    final payload = <String, dynamic>{
      'event_name': eventName,
      'user_id': _userId ?? 'unknown',
      'session_id': _sessionId ?? 'unknown',
      'timestamp': DateTime.now().toIso8601String(),
      'time_since_session_start_ms':
          DateTime.now().millisecondsSinceEpoch - _sessionStartTime,
      if (parameters != null) ...parameters,
    };

    if (kDebugMode) {
      debugPrint('[Analytics] 📊 $eventName -> ${jsonEncode(payload)}');
    }

    // Dispatch in background to Firebase / Firestore endpoint
    _dispatchToFirebase(payload);
  }

  // ================= SPECIFIC CONVENIENCE TELEMETRY =================

  /// Log when user clicks any feedback / survey link
  void logSurveyClick(String sourceScreen, {Map<String, dynamic>? extra}) {
    _surveyClicks++;
    _persistSurveyClicks();

    logEvent('survey_clicked', {
      'source_screen': sourceScreen,
      'total_survey_clicks_by_user': _surveyClicks,
      'quizzes_completed_before_survey': _quizzesPlayed,
      if (extra != null) ...extra,
    });
  }

  /// Log when a quiz tier is completed
  void logQuizCompleted({
    required String difficulty,
    required int score,
    required int totalQuestions,
    required bool isPerfect,
    int? durationSeconds,
  }) {
    _quizzesPlayed++;
    _persistQuizzesPlayed();

    final record = {
      'difficulty': difficulty,
      'score': score,
      'total': totalQuestions,
      'accuracy_pct': (score / totalQuestions * 100).round(),
      'is_perfect': isPerfect,
      'attempt_number': _quizzesPlayed,
      'timestamp': DateTime.now().toIso8601String(),
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
    };

    _scoresHistory.add(record);
    _persistScoresHistory();

    logEvent('quiz_completed', record);
  }

  /// Log when a quiz question is answered
  void logQuestionAnswered({
    required String questionId,
    required String questionType,
    required dynamic optionSelected,
    required bool isCorrect,
    required int questionIndex,
  }) {
    logEvent('quiz_question_answered', {
      'question_id': questionId,
      'question_type': questionType,
      'option_selected': optionSelected.toString(),
      'is_correct': isCorrect,
      'question_index': questionIndex,
    });
  }

  /// Log when a quiz difficulty is selected
  void logQuizStarted(String difficulty) {
    logEvent('quiz_started', {'difficulty': difficulty});
  }

  /// Log when user skips a quiz
  void logQuizSkipped(String difficulty, {int? atQuestionIndex}) {
    logEvent('quiz_skipped', {
      'difficulty': difficulty,
      if (atQuestionIndex != null) 'at_question_index': atQuestionIndex,
    });
  }

  /// Log tour stop navigation and visits
  void logTourStopEntered(String stopId) {
    logEvent('tour_stop_entered', {'stop_id': stopId});
  }

  /// Log audio interaction
  void logAudioPlayback({
    required String stopId,
    required String action, // 'play', 'pause', 'complete', 'scrub'
    double? positionSeconds,
    double? totalDurationSeconds,
  }) {
    logEvent('tour_audio_interaction', {
      'stop_id': stopId,
      'action': action,
      if (positionSeconds != null) 'position_seconds': positionSeconds,
      if (totalDurationSeconds != null)
        'total_duration_seconds': totalDurationSeconds,
    });
  }

  /// Log character card unlock
  void logCardUnlocked({
    required String cardId,
    required String cardName,
    required String rarity,
    required String triggerReason,
  }) {
    logEvent('card_unlocked', {
      'card_id': cardId,
      'card_name': cardName,
      'rarity': rarity,
      'trigger_reason': triggerReason,
    });
  }

  /// Log character card modal interaction
  void logCardViewedFullscreen(String cardId, {bool downloaded = false}) {
    logEvent('card_viewed_fullscreen', {
      'card_id': cardId,
      'downloaded': downloaded,
    });
  }

  /// Log library screen opened
  void logLibraryOpened(int unlockedCount, int totalCount) {
    logEvent('library_opened', {
      'unlocked_cards_count': unlockedCount,
      'total_cards_count': totalCount,
      'completion_pct': (unlockedCount / totalCount * 100).round(),
    });
  }

  // ================= BACKGROUND DISPATCH & PERSISTENCE =================

  void _dispatchToFirebase(Map<String, dynamic> payload) {
    // Non-blocking fire-and-forget background HTTP dispatch
    Future.microtask(() async {
      try {
        if (_firebaseProjectId.isEmpty) return;

        // Firebase Firestore REST API structured document creation endpoint
        final url = Uri.parse(
          'https://firestore.googleapis.com/v1/projects/$_firebaseProjectId/databases/(default)/documents/cityloom_analytics_events'
          '${_firebaseApiKey.isNotEmpty ? '?key=$_firebaseApiKey' : ''}',
        );

        final firestoreFields = <String, dynamic>{};
        payload.forEach((k, v) {
          if (v is String) {
            firestoreFields[k] = {'stringValue': v};
          } else if (v is int) {
            firestoreFields[k] = {'integerValue': v.toString()};
          } else if (v is double) {
            firestoreFields[k] = {'doubleValue': v};
          } else if (v is bool) {
            firestoreFields[k] = {'booleanValue': v};
          } else {
            firestoreFields[k] = {'stringValue': v.toString()};
          }
        });

        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'fields': firestoreFields}),
            )
            .timeout(const Duration(seconds: 4));

        if (response.statusCode >= 400 && response.statusCode != 404) {
          // If offline or temporary network issue, queue event locally
          _queuePendingEvent(payload);
        }
      } catch (_) {
        // Silently queue event locally for offline sync
        _queuePendingEvent(payload);
      }
    });
  }

  void _queuePendingEvent(Map<String, dynamic> event) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getStringList(_prefPendingEvents) ?? [];
      if (current.length < 100) {
        current.add(jsonEncode(event));
        await prefs.setStringList(_prefPendingEvents, current);
      }
    } catch (_) {}
  }

  void _flushPendingEvents(SharedPreferences prefs) async {
    try {
      final pending = prefs.getStringList(_prefPendingEvents);
      if (pending == null || pending.isEmpty) return;
      await prefs.remove(_prefPendingEvents);

      for (final raw in pending) {
        try {
          final data = jsonDecode(raw) as Map<String, dynamic>;
          _dispatchToFirebase(data);
        } catch (_) {}
      }
    } catch (_) {}
  }

  void _persistSurveyClicks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefSurveyClicks, _surveyClicks);
    } catch (_) {}
  }

  void _persistQuizzesPlayed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefQuizzesPlayed, _quizzesPlayed);
    } catch (_) {}
  }

  void _persistScoresHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefScoresHistory, jsonEncode(_scoresHistory));
    } catch (_) {}
  }

  String _generateRandomId() {
    final rand = Random();
    final bytes = List<int>.generate(8, (_) => rand.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
