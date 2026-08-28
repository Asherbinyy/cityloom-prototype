import 'package:flutter/foundation.dart';
import 'dart:js_interop' as js;

@js.JS('window.cityLoomSound')
external _CityLoomSound? get _jsSound;

@js.JS()
@js.staticInterop
class _CityLoomSound {}

extension _CityLoomSoundExt on _CityLoomSound {
  external void playUnlock();
  external void playCongrats();
  external void playCorrect();
  external void playIncorrect();
  external void playFootstep();
  external void playTap();
  external void playLocked();
}

class SoundService {
  static void playUnlock() {
    try {
      _jsSound?.playUnlock();
    } catch (e) {
      debugPrint('Sound error: $e');
    }
  }

  static void playCongrats() {
    try {
      _jsSound?.playCongrats();
    } catch (e) {
      debugPrint('Sound error: $e');
    }
  }

  static void playCorrect() {
    try {
      _jsSound?.playCorrect();
    } catch (e) {
      debugPrint('Sound error: $e');
    }
  }

  static void playIncorrect() {
    try {
      _jsSound?.playIncorrect();
    } catch (e) {
      debugPrint('Sound error: $e');
    }
  }

  static void playFootstep() {
    try {
      _jsSound?.playFootstep();
    } catch (e) {
      debugPrint('Sound error: $e');
    }
  }

  static void playTap() {
    try {
      _jsSound?.playTap();
    } catch (e) {
      debugPrint('Sound error: $e');
    }
  }

  static void playLocked() {
    try {
      _jsSound?.playLocked();
    } catch (e) {
      debugPrint('Sound error: $e');
    }
  }
}
