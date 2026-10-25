import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Clinical Nexus Color Palette
  static const Color primary = Color(0xFF003D9B);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF0052CC);
  static const Color onPrimaryContainer = Color(0xFFC4D2FF);

  static const Color secondary = Color(0xFF006C49);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF6CF8BB);
  static const Color onSecondaryContainer = Color(0xFF00714D);

  static const Color tertiary = Color(0xFF004A58);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF006475);
  static const Color onTertiaryContainer = Color(0xFF6DE2FF);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  static const Color surface = Color(0xFFF8F9FF);
  static const Color surfaceDim = Color(0xFFCBDBF5);
  static const Color surfaceBright = Color(0xFFF8F9FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color surfaceContainerHighest = Color(0xFFD3E4FE);

  static const Color onSurface = Color(0xFF0B1C30);
  static const Color onSurfaceVariant = Color(0xFF434654);

  static const Color outline = Color(0xFF737685);
  static const Color outlineVariant = Color(0xFFC3C6D6);

  static const Color inverseSurface = Color(0xFF213145);
  static const Color inverseOnSurface = Color(0xFFEAF1FF);

  static const Color background = Color(0xFFF8F9FF);
  static const Color onBackground = Color(0xFF0B1C30);

  // Status colors
  static const Color statusCritical = Color(0xFFBA1A1A);
  static const Color statusStable = Color(0xFF006C49);
  static const Color statusPending = Color(0xFFFFA726);
  static const Color statusWarning = Color(0xFFFF6D00);

  // Border radius
  static const double radiusSm = 4.0;
  static const double radiusDefault = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 9999.0;

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
        inverseSurface: inverseSurface,
        onInverseSurface: inverseOnSurface,
      ),
      scaffoldBackgroundColor: background,
      textTheme: _textTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      cardTheme: _cardTheme,
      chipTheme: _chipTheme,
      bottomNavigationBarTheme: _bottomNavigationBarTheme,
      appBarTheme: _appBarTheme,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF12141C),
      cardTheme: _cardTheme.copyWith(color: const Color(0xFF1E2230)),
      textTheme: _textTheme.apply(
        bodyColor: const Color(0xFFF0F2F8),
        displayColor: const Color(0xFFF0F2F8),
      ),
    );
  }

  static TextTheme get _textTheme {
    return TextTheme(
      // Display Large - 40px, 700, -0.02em
      displayLarge: GoogleFonts.inter(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.8,
        color: onSurface,
      ),
      // Headline Large - 28px, 600, -0.01em
      headlineLarge: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.29,
        letterSpacing: -0.28,
        color: onSurface,
      ),
      // Headline Medium (Mobile) - 24px, 600
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.33,
        color: onSurface,
      ),
      // Title Medium - 18px, 600
      titleMedium: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.33,
        color: onSurface,
      ),
      // Body Medium - 16px, 400
      bodyMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: onSurface,
      ),
      // Body Small - 14px, 400
      bodySmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
        color: onSurfaceVariant,
      ),
      // Label Medium - 12px, 600, 0.05em
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.33,
        letterSpacing: 0.6,
        color: onSurfaceVariant,
      ),
      // Label Small - 11px, 500
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.45,
        color: onSurfaceVariant,
      ),
    );
  }

  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusDefault),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData get _outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusDefault),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
      ),
    );
  }

  static InputDecorationTheme get _inputDecorationTheme {
    return InputDecorationTheme(
      filled: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusDefault),
        borderSide: const BorderSide(color: outline, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusDefault),
        borderSide: const BorderSide(color: outline, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusDefault),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusDefault),
        borderSide: const BorderSide(color: error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusDefault),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      labelStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: onSurfaceVariant,
      ),
      floatingLabelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      hintStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: onSurfaceVariant,
      ),
    );
  }

  static CardThemeData get _cardTheme {
    return CardThemeData(
      elevation: 0,
      color: surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        side: BorderSide(color: outlineVariant.withValues(alpha: 0.5), width: 1),
      ),
      margin: const EdgeInsets.all(0),
    );
  }

  static ChipThemeData get _chipTheme {
    return ChipThemeData(
      backgroundColor: surfaceContainer,
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusFull),
      ),
    );
  }

  static BottomNavigationBarThemeData get _bottomNavigationBarTheme {
    return const BottomNavigationBarThemeData(
      backgroundColor: surfaceContainerLowest,
      selectedItemColor: primary,
      unselectedItemColor: onSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    );
  }

  static AppBarTheme get _appBarTheme {
    return AppBarTheme(
      backgroundColor: surfaceContainerLowest,
      foregroundColor: onSurface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
    );
  }
}
