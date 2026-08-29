import 'dart:js_interop' as js;
import 'package:flutter/foundation.dart';
import '../models/quiz_model.dart';

@js.JS('window.cityLoomTTS')
external _CityLoomTTS? get _jsTTS;

@js.JS()
@js.staticInterop
class _CityLoomTTS {}

extension _CityLoomTTSExt on _CityLoomTTS {
  external void speak(String text, [double? rate]);
  external void pause();
  external void resume();
  external void restart();
  external void setSpeed(double rate);
  external void stop();
  external bool get speaking;
  external bool get paused;
}

@js.JS('window.cityLoomSTT')
external _CityLoomSTT? get _jsSTT;

@js.JS()
@js.staticInterop
class _CityLoomSTT {}

extension _CityLoomSTTExt on _CityLoomSTT {
  external bool startListening(js.JSFunction onResult);
  external void stopListening();
  external bool get listening;
}

class TtsService {
  static bool _isPlaying = false;
  static bool get isPlaying => _isPlaying;

  static bool _isPaused = false;
  static bool get isPaused => _isPaused;

  static double _currentSpeed = 1.0;
  static double get currentSpeed => _currentSpeed;

  static void speak(String text, {double rate = 0.92}) {
    try {
      _isPlaying = true;
      _isPaused = false;
      _currentSpeed = rate;
      _jsTTS?.speak(text, rate);
    } catch (e) {
      debugPrint('[TtsService] Speak error: $e');
    }
  }

  static void pause() {
    try {
      _isPaused = true;
      _jsTTS?.pause();
    } catch (e) {
      debugPrint('[TtsService] Pause error: $e');
    }
  }

  static void resume() {
    try {
      _isPaused = false;
      _jsTTS?.resume();
    } catch (e) {
      debugPrint('[TtsService] Resume error: $e');
    }
  }

  static void restart() {
    try {
      _isPaused = false;
      _isPlaying = true;
      _jsTTS?.restart();
    } catch (e) {
      debugPrint('[TtsService] Restart error: $e');
    }
  }

  static void setSpeed(double rate) {
    try {
      _currentSpeed = rate;
      _jsTTS?.setSpeed(rate);
    } catch (e) {
      debugPrint('[TtsService] SetSpeed error: $e');
    }
  }

  static void stop() {
    try {
      _isPlaying = false;
      _isPaused = false;
      _jsTTS?.stop();
    } catch (e) {
      debugPrint('[TtsService] Stop error: $e');
    }
  }

  static bool startListening(Function(String text) onResult) {
    try {
      final jsCallback = (js.JSString result) {
        onResult(result.toDart);
      }.toJS;
      return _jsSTT?.startListening(jsCallback) ?? false;
    } catch (e) {
      debugPrint('[TtsService] STT start error: $e');
      return false;
    }
  }

  static void stopListening() {
    try {
      _jsSTT?.stopListening();
    } catch (e) {
      debugPrint('[TtsService] STT stop error: $e');
    }
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
