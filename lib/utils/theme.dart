import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Coffee-inspired warm palette
  static const Color primary = Color(0xFF5C3317);      // dark coffee brown
  static const Color primaryLight = Color(0xFF8B5E3C);  // medium brown
  static const Color primaryDark = Color(0xFF3B1F0A);   // espresso
  static const Color accent = Color(0xFF6B8F5E);        // soft sage green
  static const Color accentLight = Color(0xFF8FAF7F);
  static const Color background = Color(0xFFF5F0E8);   // warm cream
  static const Color surface = Color(0xFFFAF6EE);       // light cream
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2C1810);   // dark espresso text
  static const Color textSecondary = Color(0xFF6B4C3B); // medium brown text
  static const Color textMuted = Color(0xFF9E7B6A);
  static const Color divider = Color(0xFFE5D8C8);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFF8F00);
  static const Color goldAccent = Color(0xFFD4A017);   // honey gold

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: accent,
      surface: surface,
      error: error,
    ).copyWith(
      primary: primary,
      secondary: accent,
      surface: surface,
      background: background,
    ),
    scaffoldBackgroundColor: background,
    fontFamily: GoogleFonts.cairo().fontFamily,
    textTheme: GoogleFonts.cairoTextTheme().copyWith(
      displayLarge: GoogleFonts.cairo(fontSize: 32, fontWeight: FontWeight.w800, color: textPrimary),
      headlineLarge: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary),
      headlineMedium: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
      titleLarge: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
      titleMedium: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary),
      bodyLarge: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary),
      bodyMedium: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary),
      labelLarge: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
      labelMedium: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w500, color: textMuted),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w700),
        elevation: 2,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary, width: 1.5),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardTheme(
      color: surfaceCard,
      elevation: 2,
      shadowColor: primary.withOpacity(0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error),
      ),
      labelStyle: GoogleFonts.cairo(color: textSecondary),
      hintStyle: GoogleFonts.cairo(color: textMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceCard,
      selectedItemColor: primary,
      unselectedItemColor: textMuted,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    dividerTheme: const DividerThemeData(color: divider, thickness: 1),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: primaryDark,
      contentTextStyle: GoogleFonts.cairo(color: Colors.white, fontSize: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
      contentTextStyle: GoogleFonts.cairo(fontSize: 15, color: textSecondary),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
    ),
  );
}
