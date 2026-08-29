import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/card_data.dart';
import '../models/card_model.dart';
import '../services/sound_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
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
      topBarTitle: 'Card Library',
      onBack: () => appState.goBack(),
      showLibraryBtn: false,
      backgroundGradient: AppScaffold.libraryGradient,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),

          // Header
          Text(
            'COLLECTION',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppColors.coral,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          Text(
            'Historical Library',
            style: GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),

          Text(
            '${appState.unlockedCardsCount} / ${appState.totalCardsCount} cards',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppColors.muted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Sections: Common, Uncommon, Rare, Legendary
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

          // Grid of Cards (aspect ratio 2/3 like in HTML)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.67,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
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
                      child: Image.asset(
                        card.imageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: AppColors.cream,
                          child: Center(
                            child: Text(
                              card.name,
                              style: GoogleFonts.playfairDisplay(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.dark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  // Locked Card: Dark Overlay with ? and Name matching HTML
                  Positioned.fill(
                    child: Container(
                      color: const Color(0xFF281E14).withValues(alpha: 0.6),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '?',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            card.name,
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              card.rarity.name.toUpperCase(),
                              style: GoogleFonts.dmSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // On-Card Locked Toast (like HTML .toast-locked)
                if (showToast)
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF281E14).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Locked',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
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
