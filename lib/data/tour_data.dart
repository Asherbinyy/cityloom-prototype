import 'package:flutter/material.dart';
import '../models/tour_model.dart';
import 'scripts_data.dart';

class TourData {
  // Initial entrance coordinate — bottom entrance gate path on new map
  static const Offset entranceCoordinate = Offset(0.50, 0.95);

  static const List<TourStop> stops = [
    TourStop(
      id: 'intro',
      label: 'Welcome',
      title: 'Introduction',
      mapTitle: 'Welcome to Greyfriars',
      mapDesc:
          'Listen to a brief introduction about your journey through Greyfriars Kirkyard before heading to your first stop.',
      stopDesc:
          'Listen to a brief introduction about your journey through Greyfriars Kirkyard before heading to your first stop.',
      audioAsset: 'assets/audio/intro.mp3',
      photoAsset: 'assets/images/screen-intro_photo.jpg',
      unlockedCardId: 'mary',
      mapCoordinate: entranceCoordinate,
      walkPath: [
        Offset(0.50, 0.95),
      ],
      progressStep: 0,
      storyScript: ScriptsData.introNarration,
      subtitles: ScriptsData.introSubtitles,
    ),
    TourStop(
      id: 'stop-a',
      label: 'Stop A',
      title: 'The Mortsafes',
      mapTitle: 'Head to the Mortsafes',
      mapDesc:
          'Use the map below to find your way to Stop A. Look for the iron cages near the south side of the Kirk.',
      stopDesc:
          'You should see these iron cages in front of you. Press play to hear the story behind them.',
      audioAsset: 'assets/audio/mortsafes.mp3',
      photoAsset: 'assets/images/mortsafes.jpg',
      unlockedCardId: null,
      mapCoordinate: Offset(0.49, 0.58),
      walkPath: [
        Offset(0.50, 0.95),
        Offset(0.50, 0.85),
        Offset(0.50, 0.72),
        Offset(0.50, 0.64),
        Offset(0.49, 0.58),
      ],
      progressStep: 1,
      storyScript: ScriptsData.mortsafesNarration,
      subtitles: ScriptsData.mortsafesSubtitles,
    ),
    TourStop(
      id: 'stop-b',
      label: 'Stop B',
      title: "Covenanters' Prison",
      mapTitle: "Head to the Covenanters' Prison",
      mapDesc:
          "Walk towards the northern section of the graveyard to find the gated entrance to the Covenanters' Prison.",
      stopDesc:
          'Stand near the iron gates of the prison. Listen to the tragic story of what took place here in 1679.',
      audioAsset: 'assets/audio/covenanters.mp3',
      photoAsset: 'assets/images/prison.jpg',
      unlockedCardId: 'charles',
      mapCoordinate: Offset(0.35, 0.10),
      walkPath: [
        Offset(0.49, 0.58),
        Offset(0.45, 0.45),
        Offset(0.40, 0.30),
        Offset(0.36, 0.18),
        Offset(0.35, 0.10),
      ],
      progressStep: 2,
      storyScript: ScriptsData.covenantersNarration,
      subtitles: ScriptsData.covenantersSubtitles,
    ),
    TourStop(
      id: 'stop-c',
      label: 'Stop C',
      title: 'Mackenzie Mausoleum',
      mapTitle: 'Head to the Black Mausoleum',
      mapDesc:
          'Follow the path to the domed mausoleum of Sir George "Bloody" Mackenzie.',
      stopDesc:
          'You are standing before the Black Mausoleum. Listen to the history and dark legends surrounding this tomb.',
      audioAsset: 'assets/audio/black_mausoleum.mp3',
      photoAsset: 'assets/images/black_mausoleum.jpg',
      unlockedCardId: null,
      mapCoordinate: Offset(0.35, 0.55),
      walkPath: [
        Offset(0.35, 0.10),
        Offset(0.35, 0.22),
        Offset(0.35, 0.35),
        Offset(0.35, 0.45),
        Offset(0.35, 0.55),
      ],
      progressStep: 3,
      storyScript: ScriptsData.mackenzieNarration,
      subtitles: ScriptsData.mackenzieSubtitles,
    ),
  ];
}
