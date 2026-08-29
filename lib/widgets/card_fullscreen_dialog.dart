import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/card_model.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';

class CardFullscreenDialog extends StatelessWidget {
  final CharacterCard card;

  const CardFullscreenDialog({
    super.key,
    required this.card,
  });

  void _downloadCard(BuildContext context) async {
    SoundService.playTap();
    try {
      final uri = Uri.parse(card.imageAsset);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback info
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Long-press or right-click the image to save "${card.name}"',
                style: GoogleFonts.dmSans(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              backgroundColor: const Color(0xFF281E14),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
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

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 420, maxHeight: 680),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            decoration: BoxDecoration(
              color: const Color(0xFFFEFAF6),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 28,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header: Name & Rarity
                Text(
                  card.name,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: rarityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: rarityColor, width: 1.2),
                  ),
                  child: Text(
                    card.rarity.displayName.toUpperCase(),
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: rarityColor,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Interactive Zoomable & Pannable Card
                Expanded(
                  child: GestureDetector(
                    onLongPress: () => _downloadCard(context),
                    child: InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 3.5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          card.imageAsset,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => Container(
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
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Historical Bio
                if (card.historicalBio != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.blush),
                    ),
                    child: Text(
                      card.historicalBio!,
                      style: GoogleFonts.dmSans(
                        fontSize: 12.5,
                        height: 1.4,
                        color: AppColors.dark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 12),

                // Download / Save Action Button
                TextButton.icon(
                  onPressed: () => _downloadCard(context),
                  icon: const Icon(Icons.download_rounded, size: 18, color: AppColors.coral),
                  label: Text(
                    'Save / Open High-Res Image',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.coral,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Close button in top-right
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
