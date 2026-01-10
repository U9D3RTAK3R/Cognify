import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Gen-Z Neon Colors
  static const Color primaryCyan = Color(0xFF00F5FF);
  static const Color accentPurple = Color(0xFFBF00FF);
  static const Color accentPink = Color(0xFFFF00A0);
  static const Color bgBlack = Color(0xFF0A0A0F);
  static const Color cardColor = Color(0xFF1A1A2E);
  static const Color textWhite = Color(0xFFF0F0F0);
  static const Color textGrey = Color(0xFF888888);

  // Text Styles
  static TextStyle get headlineLarge => GoogleFonts.outfit(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textWhite,
  );

  static TextStyle get headlineMedium => GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textWhite,
  );

  static TextStyle get bodyLarge => GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: textWhite,
  );

  static TextStyle get bodyMedium => GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textWhite,
  );

  static TextStyle get labelLarge => GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: textGrey,
  );

  // Theme Data
  static ThemeData get darkTheme => ThemeData.dark().copyWith(
    scaffoldBackgroundColor: bgBlack,
    primaryColor: primaryCyan,
    colorScheme: const ColorScheme.dark(
      primary: primaryCyan,
      secondary: accentPurple,
      surface: cardColor,
      onSurface: textWhite,
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryCyan,
        foregroundColor: bgBlack,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );

  // Light Theme
  static const Color lightBg = Color(0xFFF5F5F7);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1A1A2E);

  static ThemeData get lightTheme => ThemeData.light().copyWith(
    scaffoldBackgroundColor: lightBg,
    primaryColor: primaryCyan,
    colorScheme: const ColorScheme.light(
      primary: primaryCyan,
      secondary: accentPurple,
      surface: lightCard,
      onSurface: lightText,
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryCyan,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
