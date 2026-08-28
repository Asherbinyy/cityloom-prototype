import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/card_data.dart';
import '../models/card_model.dart';
import '../theme/app_theme.dart';

class CardRevealDialog extends StatefulWidget {
  final String cardId;
  final VoidCallback onDismiss;
  final VoidCallback onViewLibrary;

  const CardRevealDialog({
    super.key,
    required this.cardId,
    required this.onDismiss,
    required this.onViewLibrary,
  });

  @override
  State<CardRevealDialog> createState() => _CardRevealDialogState();
}

class _CardRevealDialogState extends State<CardRevealDialog> {
  bool _isRevealed = false;

  @override
  Widget build(BuildContext context) {
    final card = CardData.cards[widget.cardId];
    if (card == null) {
      widget.onDismiss();
      return const SizedBox.shrink();
    }

    Color rarityColor;
    switch (card.rarity) {
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

    return Material(
      color: Colors.black.withValues(alpha: 0.88),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: _isRevealed
                ? _buildRevealedContent(card, rarityColor)
                : _buildTeaserContent(card, rarityColor),
          ),
        ),
      ),
    );
  }

  Widget _buildTeaserContent(CharacterCard card, Color rarityColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'NEW CHARACTER UNLOCKED!',
          style: TextStyle(
            fontFamily: 'Playfair Display',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
        const SizedBox(height: 12),

        // Rarity Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: rarityColor.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: rarityColor, width: 1.5),
          ),
          child: Text(
            '${card.rarity.displayName.toUpperCase()} CARD',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: rarityColor,
            ),
          ),
        ).animate().scale(delay: 200.ms, duration: 400.ms),
        const SizedBox(height: 24),

        // Locked Silhouette Box with glow
        Container(
          width: 200,
          height: 280,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E24),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: rarityColor.withValues(alpha: 0.6), width: 2),
            boxShadow: [
              BoxShadow(
                color: rarityColor.withValues(alpha: 0.3),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_rounded,
                size: 64,
                color: rarityColor.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 16),
              if (card.teaserMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    card.teaserMessage!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ).animate().scale(delay: 300.ms, duration: 500.ms),
        const SizedBox(height: 32),

        // Tap to Reveal Button
        ElevatedButton(
          onPressed: () {
            setState(() {
              _isRevealed = true;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.coral,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 8,
          ),
          child: const Text(
            'Tap to Reveal',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ).animate().fadeIn(delay: 500.ms).shimmer(duration: 1500.ms),
      ],
    );
  }

  Widget _buildRevealedContent(CharacterCard card, Color rarityColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          card.name,
          style: const TextStyle(
            fontFamily: 'Playfair Display',
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
        const SizedBox(height: 8),

        // Rarity Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: rarityColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            card.rarity.displayName.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.white,
            ),
          ),
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 20),

        // Revealed Card Image with 3D Flip & Glow
        Container(
          width: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: rarityColor.withValues(alpha: 0.5),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              card.imageAsset,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Container(
                height: 320,
                color: const Color(0xFF2A2A2A),
                child: Center(
                  child: Text(
                    card.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        )
            .animate()
            .scale(duration: 600.ms, curve: Curves.easeOutBack)
            .shimmer(delay: 600.ms, duration: 1200.ms),
        const SizedBox(height: 28),

        // Action Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: widget.onViewLibrary,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54, width: 1.5),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('View Library'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: widget.onDismiss,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.coral,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }
}
