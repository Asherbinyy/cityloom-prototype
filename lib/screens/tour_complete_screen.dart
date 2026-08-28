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
          // All Progress Dots Completed
          const ProgressStrip(currentStep: 4),
          const SizedBox(height: 16),

          // CityLoom Logo Icon
          Image.asset(
            'assets/images/logo.png',
            width: 140,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(
              Icons.church_rounded,
              size: 72,
              color: AppColors.coral,
            ),
          ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
          const SizedBox(height: 16),

          // Header
          Text(
            'TOUR COMPLETE',
            style: GoogleFonts.dmSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppColors.coral,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "You've Explored Greyfriars!",
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.dark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),

          // Dynamic Summary Message
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.blush),
              boxShadow: [
                BoxShadow(
                  color: AppColors.coral.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  appState.unlockedCardsCount > 0
                      ? "You've explored Greyfriars Kirkyard and unlocked ${appState.unlockedCardsCount} of ${appState.totalCardsCount} character cards! Check your library or play the quiz to collect the rest."
                      : "You've explored Greyfriars Kirkyard! Play the quiz to unlock character cards and collect them in your library.",
                  style: GoogleFonts.dmSans(
                    fontSize: 14.5,
                    height: 1.5,
                    color: AppColors.dark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 32),

          // "Take the Quiz" Primary Button
          PrimaryButton(
            text: 'Take the Quiz',
            icon: Icons.quiz_rounded,
            onPressed: () {
              SoundService.playTap();
              appState.navigateTo(AppScreen.quizSelect);
            },
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 12),

          // "View Library" Secondary Button
          PrimaryButton(
            text:
                'View Collection (${appState.unlockedCardsCount}/${appState.totalCardsCount})',
            icon: Icons.auto_stories_rounded,
            isSecondary: true,
            onPressed: () {
              SoundService.playTap();
              appState.navigateTo(AppScreen.library);
            },
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 12),

          // "Give Feedback" Text Button
          TextButton.icon(
            onPressed: () {
              SoundService.playTap();
              appState.navigateTo(AppScreen.survey);
            },
            icon: const Icon(Icons.rate_review_outlined,
                size: 16, color: AppColors.dark),
            label: Text(
              'Give Feedback',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.dark,
                decoration: TextDecoration.underline,
              ),
            ),
          ).animate().fadeIn(delay: 500.ms),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
