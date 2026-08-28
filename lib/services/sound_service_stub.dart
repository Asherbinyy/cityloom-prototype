import 'package:flutter/services.dart';

class SoundService {
  static void playUnlock() {
    HapticFeedback.mediumImpact();
  }

  static void playCongrats() {
    HapticFeedback.heavyImpact();
  }

  static void playCorrect() {
    HapticFeedback.lightImpact();
  }

  static void playIncorrect() {
    HapticFeedback.heavyImpact();
  }

  static void playFootstep() {}

  static void playTap() {
    HapticFeedback.selectionClick();
  }

  static void playLocked() {
    HapticFeedback.vibrate();
  }
}
