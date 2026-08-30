import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/analytics_service.dart';
import '../services/sound_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/credits_dialog.dart';
import '../widgets/primary_button.dart';

class SurveyScreen extends StatelessWidget {
  static const String surveyUrl = 'https://forms.gle/2iMZ6P9CGV3iMUja7';

  const SurveyScreen({super.key});

  Future<void> _openSurvey() async {
    AnalyticsService.instance.logSurveyClick('feedback_screen');
    final uri = Uri.parse(surveyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showCreditsDialog(BuildContext context) {
    SoundService.playTap();
    showDialog(
      context: context,
      builder: (ctx) => const CreditsDialog(),
    );
  }

  void _showAiDisclaimerDialog(BuildContext context) {
    SoundService.playTap();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFFFEFAF6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Visual Direction & Design',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dark,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.muted),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const Divider(color: AppColors.blush, height: 16),
                const SizedBox(height: 6),
                Text(
                  'Why are the cards and map AI-generated for now?',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.coral,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "These illustrations are placeholders. They're here purely to show the direction we want CityLoom to take visually, not the final product.\n\n"
                  "• The map will be professionally designed early on, within our initial budget (as part of our Fiverr designer's scope).\n\n"
                  "• The cards will initially use a simpler, cleaner design — likely featuring real, copyright-free photographs of the actual characters rather than illustrations.\n\n"
                  "• Long-term, once budget allows, we want to develop a distinct visual identity and branding for CityLoom, with a unique illustration style for the cards. That's the vision the AI placeholders are hinting at.\n\n"
                  "We're fortunate to already have a strong lead for that future step: Roger Coronel-Hillary, one of our Spanish-speaking collaborators based in Edinburgh, is a professional designer and illustrator, and would be our natural first choice for this collaboration. Nothing has been finalized yet, including budget, since card design isn't a current priority, and it's still too early to know how many cards each package will need.",
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    height: 1.45,
                    color: AppColors.dark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
          const SizedBox(height: 12),

          // Logo
          Image.asset(
            'assets/images/logo.png',
            width: 140,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(
              Icons.feedback_rounded,
              size: 56,
              color: AppColors.coral,
            ),
          ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
          const SizedBox(height: 16),

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
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.dark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),

          // Body Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFEFAF6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.blush),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
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
                    fontSize: 14,
                    height: 1.45,
                    color: AppColors.dark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  '(It only takes 2 minutes and is completely anonymous.)',
                  style: GoogleFonts.dmSans(
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                    color: AppColors.muted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 20),

          // AI Illustration Disclaimer Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF4EDE4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.blush),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 18, color: AppColors.coral),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Illustrations are currently AI-generated placeholders.',
                    style: GoogleFonts.dmSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.dark,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _showAiDisclaimerDialog(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(50, 28),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Learn more',
                    style: GoogleFonts.dmSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.coral,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 250.ms),

          const SizedBox(height: 24),

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

          // "Credits" Secondary Button
          PrimaryButton(
            text: 'Credits',
            icon: Icons.people_outline_rounded,
            isSecondary: true,
            onPressed: () => _showCreditsDialog(context),
          ).animate().fadeIn(delay: 350.ms),

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
