import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/card_data.dart';
import '../models/card_model.dart';
import '../services/sound_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_fullscreen_dialog.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  Color _getRarityColor(CardRarity rarity) {
    switch (rarity) {
      case CardRarity.common:
        return const Color(0xFF2A2A2A);
      case CardRarity.uncommon:
        return const Color(0xFF2563EB);
      case CardRarity.rare:
        return const Color(0xFF9333EA);
      case CardRarity.legendary:
        return const Color(0xFFD97706);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return AppScaffold(
      backgroundGradient: AppColors.warmBackground,
      showLibraryBtn: false,
      onBack: () {
        SoundService.playTap();
        appState.goBackFromLibrary();
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),

          // Library Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.coral.withValues(alpha: 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/library.png',
              width: 58,
              height: 58,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.auto_stories_rounded,
                size: 48,
                color: AppColors.coral,
              ),
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'YOUR COLLECTION',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
              color: AppColors.coral,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            '${appState.unlockedCardsCount} of ${appState.totalCardsCount} Cards Unlocked',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 24),

          // Sections: Common, Uncommon, Rare, Legendary
          ...CardData.libraryOrder.map((sec) {
            final sectionName = sec['section'] as String;
            final rarity = sec['rarity'] as CardRarity;
            final cardIds = sec['cardIds'] as List<String>;
            final rarityColor = _getRarityColor(rarity);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: rarityColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        sectionName.toUpperCase(),
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: rarityColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // 3-Column Card Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: cardIds.length,
                  itemBuilder: (context, idx) {
                    final cId = cardIds[idx];
                    final card = CardData.cards[cId]!;
                    final isUnlocked = appState.isCardUnlocked(cId);

                    return _LibraryCardTile(
                      card: card,
                      isUnlocked: isUnlocked,
                      rarityColor: rarityColor,
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            );
          }),
          const SizedBox(height: 12),
          Text(
            'Play the different quiz levels to unlock more cards.',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: AppColors.muted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _LibraryCardTile extends StatefulWidget {
  final CharacterCard card;
  final bool isUnlocked;
  final Color rarityColor;

  const _LibraryCardTile({
    required this.card,
    required this.isUnlocked,
    required this.rarityColor,
  });

  @override
  State<_LibraryCardTile> createState() => _LibraryCardTileState();
}

class _LibraryCardTileState extends State<_LibraryCardTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onTapLocked() {
    SoundService.playLocked();
    _shakeController.forward(from: 0.0);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.card.teaserMessage ??
              'Complete stops and quiz levels to unlock this card!',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF2A2A2A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isUnlocked) {
      return GestureDetector(
        onTap: () {
          SoundService.playTap();
          showDialog(
            context: context,
            builder: (_) => CardFullscreenDialog(card: widget.card),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.rarityColor.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              widget.card.imageAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFF2A2A2A),
                child: Center(
                  child: Text(
                    widget.card.name,
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Locked Card with Shaking Effect
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final offset = math.sin(_shakeController.value * math.pi * 4) * 6.0;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: _onTapLocked,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE2DBD3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                color: AppColors.dark.withValues(alpha: 0.6),
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                'LOCKED',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: AppColors.dark.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
