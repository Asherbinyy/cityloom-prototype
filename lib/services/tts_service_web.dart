import 'dart:js_interop' as js;
import 'package:flutter/foundation.dart';
import '../models/quiz_model.dart';

@js.JS('window.cityLoomTTS')
external _CityLoomTTS? get _jsTTS;

@js.JS()
@js.staticInterop
class _CityLoomTTS {}

extension _CityLoomTTSExt on _CityLoomTTS {
  external void speak(String text);
  external void stop();
  external bool get speaking;
}

class TtsService {
  static bool _isPlaying = false;
  static bool get isPlaying => _isPlaying;

  static void speak(String text) {
    try {
      _isPlaying = true;
      _jsTTS?.speak(text);
    } catch (e) {
      debugPrint('[TtsService] Speak error: $e');
    }
  }

  static void stop() {
    try {
      _isPlaying = false;
      _jsTTS?.stop();
    } catch (e) {
      debugPrint('[TtsService] Stop error: $e');
    }
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
