import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/card_data.dart';
import '../models/card_model.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import 'card_fullscreen_dialog.dart';

class CardRevealDialog extends StatefulWidget {
  final String cardId;
  final VoidCallback onDismiss;
  final VoidCallback? onViewLibrary;

  const CardRevealDialog({
    super.key,
    required this.cardId,
    required this.onDismiss,
    this.onViewLibrary,
  });

  @override
  State<CardRevealDialog> createState() => _CardRevealDialogState();
}

class _CardRevealDialogState extends State<CardRevealDialog>
    with SingleTickerProviderStateMixin {
  bool _isRevealed = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _flipAnimation = Tween<double>(begin: math.pi / 2, end: 0.0).animate(
      CurvedAnimation(
        parent: _flipController,
        curve: const Cubic(0.34, 1.56, 0.64, 1.0),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _flipController,
        curve: const Cubic(0.34, 1.56, 0.64, 1.0),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _flipController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Initial sound on popup
    SoundService.playTap();
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _triggerReveal() {
    if (_isRevealed) return;
    setState(() {
      _isRevealed = true;
    });
    SoundService.playUnlock();
    _flipController.forward(from: 0.0);
  }

  Color _getRarityColor(CardRarity rarity) {
    switch (rarity) {
      case CardRarity.common:
        return AppColors.dark;
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
    final card = CardData.cards[widget.cardId];
    if (card == null) return const SizedBox.shrink();

    final rarityColor = _getRarityColor(card.rarity);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.1,
            colors: [
              AppColors.coral.withValues(alpha: 0.94),
              const Color(0xFFFDD2BE).withValues(alpha: 0.94),
              AppColors.blush.withValues(alpha: 0.94),
              AppColors.cream.withValues(alpha: 0.94),
            ],
            stops: const [0.0, 0.35, 0.70, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (!_isRevealed) ...[
                      // STEP 1: TEASER
                      Text(
                        card.teaserMessage ?? 'You unlocked a character!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'You unlocked a character!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.dark.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Rarity Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: rarityColor.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          card.rarity.name.toUpperCase(),
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.5,
                            color: rarityColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      // Silhouette Teaser Placeholder
                      GestureDetector(
                        onTap: _triggerReveal,
                        child: Container(
                          width: 220,
                          height: 310,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.6),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.coral.withValues(alpha: 0.25),
                                blurRadius: 28,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 54,
                                color: AppColors.coral.withValues(alpha: 0.8),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tap to Reveal',
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.dark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _triggerReveal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.4),
                          foregroundColor: AppColors.dark,
                          elevation: 0,
                          side: const BorderSide(
                              color: AppColors.dark, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 36, vertical: 14),
                        ),
                        child: Text(
                          'Tap to Reveal',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ] else ...[
                      // STEP 2: 3D REVEALED CARD
                      AnimatedBuilder(
                        animation: _flipController,
                        builder: (context, child) {
                          final transform = Matrix4.identity()
                            ..setEntry(3, 2, 0.0018) // perspective
                            ..rotateY(_flipAnimation.value)
                            ..scaleByDouble(_scaleAnimation.value, _scaleAnimation.value, 1.0, 1.0);

                          return Opacity(
                            opacity: _opacityAnimation.value.clamp(0.0, 1.0),
                            child: Transform(
                              transform: transform,
                              alignment: Alignment.center,
                              child: child,
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Text(
                              card.name,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: AppColors.dark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: rarityColor.withValues(alpha: 0.4),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                card.rarity.name.toUpperCase(),
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                  color: rarityColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            // Card Portrait
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => CardFullscreenDialog(card: card),
                                );
                              },
                              child: Container(
                                width: 250,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 28,
                                      offset: Offset(0, 10),
                                    ),
                                    BoxShadow(
                                      color: Color(0x33FDA692),
                                      blurRadius: 40,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    card.imageAsset,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Continue Button
                            ElevatedButton(
                              onPressed: widget.onDismiss,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withValues(alpha: 0.45),
                                foregroundColor: AppColors.dark,
                                elevation: 0,
                                side: const BorderSide(
                                    color: AppColors.dark, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 14),
                              ),
                              child: Text(
                                'Continue',
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
