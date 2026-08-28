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
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: const Color(0xFF2563EB),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          Text(
            'Historical Library',
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.dark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),

          Text(
            '${appState.unlockedCardsCount} / ${appState.totalCardsCount} cards unlocked',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2563EB),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

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

    Color labelColor;
    String labelText;

    switch (rarity) {
      case CardRarity.common:
        labelText = 'Common';
        labelColor = const Color(0xFF2A2A2A);
        break;
      case CardRarity.uncommon:
        labelText = 'Uncommon';
        labelColor = const Color(0xFF2563EB);
        break;
      case CardRarity.rare:
        labelText = 'Rare';
        labelColor = const Color(0xFF9333EA);
        break;
      case CardRarity.legendary:
        labelText = 'Legendary';
        labelColor = const Color(0xFFD97706);
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: labelColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  labelText,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: labelColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Grid of Cards
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              final isUnlocked = appState.isCardUnlocked(card.id);
              final isShaking = _shakingMap[card.id] ?? false;

              return _buildCardItem(context, card, isUnlocked, isShaking);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(
      BuildContext context, CharacterCard card, bool isUnlocked, bool isShaking) {
    Widget cardWidget = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isUnlocked ? 0.15 : 0.06),
            blurRadius: isUnlocked ? 12 : 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
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
                setState(() => _shakingMap[card.id] = true);
                Future.delayed(const Duration(milliseconds: 600), () {
                  if (mounted) setState(() => _shakingMap[card.id] = false);
                });

                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '🔒 ${card.name}: ${card.hint}',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    backgroundColor: const Color(0xFF281E14).withValues(alpha: 0.92),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            child: isUnlocked
                ? Hero(
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
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2C241D), Color(0xFF1E1812)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.coral.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.coral.withValues(alpha: 0.4),
                            ),
                          ),
                          child: const Icon(
                            Icons.lock_rounded,
                            size: 26,
                            color: Color(0xFFD4AF37), // Antique gold lock
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          card.name,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFE5D5C5),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tap to see hint',
                          style: GoogleFonts.dmSans(
                            fontSize: 10.5,
                            fontStyle: FontStyle.italic,
                            color: const Color(0xFF9E8E7E),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );

    if (isShaking) {
      return cardWidget
          .animate(onComplete: (_) {})
          .shake(duration: 500.ms, hz: 6, curve: Curves.easeInOut);
    }

    return cardWidget;
  }
}
