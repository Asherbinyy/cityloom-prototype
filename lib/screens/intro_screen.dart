import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../data/tour_data.dart';
import '../state/app_state.dart';
import '../state/audio_controller.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/audio_player_card.dart';
import '../widgets/card_reveal_dialog.dart';
import '../widgets/primary_button.dart';
import '../widgets/progress_strip.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final audio = context.read<AudioController>();
    final introStop = TourData.stops.firstWhere((s) => s.id == 'intro');

    return AppScaffold(
      onBack: () {
        audio.stop();
        appState.navigateTo(AppScreen.home);
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

          // Audio Player with Speed & Script
          AudioPlayerCard(
            audioAsset: introStop.audioAsset,
            scriptText: introStop.storyScript,
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 24),

          // Next Button (Unlocks Mary Queen of Scots Card)
          PrimaryButton(
            text: 'Next',
            onPressed: () {
              audio.stop();
              appState.unlockStoryCard('mary');
              
              // Show Card Reveal Dialog if not unlocked before
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => CardRevealDialog(
                  cardId: 'mary',
                  onDismiss: () {
                    Navigator.of(context).pop();
                    appState.navigateTo(AppScreen.mapA);
                  },
                  onViewLibrary: () {
                    Navigator.of(context).pop();
                    appState.navigateTo(AppScreen.library);
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Skip Button (Same height/dimensions)
          PrimaryButton(
            text: 'Skip Intro',
            isSecondary: true,
            onPressed: () {
              audio.stop();
              appState.navigateTo(AppScreen.mapA);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
