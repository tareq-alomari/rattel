import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Quran Theme System - Professional & Unified Design
class QuranTheme {
  // Theme Colors
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color darkGold = Color(0xFFB8941F);
  static const Color lightGold = Color(0xFFE8D7A0);

  static const Color paperBeige = Color(0xFFFAF8F3);
  static const Color darkPaper = Color(0xFF2C2416);

  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xFFF5F5F5);
  static const Color textGray = Color(0xFF666666);

  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFF44336);

  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [primaryGold, darkGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient paperGradient = LinearGradient(
    colors: [paperBeige, Color(0xFFF5F0E8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF2C2C2C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Text Styles
  static TextStyle get quranTextStyle => GoogleFonts.amiri(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 2.0,
    letterSpacing: 0.5,
  );

  static TextStyle get surahNameStyle => GoogleFonts.cairo(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.0,
  );

  static TextStyle get ayahNumberStyle =>
      GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600);

  static TextStyle get tafseerStyle =>
      GoogleFonts.cairo(fontSize: 16, height: 1.8);

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;

  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // Theme Data
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryGold,
      secondary: darkGold,
      surface: paperBeige,
      error: errorRed,
    ),
    scaffoldBackgroundColor: paperBeige,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: textDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusM),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGold,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(
          horizontal: spacingL,
          vertical: spacingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.cairo(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
      displayMedium: GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
      bodyLarge: GoogleFonts.cairo(fontSize: 16, color: textDark),
      bodyMedium: GoogleFonts.cairo(fontSize: 14, color: textGray),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: lightGold,
      secondary: primaryGold,
      surface: darkPaper,
      error: errorRed,
    ),
    scaffoldBackgroundColor: const Color(0xFF1A1A1A),
    appBarTheme: AppBarTheme(
      backgroundColor: darkPaper,
      foregroundColor: textLight,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textLight,
      ),
    ),
    cardTheme: CardTheme(
      color: darkPaper,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusM),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightGold,
        foregroundColor: textDark,
        elevation: 2,
        padding: const EdgeInsets.symmetric(
          horizontal: spacingL,
          vertical: spacingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.cairo(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textLight,
      ),
      displayMedium: GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textLight,
      ),
      bodyLarge: GoogleFonts.cairo(fontSize: 16, color: textLight),
      bodyMedium: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[400]),
    ),
  );

  // Decorations
  static BoxDecoration get paperDecoration => BoxDecoration(
    gradient: paperGradient,
    borderRadius: BorderRadius.circular(radiusM),
    boxShadow: cardShadow,
  );

  static BoxDecoration get goldDecoration => BoxDecoration(
    gradient: goldGradient,
    borderRadius: BorderRadius.circular(radiusM),
    boxShadow: elevatedShadow,
  );

  static BoxDecoration ayahContainerDecoration(bool isDark) => BoxDecoration(
    color: isDark ? darkPaper : Colors.white,
    borderRadius: BorderRadius.circular(radiusM),
    border: Border.all(
      color: isDark
          ? lightGold.withValues(alpha: 0.3)
          : primaryGold.withValues(alpha: 0.3),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: (isDark ? Colors.black : Colors.grey).withValues(alpha: 0.1),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Widgets
  static Widget buildSurahHeader({
    required String surahName,
    required String surahNameEn,
    required int versesCount,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(spacingL),
      decoration: BoxDecoration(
        gradient: goldGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(radiusXL),
          bottomRight: Radius.circular(radiusXL),
        ),
        boxShadow: elevatedShadow,
      ),
      child: Column(
        children: [
          Text(
            surahName,
            style: GoogleFonts.amiri(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: spacingS),
          Text(
            surahNameEn,
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: spacingS),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: spacingM,
              vertical: spacingS,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(radiusS),
            ),
            child: Text(
              '$versesCount آية',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildAyahNumber(int number, bool isDark) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: goldGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: primaryGold.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$number',
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  static Widget buildDivider(bool isDark) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: spacingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            isDark
                ? lightGold.withValues(alpha: 0.3)
                : primaryGold.withValues(alpha: 0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
