import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CreditsDialog extends StatelessWidget {
  const CreditsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Credits',
              style: TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.dark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            _buildCreditRow('Research', 'Malek Ben Khaled'),
            _buildCreditRow('Script Writer', 'Aoibhín Gallagher'),
            _buildCreditRow('Voice Actors', 'Gregor Campbell, Kieran Lee-Hamilton, Robbie Hail, Malek Ben Khaled'),
            _buildCreditRow('Sound Production', 'Malek Ben Khaled'),
            _buildCreditRow('Quiz Concept', 'Malek Ben Khaled'),
            _buildCreditRow('Prototype Development', 'Ahmed Elsherbini'),
            _buildCreditRow('Map Illustration', 'Generated with ChatGPT'),

            const SizedBox(height: 16),
            const Text(
              'All sounds and music used in this project are royalty-free. All real location photographs in this project were taken by the founder.',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: AppColors.muted,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.coral,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Close',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            color: AppColors.dark,
            height: 1.4,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
