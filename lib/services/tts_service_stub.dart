import 'package:flutter/foundation.dart';
import '../models/quiz_model.dart';

class TtsService {
  static bool _isPlaying = false;
  static bool get isPlaying => _isPlaying;

  static bool _isPaused = false;
  static bool get isPaused => _isPaused;

  static double _currentSpeed = 1.0;
  static double get currentSpeed => _currentSpeed;

  static void speak(String text, {double rate = 0.92}) {
    debugPrint('[TtsService] Speaking: $text (rate: $rate)');
    _isPlaying = true;
    _isPaused = false;
    _currentSpeed = rate;
  }

  static void pause() {
    _isPaused = true;
  }

  static void resume() {
    _isPaused = false;
  }

  static void restart() {
    _isPaused = false;
    _isPlaying = true;
  }

  static void setSpeed(double rate) {
    _currentSpeed = rate;
  }

  static void stop() {
    _isPlaying = false;
    _isPaused = false;
  }

  static bool startListening(Function(String text) onResult) {
    debugPrint('[TtsService] STT listening started');
    return false;
  }

  static void stopListening() {
    debugPrint('[TtsService] STT listening stopped');
  }

  static void readQuestion(QuizQuestion q, {double speed = 1.0}) {
    final buffer = StringBuffer();
    buffer.write('Question: ${q.question}. ');

    if (q.instruction != null && q.instruction!.isNotEmpty) {
      buffer.write('${q.instruction!}. ');
    }

    switch (q.type) {
      case QuestionType.single:
      case QuestionType.oddOneOut:
        buffer.write('Single choice. The options are: ');
        for (var i = 0; i < q.options.length; i++) {
          buffer.write('Option ${i + 1}: ${q.options[i]}. ');
        }
        break;
      case QuestionType.multiSelect:
        buffer.write('Multiple choice. The options are: ');
        for (var i = 0; i < q.options.length; i++) {
          buffer.write('Option ${i + 1}: ${q.options[i]}. ');
        }
        break;
      case QuestionType.trueFalse:
        buffer.write('True or false. Option 1: True. Option 2: False. ');
        break;
      case QuestionType.fillGapSingle:
        buffer.write('Fill in the blank. The options are: ');
        for (var i = 0; i < q.options.length; i++) {
          buffer.write('${q.options[i]}. ');
        }
        break;
      case QuestionType.match:
        buffer.write('Match each item on the left with the correct item on the right. ');
        break;
      case QuestionType.order:
        buffer.write('Put the events in order from first to last. ');
        break;
    }

    speak(buffer.toString(), rate: speed);
  }
}
