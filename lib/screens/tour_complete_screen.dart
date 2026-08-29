import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/sound_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/primary_button.dart';
import '../widgets/progress_strip.dart';

class TourCompleteScreen extends StatelessWidget {
  const TourCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return AppScaffold(
      backgroundGradient: AppColors.warmBackground,
      onBack: () {
        SoundService.playTap();
        appState.goBack();
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // All Progress Bars Completed
          const ProgressStrip(currentStep: 4),
          const SizedBox(height: 24),

          // CityLoom Logo
          Image.asset(
            'assets/images/logo.png',
            width: 140,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
          const SizedBox(height: 16),

          // Header: WELL DONE! & Chapter Complete
          Text(
            'WELL DONE!',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppColors.coral,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Chapter Complete',
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Description Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              appState.unlockedCardsCount > 0
                  ? "You've explored Greyfriars Kirkyard and unlocked ${appState.unlockedCardsCount} character cards! Check your library to see which ones you're still missing."
                  : "You've explored Greyfriars Kirkyard! Check your library to see which cards you're still missing.",
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.muted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),

          // Animated Heartbeat/Pulse Library Book Icon
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                SoundService.playTap();
                appState.navigateTo(AppScreen.library);
              },
              borderRadius: BorderRadius.circular(40),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  'assets/images/library_icon.png',
                  width: 76,
                  height: 60,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.auto_stories_rounded,
                    size: 64,
                    color: AppColors.coral,
                  ),
                ),
              ),
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.10, 1.10),
                  duration: 1100.ms,
                  curve: Curves.easeInOut,
                ),
          ),
          const SizedBox(height: 12),

          Text(
            'Play the quiz to unlock more characters.',
            style: GoogleFonts.dmSans(
              fontSize: 12.5,
              color: AppColors.muted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // "Start Quiz" Button (Solid coral, no icons)
          PrimaryButton(
            text: 'Start Quiz',
            onPressed: () {
              SoundService.playTap();
              appState.navigateTo(AppScreen.quizSelect);
            },
          ),
          const SizedBox(height: 14),

          // "Skip to Feedback" Text Link (No icons)
          TextButton(
            onPressed: () {
              SoundService.playTap();
              appState.navigateTo(AppScreen.survey);
            },
            child: Text(
              'Skip to Feedback',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.muted,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
