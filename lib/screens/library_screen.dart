import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/card_data.dart';
import '../models/card_model.dart';
import '../services/analytics_service.dart';
import '../services/sound_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_image.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_fullscreen_dialog.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final Map<String, bool> _shakingMap = {};
  final Map<String, bool> _toastMap = {};

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return AppScaffold(
      topBarTitle: '',
      onBack: () => appState.goBack(),
      showLibraryBtn: false,
      backgroundGradient: AppScaffold.libraryGradient,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header (matching HTML Screenshot 1)
          Center(
            child: Hero(
              tag: 'top_library_icon',
              child: Image.asset(
                'assets/images/library_icon.png',
                width: 58,
                height: 46,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.auto_stories_rounded,
                  size: 46,
                  color: AppColors.coral,
                ),
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.08, 1.08),
                duration: 1200.ms,
                curve: Curves.easeInOut,
              ),
          const SizedBox(height: 12),

          Text(
            'YOUR COLLECTION',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppColors.coral,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          Text(
            '${appState.unlockedCardsCount} / ${appState.totalCardsCount} cards',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppColors.muted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),

          // Rarity Sections: Common, Uncommon, Rare, Legendary
          _buildRaritySection(context, appState, CardRarity.common),
          _buildRaritySection(context, appState, CardRarity.uncommon),
          _buildRaritySection(context, appState, CardRarity.rare),
          _buildRaritySection(context, appState, CardRarity.legendary),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildRaritySection(
      BuildContext context, AppState appState, CardRarity rarity) {
    final cards =
        CardData.cards.values.where((c) => c.rarity == rarity).toList();
    if (cards.isEmpty) return const SizedBox.shrink();

    Color bgColor;
    Color textColor;
    Color borderColor;
    String labelText;

    switch (rarity) {
      case CardRarity.common:
        labelText = 'COMMON';
        bgColor = const Color(0xFFFDA692).withValues(alpha: 0.25);
        textColor = const Color(0xFFC06040);
        borderColor = const Color(0xFFC06040).withValues(alpha: 0.5);
        break;
      case CardRarity.uncommon:
        labelText = 'UNCOMMON';
        bgColor = const Color(0xFFFDA692).withValues(alpha: 0.2);
        textColor = const Color(0xFFB05A40);
        borderColor = const Color(0xFFB05A40).withValues(alpha: 0.5);
        break;
      case CardRarity.rare:
        labelText = 'RARE';
        bgColor = const Color(0xFFB43C32).withValues(alpha: 0.2);
        textColor = const Color(0xFF8A2020);
        borderColor = const Color(0xFF8A2020).withValues(alpha: 0.5);
        break;
      case CardRarity.legendary:
        labelText = 'LEGENDARY';
        bgColor = const Color(0xFF8C82C8).withValues(alpha: 0.2);
        textColor = const Color(0xFF5A4A9A);
        borderColor = const Color(0xFF5A4A9A).withValues(alpha: 0.5);
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Pill Label
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Text(
              labelText,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),

          // Grid of Cards (3 columns matching HTML Screenshot 1)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.67,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              final isUnlocked = appState.isCardUnlocked(card.id);
              final isShaking = _shakingMap[card.id] ?? false;
              final showToast = _toastMap[card.id] ?? false;

              return _buildCardItem(context, card, isUnlocked, isShaking, showToast);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(
      BuildContext context, CharacterCard card, bool isUnlocked, bool isShaking, bool showToast) {
    Widget cardContent = Container(
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.transparent : const Color(0xFFD8D0C4),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (isUnlocked) {
                SoundService.playTap();
                AnalyticsService.instance.logCardViewedFullscreen(card.id);
                showDialog(
                  context: context,
                  builder: (_) => CardFullscreenDialog(card: card),
                );
              } else {
                SoundService.playLocked();
                setState(() {
                  _shakingMap[card.id] = true;
                  _toastMap[card.id] = true;
                });
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) setState(() => _shakingMap[card.id] = false);
                });
                Future.delayed(const Duration(milliseconds: 1000), () {
                  if (mounted) setState(() => _toastMap[card.id] = false);
                });
              }
            },
            child: Stack(
              children: [
                // Unlocked Card: Full Image
                if (isUnlocked)
                  Positioned.fill(
                    child: Hero(
                      tag: 'card_${card.id}',
                      child: AppImage(
                        assetPath: card.imageAsset,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  // Locked Card: Ornate Card Back Artwork (matching HTML CARD_LOCKED_SRC)
                  const Positioned.fill(
                    child: AppImage(
                      assetPath: 'assets/images/card_locked.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),

                // On-Card Locked Toast (like HTML .toast-locked)
                if (showToast)
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF281E14).withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Locked',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFE8DCC6),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 150.ms)
                          .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 150.ms)
                          .then(delay: 600.ms)
                          .fadeOut(duration: 250.ms),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    if (isShaking) {
      return cardContent
          .animate(onComplete: (_) {})
          .shake(duration: 500.ms, hz: 6, curve: Curves.easeInOut);
    }

    return cardContent;
  }
}
