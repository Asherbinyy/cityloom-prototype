import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';

class CreditsDialog extends StatelessWidget {
  const CreditsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: const Color(0xFFFEFAF6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.blush),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Credits',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.muted),
                    onPressed: () {
                      SoundService.playTap();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const Divider(color: AppColors.blush, height: 16),
              const SizedBox(height: 8),

              _buildCreditItem('Director & Research', 'Malek Ben Khaled'),
              _buildCreditItem('Scriptwriter', 'Aoibhín Gallagher'),
              _buildCreditItem('Voice Actors',
                  'Gregor Campbell, Kieran Lee-Hamilton, Robbie Hail, Malek Ben Khaled'),
              _buildCreditItem('Sound Production & Design', 'Malek Ben Khaled'),
              _buildCreditItem('Quiz Concept', 'Malek Ben Khaled'),
              _buildCreditItem('Prototype Development', 'Ahmed Elsherbini'),

              const SizedBox(height: 14),

              // Sounds & Photos notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.blush),
                ),
                child: Text(
                  'All sounds and music used in this project are copyright and royalty-free. All real location photographs in this project were taken by the founder.',
                  style: GoogleFonts.dmSans(
                    fontSize: 11.5,
                    height: 1.45,
                    color: AppColors.dark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 12),

              // AI Illustration disclaimer + Learn More button
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.coral.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Disclaimer: Illustrations are currently AI-generated but will not be used in the final product.',
                      style: GoogleFonts.dmSans(
                        fontSize: 11.5,
                        height: 1.4,
                        color: AppColors.dark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () => _showAiExplanation(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          'Learn more →',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.coral,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  SoundService.playTap();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.coral,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAiExplanation(BuildContext context) {
    SoundService.playTap();
    showDialog(
      context: context,
      builder: (ctx) => const AiDisclaimerDialog(),
    );
  }

  Widget _buildCreditItem(String role, String names) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            role.toUpperCase(),
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.coral,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            names,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class AiDisclaimerDialog extends StatelessWidget {
  const AiDisclaimerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: const Color(0xFFFEFAF6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.blush),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Why are the cards and map AI-generated for now?',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark,
                        height: 1.25,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.muted),
                    onPressed: () {
                      SoundService.playTap();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const Divider(color: AppColors.blush, height: 16),
              const SizedBox(height: 8),

              Text(
                "These illustrations are placeholder. They're here purely to show the direction we want CityLoom to take visually, not the final product.",
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.dark,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              _buildBulletPoint(
                'The map will be professionally designed early on, within our initial budget (as part of our Fiverr designer\'s scope).',
              ),
              _buildBulletPoint(
                'The cards will initially use a simpler, cleaner design — likely featuring real, copyright-free photographs of the actual characters rather than illustrations.',
              ),
              _buildBulletPoint(
                'Long-term, once budget allows, we want to develop a distinct visual identity and branding for CityLoom, with a unique illustration style for the cards. That\'s the vision the AI placeholders are hinting at.',
              ),

              const SizedBox(height: 12),
              Text(
                "We're fortunate to already have a strong lead for that future step: Roger Coronel-Hillary, one of our Spanish-speaking collaborators based in Edinburgh, is a professional designer and illustrator, and would be our natural first choice for this collaboration. Nothing has been finalized yet, including budget, since card design isn't a current priority, and it's still too early to know how many cards each package will need.",
                style: GoogleFonts.dmSans(
                  fontSize: 12.5,
                  color: AppColors.muted,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  SoundService.playTap();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.coral,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Understood',
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14, color: AppColors.coral, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.dmSans(
                fontSize: 12.5,
                color: AppColors.dark,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
