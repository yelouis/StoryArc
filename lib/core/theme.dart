import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CosmicTheme {
  static const Color primaryDeepIndigo = Color(0xFF1A1B4B);
  static const Color backgroundMidnightBlack = Color(0xFF0A0A0A);
  static const Color accentElectricPurple = Color(0xFF7B2CBF);
  static const Color glassWhite = Color(0x1AFFFFFF);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryDeepIndigo,
      scaffoldBackgroundColor: backgroundMidnightBlack,
      colorScheme: const ColorScheme.dark(
        primary: primaryDeepIndigo,
        secondary: accentElectricPurple,
        surface: Color(0xFF121212),
        background: backgroundMidnightBlack,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: GoogleFonts.inter(
          color: Colors.white70,
        ),
      ),
      cardTheme: CardTheme(
        color: glassWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentElectricPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
