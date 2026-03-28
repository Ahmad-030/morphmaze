import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core palette
  static const Color bgDeep = Color(0xFF080B1A);
  static const Color bgCard = Color(0xFF0F1428);
  static const Color bgSurface = Color(0xFF161C35);
  static const Color accent = Color(0xFF00F5FF);
  static const Color accentGlow = Color(0xFF00C8FF);
  static const Color neonPurple = Color(0xFFB24BF3);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color neonPink = Color(0xFFFF2D78);
  static const Color neonYellow = Color(0xFFFFE500);
  static const Color textPrimary = Color(0xFFEEF2FF);
  static const Color textMuted = Color(0xFF7B8FCA);
  static const Color wallColor = Color(0xFF1E2847);
  static const Color wallBorder = Color(0xFF2E3F72);

  // Shape colors
  static const Color circleColor = Color(0xFF00F5FF);
  static const Color squareColor = Color(0xFFB24BF3);
  static const Color triangleColor = Color(0xFFFF2D78);

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDeep,
    textTheme: GoogleFonts.orbitronTextTheme().apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    ),
    colorScheme: const ColorScheme.dark(
      primary: accent,
      secondary: neonPurple,
      surface: bgCard,
    ),
  );

  static TextStyle get headingStyle => GoogleFonts.orbitron(
    color: textPrimary,
    fontWeight: FontWeight.w900,
    letterSpacing: 2,
  );

  static TextStyle get labelStyle => GoogleFonts.rajdhani(
    color: textMuted,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
  );

  static BoxDecoration glowBox(Color color) => BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: color.withOpacity(0.5), width: 1.5),
    boxShadow: [
      BoxShadow(color: color.withOpacity(0.15), blurRadius: 20, spreadRadius: 2),
    ],
    color: bgCard,
  );

  static BoxShadow glowShadow(Color color, {double blur = 20}) =>
      BoxShadow(color: color.withOpacity(0.6), blurRadius: blur, spreadRadius: 1);
}