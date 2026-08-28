import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/sound_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/primary_button.dart';

class SurveyScreen extends StatelessWidget {
  static const String surveyUrl = 'https://forms.gle/2iMZ6P9CGV3iMUja7';

  const SurveyScreen({super.key});

  Future<void> _openSurvey() async {
    final uri = Uri.parse(surveyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return AppScaffold(
      topBarTitle: 'Feedback',
      onBack: () => appState.goBack(),
      backgroundGradient: AppColors.warmBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),

          // Logo
          Image.asset(
            'assets/images/logo.png',
            width: 160,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(
              Icons.feedback_rounded,
              size: 64,
              color: AppColors.coral,
            ),
          ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
          const SizedBox(height: 20),

          // Header
          Text(
            'FEEDBACK',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppColors.coral,
            ),
          ),
          const SizedBox(height: 6),

          Text(
            'Help Shape CityLoom!',
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.dark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),

          // Body Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.blush),
              boxShadow: [
                BoxShadow(
                  color: AppColors.coral.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  "We're currently developing CityLoom and would love your feedback to shape the future of immersive audio walking tours!",
                  style: GoogleFonts.dmSans(
                    fontSize: 14.5,
                    height: 1.5,
                    color: AppColors.dark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  '(It only takes 2 minutes and is completely anonymous.)',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: AppColors.muted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 32),

          // "Start Survey" Primary Button
          PrimaryButton(
            text: 'Start Survey',
            icon: Icons.open_in_new_rounded,
            onPressed: () {
              SoundService.playTap();
              _openSurvey();
            },
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 12),

          // "Back" Secondary Button
          PrimaryButton(
            text: 'Back',
            isSecondary: true,
            onPressed: () {
              SoundService.playTap();
              appState.goBack();
            },
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
