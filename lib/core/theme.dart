import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CosmicTheme {
  static const Color primaryDeepIndigo = Color(0xFF1A1B4B);
  static const Color backgroundMidnightBlack = Color(0xFF0A0A0A);
  static const Color accentElectricPurple = Color(0xFF7B2CBF);
  static const Color accentSoftCyan = Color(0xFF00F5D4);
  static const Color glassWhite = Color(0x1AFFFFFF);

  static const Map<String, List<Color>> gradients = {
    'Deep Purple': [Color(0xFF3A0CA3), Color(0xFF7209B7)],
    'Cosmic Blue': [Color(0xFF03045E), Color(0xFF0077B6)],
    'Sunset Orange': [Color(0xFFE85D04), Color(0xFFD00000)],
    'Forest Green': [Color(0xFF132A13), Color(0xFF3F5E3D)],
    'Electric Teal': [Color(0xFF005F73), Color(0xFF0A9396)],
  };

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
