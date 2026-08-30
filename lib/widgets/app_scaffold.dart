import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/sound_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String? topBarTitle;
  final VoidCallback? onBack;
  final bool showLibraryBtn;
  final Gradient? backgroundGradient;
  final Color? backgroundColor;
  final bool scrollable;

  const AppScaffold({
    super.key,
    required this.body,
    this.topBarTitle,
    this.onBack,
    this.showLibraryBtn = true,
    this.backgroundGradient,
    this.backgroundColor,
    this.scrollable = true,
  });

  static const Gradient libraryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFF4EB),
      Color(0xFFD4E8F2),
      Color(0xFFA5CEE4),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isHome = appState.currentScreen == AppScreen.home;
    final isLibrary = appState.currentScreen == AppScreen.library;

    final effectiveGradient = backgroundGradient ??
        (isLibrary ? libraryGradient : AppColors.warmBackground);

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.cream,
      body: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          gradient: effectiveGradient,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SafeArea(
              child: Column(
                children: [
                  // Top bar
                  if (!isHome) _buildTopBar(context, appState),

                  // Main Content
                  Expanded(
                    child: scrollable
                        ? SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            child: body,
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            child: body,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, AppState appState) {
    final bool canGoBack = onBack != null || appState.history.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Clean Back Chevron matching HTML .back-btn
          if (canGoBack)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  SoundService.playTap();
                  if (onBack != null) {
                    onBack!();
                  } else {
                    appState.goBack();
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: AppColors.coral,
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 36),

          // Center: Title cleanly centered on top bar
          Expanded(
            child: Text(
              topBarTitle ?? 'Greyfriars Kirkyard',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),

          // Right: Exact Library Icon from HTML with count badge + subtle pulse animation
          if (showLibraryBtn && appState.currentScreen != AppScreen.library)
            Builder(
              builder: (ctx) {
                final isQuizActive = appState.currentScreen == AppScreen.quizRunner;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (isQuizActive) {
                        SoundService.playLocked();
                        ScaffoldMessenger.of(ctx).clearSnackBars();
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.lock_rounded,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Library is locked during the quiz!',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: const Color(0xFF333333),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      } else {
                        SoundService.playTap();
                        appState.navigateTo(AppScreen.library);
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isQuizActive
                            ? const Color(0xFFE8E8E8)
                            : AppColors.cream.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isQuizActive
                              ? const Color(0xFFB0B0B0)
                              : AppColors.coral.withValues(alpha: 0.4),
                        ),
                        boxShadow: isQuizActive
                            ? []
                            : [
                                BoxShadow(
                                  color: AppColors.coral.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (isQuizActive)
                            const Icon(
                              Icons.lock_rounded,
                              size: 16,
                              color: Color(0xFF7A7A7A),
                            )
                          else
                            Hero(
                              tag: 'top_library_icon',
                              child: Image.asset(
                                'assets/images/library_icon.png',
                                width: 24,
                                height: 20,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.collections_bookmark_rounded,
                                  size: 16,
                                  color: AppColors.coral,
                                ),
                              ),
                            ),
                          const SizedBox(width: 5),
                          Text(
                            isQuizActive
                                ? 'Locked'
                                : '${appState.unlockedCardsCount}/${appState.totalCardsCount}',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isQuizActive
                                  ? const Color(0xFF7A7A7A)
                                  : AppColors.dark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          else
            const SizedBox(width: 36),
        ],
      ),
    );
  }
}
