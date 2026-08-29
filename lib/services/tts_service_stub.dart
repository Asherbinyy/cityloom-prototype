import 'package:flutter/foundation.dart';
import '../models/quiz_model.dart';

class TtsService {
  static bool _isPlaying = false;
  static bool get isPlaying => _isPlaying;

  static void speak(String text) {
    debugPrint('[TtsService] Speaking: $text');
    _isPlaying = true;
  }

  static void stop() {
    _isPlaying = false;
  }

  static void readQuestion(QuizQuestion q) {
    final buffer = StringBuffer();
    buffer.write('Question: ${q.question}. ');

    switch (q.type) {
      case QuestionType.single:
      case QuestionType.oddOneOut:
        buffer.write('This is a single choice question. The options are: ');
        for (var i = 0; i < q.options.length; i++) {
          buffer.write('Option ${i + 1}: ${q.options[i]}. ');
        }
        break;
      case QuestionType.multiSelect:
        buffer.write('This is a multiple choice question. Select all that apply. The options are: ');
        for (var i = 0; i < q.options.length; i++) {
          buffer.write('Option ${i + 1}: ${q.options[i]}. ');
        }
        break;
      case QuestionType.trueFalse:
        buffer.write('This is a true or false question. Option 1: True. Option 2: False. ');
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

    speak(buffer.toString());
  }
}
