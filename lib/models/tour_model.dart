import 'package:flutter/material.dart';

class TourStop {
  final String id;
  final String label;
  final String title;
  final String mapTitle;
  final String mapDesc;
  final String stopDesc;
  final String audioAsset;
  final String? photoAsset;
  final String storyScript;
  final String? unlockedCardId;
  final Offset mapCoordinate; // Normalized coordinates (0.0 to 1.0) on the map
  final int progressStep; // 0: intro, 1: stopA, 2: stopB, 3: stopC, 4: complete

  const TourStop({
    required this.id,
    required this.label,
    required this.title,
    required this.mapTitle,
    required this.mapDesc,
    required this.stopDesc,
    required this.audioAsset,
    this.photoAsset,
    required this.storyScript,
    this.unlockedCardId,
    required this.mapCoordinate,
    required this.progressStep,
  });
}
