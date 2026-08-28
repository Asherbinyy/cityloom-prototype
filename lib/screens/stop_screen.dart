import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../data/tour_data.dart';
import '../models/tour_model.dart';
import '../state/app_state.dart';
import '../state/audio_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/audio_player_card.dart';
import '../widgets/card_reveal_dialog.dart';
import '../widgets/primary_button.dart';
import '../widgets/progress_strip.dart';

class StopScreen extends StatelessWidget {
  final int stopIndex; // 1: Stop A, 2: Stop B, 3: Stop C

  const StopScreen({
    super.key,
    required this.stopIndex,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final audio = context.read<AudioController>();
    final TourStop stop = TourData.stops[stopIndex];

    return AppScaffold(
      onBack: () {
        audio.stop();
        if (stopIndex == 1) {
          appState.navigateTo(AppScreen.mapA);
        } else if (stopIndex == 2) {
          appState.navigateTo(AppScreen.mapB);
        } else {
          appState.navigateTo(AppScreen.mapC);
        }
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress Dots
          ProgressStrip(currentStep: stop.progressStep),
          const SizedBox(height: 12),

          // Header
          Text(
            stop.label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 4),
          Text(
            stop.title,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 16),

          // Stop Photo with soft shadow & rounded corners
          if (stop.photoAsset.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.coral.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: AspectRatio(
                  aspectRatio: 1.4,
                  child: Image.asset(
                    stop.photoAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.blush,
                      child: const Center(
                        child: Icon(Icons.photo_rounded,
                            size: 48, color: AppColors.coral),
                      ),
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms),

          // Stop Description
          Text(
            stop.stopDesc,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),

          // Audio Player with Speed & Spotify-style Synced Lyrics
          AudioPlayerCard(
            audioAsset: stop.audioAsset,
            scriptText: stop.storyScript,
            subtitles: stop.subtitles,
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 24),

          // Next Stop Action (Uniform button dimensions)
          PrimaryButton(
            text: stopIndex < 3 ? 'Next Stop' : 'Complete Tour',
            onPressed: () {
              audio.stop();

              if (stop.unlockedCardId != null) {
                final cardId = stop.unlockedCardId!;
                final isNew = appState.unlockStoryCard(cardId);

                if (isNew) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => CardRevealDialog(
                      cardId: cardId,
                      onDismiss: () {
                        Navigator.of(context).pop();
                        _advanceScreen(appState);
                      },
                      onViewLibrary: () {
                        Navigator.of(context).pop();
                        appState.navigateTo(AppScreen.library);
                      },
                    ),
                  );
                  return;
                }
              }

              _advanceScreen(appState);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _advanceScreen(AppState appState) {
    if (stopIndex == 1) {
      appState.navigateTo(AppScreen.mapB);
    } else if (stopIndex == 2) {
      appState.navigateTo(AppScreen.mapC);
    } else {
      appState.navigateTo(AppScreen.complete);
    }
  }
}
