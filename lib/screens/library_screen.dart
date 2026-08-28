import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../data/card_data.dart';
import '../models/card_model.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/card_fullscreen_dialog.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return AppScaffold(
      backgroundGradient: AppColors.libraryBackground,
      showLibraryBtn: false,
      onBack: () => appState.goBackFromLibrary(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Library Icon
          Image.asset(
            'assets/images/library.png',
            width: 90,
            height: 90,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(
              Icons.auto_stories_rounded,
              size: 64,
              color: AppColors.coral,
            ),
          ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
          const SizedBox(height: 10),

          // Title
          const Text(
            'YOUR COLLECTION',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 4),

          // Counter
          Text(
            '${appState.unlockedCardsCount} of ${appState.totalCardsCount} Cards Unlocked',
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 20),

          // Sections: Common, Uncommon, Rare, Legendary
          ...CardData.libraryOrder.map((sec) {
            final sectionName = sec['section'] as String;
            final rarity = sec['rarity'] as CardRarity;
            final cardIds = sec['cardIds'] as List<String>;

            Color rarityColor;
            switch (rarity) {
              case CardRarity.common:
                rarityColor = AppColors.rarityCommon;
                break;
              case CardRarity.uncommon:
                rarityColor = AppColors.rarityUncommon;
                break;
              case CardRarity.rare:
                rarityColor = AppColors.rarityRare;
                break;
              case CardRarity.legendary:
                rarityColor = AppColors.rarityLegendary;
                break;
            }

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
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: rarityColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Card Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: cardIds.length,
                  itemBuilder: (context, idx) {
                    final cId = cardIds[idx];
                    final card = CardData.cards[cId]!;
                    final isUnlocked = appState.isCardUnlocked(cId);

                    return _buildCardTile(
                      context,
                      card,
                      isUnlocked,
                      rarityColor,
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCardTile(
    BuildContext context,
    CharacterCard card,
    bool isUnlocked,
    Color rarityColor,
  ) {
    if (isUnlocked) {
      return GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => CardFullscreenDialog(card: card),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: rarityColor.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              card.imageAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFF2A2A2A),
                child: Center(
                  child: Text(
                    card.name,
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

    // Locked Card
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              card.teaserMessage ?? 'Complete stops and quizzes to unlock this card.',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFF281E14),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E24),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: rarityColor.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              color: rarityColor.withValues(alpha: 0.7),
              size: 24,
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'LOCKED',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: rarityColor.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
