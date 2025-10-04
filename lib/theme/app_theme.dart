import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color nasaBlue = Color(0xFF0B3D91);
  static const Color nasaDarkBlue = Color(0xFF001133);
  static const Color spaceBlack = Color(0xFF0A0A0A);
  static const Color starWhite = Color(0xFFE8F4F8);
  static const Color cosmicPurple = Color(0xFF6B46C1);
  static const Color nebulaBlue = Color(0xFF1E40AF);
  static const Color surfaceGrey = Color(0xFF1F2937);
  static const Color cardGrey = Color(0xFF374151);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: nasaBlue,
        primaryContainer: nasaDarkBlue,
        secondary: cosmicPurple,
        secondaryContainer: nebulaBlue,
        surface: spaceBlack,
        onSurface: starWhite,
        surfaceContainerHighest: surfaceGrey,
        surfaceContainer: cardGrey,
        outline: surfaceGrey,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.copyWith(
          headlineLarge: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: starWhite,
          ),
          headlineMedium: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: starWhite,
          ),
          titleLarge: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: starWhite,
          ),
          titleMedium: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: starWhite,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: starWhite.withValues(alpha: 0.9),
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: starWhite.withValues(alpha: 0.8),
          ),
          bodySmall: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: starWhite.withValues(alpha: 0.7),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardGrey,
        elevation: 8,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: nasaBlue,
          foregroundColor: starWhite,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: nasaBlue,
        foregroundColor: starWhite,
        elevation: 8,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceGrey,
        selectedItemColor: nasaBlue,
        unselectedItemColor: starWhite.withValues(alpha: 0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 16,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: spaceBlack,
        foregroundColor: starWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: starWhite,
        ),
      ),
      scaffoldBackgroundColor: spaceBlack,
    );
  }

  static BoxDecoration get spaceGradient {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          spaceBlack,
          nasaDarkBlue,
          spaceBlack,
        ],
        stops: [0.0, 0.5, 1.0],
      ),
    );
  }

  static BoxDecoration get cardGradient {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          cardGrey.withValues(alpha: 0.9),
          surfaceGrey.withValues(alpha: 0.7),
        ],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: starWhite.withValues(alpha: 0.1),
        width: 1,
      ),
    );
  }
}