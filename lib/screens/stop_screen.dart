import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../data/tour_data.dart';
import '../models/tour_model.dart';
import '../services/sound_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/audio_player_card.dart';
import '../widgets/card_reveal_dialog.dart';
import '../widgets/fly_to_library_animation.dart';
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
    final appState = context.watch<AppState>();
    final TourStop stop = TourData.stops[stopIndex];

    return AppScaffold(
      onBack: () {
        SoundService.playTap();
        appState.goBack();
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

          // Stop Photo
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
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 24),

          // "Next Stop" / "Finish Tour" Primary Button
          PrimaryButton(
            text: stopIndex < 3 ? 'Next Stop' : 'Finish Tour',
            onPressed: () => _handleNext(context, appState),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _handleNext(BuildContext context, AppState appState) {
    SoundService.playTap();
    final TourStop stop = TourData.stops[stopIndex];

    if (stop.unlockedCardId != null) {
      final bool isNewlyUnlocked =
          appState.unlockStoryCard(stop.unlockedCardId!);
      if (isNewlyUnlocked) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => CardRevealDialog(
            cardId: stop.unlockedCardId!,
            onDismiss: () {
              Navigator.of(context).pop();
              FlyToLibraryAnimation.fly(
                context,
                cardId: stop.unlockedCardId!,
                onComplete: () => _proceedToNextScreen(appState),
              );
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

    _proceedToNextScreen(appState);
  }

  void _proceedToNextScreen(AppState appState) {
    if (stopIndex == 1) {
      appState.navigateTo(AppScreen.mapB);
    } else if (stopIndex == 2) {
      appState.navigateTo(AppScreen.mapC);
    } else {
      appState.navigateTo(AppScreen.complete);
    }
  }
}
