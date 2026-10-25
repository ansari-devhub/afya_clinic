import 'package:flutter/animation.dart';

/// Animation constants for the Afya Clinic app.
/// Centralizes durations, curves, and intervals for consistent motion design.
class AppMotion {
  const AppMotion._();

  // ============================================================================
  // SPLASH SCREEN - PHASE 1: ENTRANCE ANIMATION
  // ============================================================================

  /// Total duration of the splash entrance animation
  static const Duration splashEntranceDuration = Duration(milliseconds: 1600);

  /// Minimum time the splash screen stays visible (including animation)
  static const Duration splashMinimumDuration = Duration(milliseconds: 1800);

  /// Maximum time to wait for initialization before proceeding anyway
  static const Duration splashTimeout = Duration(seconds: 6);

  // Logo animation (0.0 - 0.5): fade in + scale from 0.8 to 1.0
  static const double splashLogoIntervalStart = 0.0;
  static const double splashLogoIntervalEnd = 0.5;
  static const Curve splashLogoCurve = Curves.easeOutBack;
  static const double splashLogoScaleFrom = 0.8;
  static const double splashLogoScaleTo = 1.0;

  // Glow animation (0.3 - 0.7): expand and fade
  static const double splashGlowIntervalStart = 0.3;
  static const double splashGlowIntervalEnd = 0.7;
  static const Curve splashGlowCurve = Curves.easeOut;
  static const double splashGlowOpacity = 0.15;
  static const double splashGlowScaleFrom = 0.5;
  static const double splashGlowScaleTo = 2.0;

  // App name animation (0.5 - 0.9): fade in + slide up
  static const double splashAppNameIntervalStart = 0.5;
  static const double splashAppNameIntervalEnd = 0.9;
  static const Curve splashAppNameCurve = Curves.easeOut;
  static const double splashAppNameSlideOffset = 12.0; // pixels

  // Tagline animation (0.7 - 1.0): fade in
  static const double splashTaglineIntervalStart = 0.7;
  static const double splashTaglineIntervalEnd = 1.0;
  static const Curve splashTaglineCurve = Curves.easeOut;

  // ============================================================================
  // SPLASH SCREEN - IDLE PULSE (after entrance completes)
  // ============================================================================

  /// Duration of the idle pulse animation (logo breathing effect)
  static const Duration splashPulseDuration = Duration(milliseconds: 2000);

  static const Curve splashPulseCurve = Curves.easeInOut;
  static const double splashPulseScaleFrom = 1.0;
  static const double splashPulseScaleTo = 1.03;

  // ============================================================================
  // SPLASH SCREEN - PHASE 2: EXIT TRANSITION
  // ============================================================================

  /// Duration of the splash exit + onboarding entrance transition
  static const Duration splashExitDuration = Duration(milliseconds: 700);

  // Splash text fade-out (0.0 - 0.4)
  static const double splashTextFadeOutStart = 0.0;
  static const double splashTextFadeOutEnd = 0.4;
  static const Curve splashTextFadeOutCurve = Curves.easeIn;

  // Splash logo scale-down + fade-out (0.0 - 0.4)
  static const double splashLogoExitStart = 0.0;
  static const double splashLogoExitEnd = 0.4;
  static const Curve splashLogoExitCurve = Curves.easeIn;
  static const double splashLogoExitScale = 0.9;

  // Onboarding image fade-in + zoom (0.2 - 0.7)
  static const double onboardingImageEntranceStart = 0.2;
  static const double onboardingImageEntranceEnd = 0.7;
  static const Curve onboardingImageEntranceCurve = Curves.easeOut;
  static const double onboardingImageScaleFrom = 1.08;
  static const double onboardingImageScaleTo = 1.0;

  // Onboarding bottom sheet slide-up (0.4 - 1.0)
  static const double onboardingSheetSlideStart = 0.4;
  static const double onboardingSheetSlideEnd = 1.0;
  static const Curve onboardingSheetSlideCurve = Curves.easeOutCubic;

  // Onboarding bottom sheet content fade-in (0.6 - 1.0)
  static const double onboardingContentFadeStart = 0.6;
  static const double onboardingContentFadeEnd = 1.0;
  static const Curve onboardingContentFadeCurve = Curves.easeOut;

  // ============================================================================
  // GENERIC ROUTE TRANSITIONS
  // ============================================================================

  /// Simple fade transition for login/home routes (not onboarding)
  static const Duration genericFadeDuration = Duration(milliseconds: 400);
  static const Curve genericFadeCurve = Curves.easeInOut;
}
