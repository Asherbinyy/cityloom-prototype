import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color sky = Color(0xFFA5CEE4);
  static const Color coral = Color(0xFFFDA692);
  static const Color blush = Color(0xFFFDEADA);
  static const Color cream = Color(0xFFFFF4EB);
  static const Color dark = Color(0xFF2A2A2A);
  static const Color muted = Color(0xFF6B6B6B);
  
  // Card Rarities
  static const Color rarityCommon = Color(0xFF7A8B99);
  static const Color rarityUncommon = Color(0xFF4A90E2);
  static const Color rarityRare = Color(0xFFE5A93B);
  static const Color rarityLegendary = Color(0xFF9B51E0);

  // Status & Feedback
  static const Color correctGreen = Color(0xFF2E7D32);
  static const Color correctGreenBg = Color(0xFFE8F5E9);
  static const Color incorrectRed = Color(0xFFC62828);
  static const Color incorrectRedBg = Color(0xFFFFEBEE);

  // Gradients
  static const LinearGradient warmBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF4EB), Color(0xFFFDEADA), Color(0xFFFDA692)],
  );

  static const LinearGradient libraryBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF4EB), Color(0xFFD4E8F2), Color(0xFFA5CEE4)],
  );

  static const LinearGradient cardGlow = LinearGradient(
    colors: [Color(0x33FDA692), Color(0x33A5CEE4)],
  );
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.cream,
      primaryColor: AppColors.coral,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.coral,
        primary: AppColors.coral,
        secondary: AppColors.sky,
        surface: AppColors.cream,
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.dark,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.dark,
        ),
        headlineSmall: GoogleFonts.playfairDisplay(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.dark,
        ),
        titleMedium: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.dark,
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 15,
          color: AppColors.dark,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 14,
          color: AppColors.muted,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        labelSmall: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.5,
          color: AppColors.coral,
        ),
      ),
    );
  }
}
