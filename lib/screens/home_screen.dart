import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/credits_dialog.dart';
import '../widgets/primary_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.warmBackground,
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // CityLoom Logo
                    Image.asset(
                      'assets/images/logo.png',
                      width: 220,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Text(
                        'CityLoom',
                        style: TextStyle(
                          fontFamily: 'Playfair Display',
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dark,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(begin: const Offset(0.9, 0.9)),

                    const SizedBox(height: 12),

                    // Tour Subtitle
                    Text(
                      'Greyfriars Kirkyard',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.dark,
                            letterSpacing: 0.5,
                          ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 8),

                    // Disclaimer text
                    const Text(
                      '(This is a prototype and not the final product.)',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        color: AppColors.muted,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: 44),

                    // Start Exploring Button
                    PrimaryButton(
                      text: 'Start Exploring',
                      onPressed: () {
                        appState.navigateTo(AppScreen.intro);
                      },
                    ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.95, 0.95)),

                    const Spacer(),

                    // Footer Credits Button
                    TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const CreditsDialog(),
                        );
                      },
                      icon: const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.muted),
                      label: const Text(
                        'Credits & About',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          color: AppColors.muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
