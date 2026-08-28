import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
    final appState = context.read<AppState>();

    return AppScaffold(
      backgroundGradient: AppColors.warmBackground,
      onBack: () => appState.goBackFromSurvey(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

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
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Help Shape CityLoom!',
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),

          // Body Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.blush),
              boxShadow: [
                BoxShadow(
                  color: AppColors.coral.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              children: [
                Text(
                  "We're currently developing CityLoom and would love your feedback to shape the future of immersive audio walking tours!",
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.5,
                    color: AppColors.dark,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  '(It only takes 2 minutes and is completely anonymous.)',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                    color: AppColors.muted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 32),

          // Open Survey Button
          PrimaryButton(
            text: 'Open Feedback Form',
            icon: Icons.open_in_new_rounded,
            onPressed: _openSurvey,
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 12),

          // Return Button
          PrimaryButton(
            text: 'Return to Tour',
            isSecondary: true,
            onPressed: () => appState.goBackFromSurvey(),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
