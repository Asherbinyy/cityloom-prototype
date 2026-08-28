import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isHome = appState.currentScreen == AppScreen.home;

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.cream,
      body: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          gradient: backgroundGradient ??
              (isHome ? AppColors.warmBackground : null),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          if (onBack != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: AppColors.dark,
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 40, height: 40),

          // Optional Title
          if (topBarTitle != null)
            Text(
              topBarTitle!,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.dark,
              ),
            )
          else
            const Spacer(),

          // Library button
          if (showLibraryBtn && appState.currentScreen != AppScreen.library)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => appState.navigateTo(AppScreen.library),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.coral.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.coral.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/library.png',
                        width: 22,
                        height: 22,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.auto_stories_rounded,
                          size: 20,
                          color: AppColors.coral,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${appState.unlockedCardsCount}/${appState.totalCardsCount}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 40, height: 40),
        ],
      ),
    );
  }
}
