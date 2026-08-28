import 'package:flutter/material.dart';

class TourSubtitle {
  final double startSeconds;
  final double endSeconds;
  final String text;

  const TourSubtitle({
    required this.startSeconds,
    required this.endSeconds,
    required this.text,
  });
}

class TourStop {
  final String id;
  final String label; // "Welcome", "Stop A", etc.
  final String title; // "Introduction", "The Mortsafes"
  final String mapTitle; // "Head to the Mortsafes"
  final String mapDesc;
  final String stopDesc;
  final String audioAsset;
  final String photoAsset;
  final String? unlockedCardId;
  final Offset mapCoordinate; // Normalized (0.0 to 1.0)
  final List<Offset> walkPath; // Sequential coordinates from previous stop to this stop
  final int progressStep; // 0, 1, 2, 3
  final String storyScript;
  final List<TourSubtitle> subtitles;

  const TourStop({
    required this.id,
    required this.label,
    required this.title,
    required this.mapTitle,
    required this.mapDesc,
    required this.stopDesc,
    required this.audioAsset,
    required this.photoAsset,
    this.unlockedCardId,
    required this.mapCoordinate,
    this.walkPath = const [],
    required this.progressStep,
    required this.storyScript,
    this.subtitles = const [],
  });
}
