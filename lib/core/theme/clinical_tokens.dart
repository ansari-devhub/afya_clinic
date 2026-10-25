import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central Design Tokens for the Clinical App.
///
/// Supports both Light and Dark mode without hardcoding colors in widgets.
/// Follows the clinical design specifications strictly.
@immutable
class ClinicalTokens extends ThemeExtension<ClinicalTokens> {
  // Brand & Colors
  final Color primary;
  final Color onPrimary;
  final Color background;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color success;
  final Color successContainer;
  final Color danger;
  final Color dangerContainer;
  final Color accentTint;

  // Radii
  static const double radiusCard = 12.0;
  static const double radiusHero = 20.0;
  static const double radiusNextPatient = 16.0;
  static const double radiusPill = 20.0;
  static const double radiusBottomNav = 30.0;
  static const double radiusTile = 9.0;
  static const double radiusChip = 8.0;

  // Spacing
  static const double screenSidePadding = 14.0;
  static const double sectionSpacing = 16.0;
  static const double sectionLabelToContent = 8.0;
  static const double rowGap = 10.0;

  // Sizes & Borders
  static const double defaultIconSize = 20.0;
  static const double borderWidth = 0.5;

  const ClinicalTokens({
    required this.primary,
    required this.onPrimary,
    required this.background,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.success,
    required this.successContainer,
    required this.danger,
    required this.dangerContainer,
    required this.accentTint,
  });

  /// Light mode design tokens
  static const ClinicalTokens light = ClinicalTokens(
    primary: Color(0xFF3B6FE0),
    onPrimary: Color(0xFFFFFFFF),
    background: Color(0xFFF6F7FB),
    surface: Color(0xFFFFFFFF),
    border: Color(0x1F1A1D29), // 0.5px low-contrast
    textPrimary: Color(0xFF1A1D29),
    textSecondary: Color(0xFF5F6577),
    textMuted: Color(0xFF949BAE),
    success: Color(0xFF1E8E3E),
    successContainer: Color(0xFFE6F4EA),
    danger: Color(0xFFD93025),
    dangerContainer: Color(0xFFFDECEA),
    accentTint: Color(0x1F3B6FE0), // ~12% primary opacity
  );

  /// Dark mode design tokens matching the clinical wireframe
  static const ClinicalTokens dark = ClinicalTokens(
    primary: Color(0xFF3B6FE0),
    onPrimary: Color(0xFFFFFFFF),
    background: Color(0xFF12141C),
    surface: Color(0xFF1E2230),
    border: Color(0x2EFFFFFF), // 0.5px low-contrast
    textPrimary: Color(0xFFF0F2F8),
    textSecondary: Color(0xFF9DA4B7),
    textMuted: Color(0xFF6C7387),
    success: Color(0xFF81C995),
    successContainer: Color(0xFF0E381E),
    danger: Color(0xFFF28B82),
    dangerContainer: Color(0xFF3C1310),
    accentTint: Color(0x2E3B6FE0), // ~18% primary opacity in dark
  );

  /// Helper to resolve tokens from the current context.
  static ClinicalTokens of(BuildContext context) {
    final ext = Theme.of(context).extension<ClinicalTokens>();
    if (ext != null) return ext;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? dark : light;
  }

  // --- Type Scale ---
  // Ratios from a 320px wireframe mapped to Flutter standard scale.
  // headline 15/medium, section title 13/medium, card title 14/medium,
  // body/secondary 11-12/regular, chips and nav labels 10.

  TextStyle get headlineStyle => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.33,
        color: textPrimary,
      );

  TextStyle get sectionTitleStyle => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.38,
        color: textPrimary,
      );

  TextStyle get heroNameStyle => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: onPrimary,
      );

  TextStyle get rowLabelStyle => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.38,
        color: textPrimary,
      );

  TextStyle get cardTitleStyle => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.36,
        color: textPrimary,
      );

  TextStyle get bodyStyle => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: textPrimary,
      );

  TextStyle get secondaryStyle => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.36,
        color: textSecondary,
      );

  TextStyle get chipStyle => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: textSecondary,
      );

  TextStyle get navLabelStyle => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: onPrimary,
      );

  @override
  ClinicalTokens copyWith({
    Color? primary,
    Color? onPrimary,
    Color? background,
    Color? surface,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? success,
    Color? successContainer,
    Color? danger,
    Color? dangerContainer,
    Color? accentTint,
  }) {
    return ClinicalTokens(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      danger: danger ?? this.danger,
      dangerContainer: dangerContainer ?? this.dangerContainer,
      accentTint: accentTint ?? this.accentTint,
    );
  }

  @override
  ClinicalTokens lerp(ThemeExtension<ClinicalTokens>? other, double t) {
    if (other is! ClinicalTokens) return this;
    return ClinicalTokens(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerContainer: Color.lerp(dangerContainer, other.dangerContainer, t)!,
      accentTint: Color.lerp(accentTint, other.accentTint, t)!,
    );
  }
}
