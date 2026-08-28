import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class CongratulationsDialog extends StatelessWidget {
  final VoidCallback onViewLibrary;
  final VoidCallback onGiveFeedback;

  const CongratulationsDialog({
    super.key,
    required this.onViewLibrary,
    required this.onGiveFeedback,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.coral.withValues(alpha: 0.25),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.rarityRare.withValues(alpha: 0.3),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 54,
                color: AppColors.rarityRare,
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 18),
            const Text(
              'CONGRATULATIONS!',
              style: TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: AppColors.dark,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 10),
            const Text(
              "You've unlocked all 10 character cards! You are a true Master of Greyfriars Kirkyard.",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.muted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onViewLibrary();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.dark,
                      side: const BorderSide(color: AppColors.blush, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('View Cards'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onGiveFeedback();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.coral,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Give Feedback',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }
}
