import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../data/tour_data.dart';
import '../services/analytics_service.dart';
import '../services/sound_service.dart';
import '../state/app_state.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/audio_player_card.dart';
import '../widgets/card_reveal_dialog.dart';
import '../widgets/fly_to_library_animation.dart';
import '../widgets/primary_button.dart';
import '../widgets/progress_strip.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final introStop = TourData.stops.firstWhere((s) => s.id == 'intro');

    return AppScaffold(
      onBack: () {
        SoundService.playTap();
        appState.goBack();
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress Dots
          const ProgressStrip(currentStep: 0),
          const SizedBox(height: 12),

          // Header
          Text(
            introStop.label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 4),
          Text(
            introStop.title,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            introStop.stopDesc,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),

          // Audio Player with Speed & Spotify-style Synced Lyrics
          AudioPlayerCard(
            audioAsset: introStop.audioAsset,
            storyScript: introStop.storyScript,
            subtitles: introStop.subtitles,
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 24),

          // "Next" Primary Button (triggers Mary Queen of Scots unlock)
          PrimaryButton(
            text: 'Next',
            onPressed: () => _handleNext(context, appState),
          ),
          const SizedBox(height: 12),

          // "Skip intro" Secondary Button
          PrimaryButton(
            text: 'Skip intro',
            isSecondary: true,
            onPressed: () {
              SoundService.playTap();
              AnalyticsService.instance.logEvent('tour_intro_skipped');
              appState.navigateTo(AppScreen.mapA);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _handleNext(BuildContext context, AppState appState) {
    SoundService.playTap();
    AnalyticsService.instance.logEvent('tour_intro_completed');
    final bool isNewlyUnlocked = appState.unlockStoryCard('mary');

    if (isNewlyUnlocked) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => CardRevealDialog(
          cardId: 'mary',
          onDismiss: () {
            Navigator.of(context).pop();
            FlyToLibraryAnimation.fly(
              context,
              cardId: 'mary',
              onComplete: () => appState.navigateTo(AppScreen.mapA),
            );
          },
          onViewLibrary: () {
            Navigator.of(context).pop();
            appState.navigateTo(AppScreen.library);
          },
        ),
      );
    } else {
      appState.navigateTo(AppScreen.mapA);
    }
  }
}
