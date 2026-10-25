import 'package:flutter/material.dart';

/// Single animation coordinator for the Doctor Dashboard load-in entrance animation.
///
/// Drives all staggered intervals (~1.1s total length) from ONE [AnimationController]:
/// - 0ms: Top bar already visible, headline opacity 0 -> 1 over 0-150ms.
/// - 100-500ms: Next patient card fades in & rises 8px.
///   - Date & time chips fade in 80ms after card (180-500ms).
///   - Two pill buttons rise from bottom edge (translateY 24 -> 0, rotation -4deg -> 0, ~3% overshoot).
/// - 300-700ms: Recent patients header fades in; avatar circles pop in left-to-right (scale 0.85 -> 1 + opacity, 40ms apart).
/// - 400-800ms: Later today header fades in; cards slide from right (translateX 24 -> 0 + opacity, 60ms apart).
/// - 500-900ms: Needs attention header fades in; rows fade in top-to-bottom (translateY 8 -> 0 + opacity, 70ms apart).
/// - 550-1000ms: Bottom nav rises (translateY 40 -> 0); active tab circle pops at ~750ms (scale 0.6 -> 1, small spring); tab labels fade in at ~900ms.
/// - Emergency strip: NO animation. Fully visible & tappable from frame 0.
class DashboardEntranceAnimation {
  final AnimationController controller;

  static const totalDuration = Duration(milliseconds: 1100);

  // Subtle overshoot curve for Next patient buttons (~3% overshoot)
  static const nextPatientButtonsCurve = Cubic(0.34, 1.15, 0.64, 1.0);

  // Small spring overshoot curve for nav active circle (~4% overshoot)
  static const navActiveCircleCurve = Cubic(0.34, 1.20, 0.64, 1.0);

  // Standard fast start, soft landing ease-out cubic
  static const easeOutCubic = Curves.easeOutCubic;

  late final Animation<double> headlineFade;
  late final Animation<double> nextPatientCard;
  late final Animation<double> nextPatientChips;
  late final Animation<double> nextPatientButtons;
  late final Animation<double> recentPatientsHeader;
  late final Animation<double> laterTodayHeader;
  late final Animation<double> needsAttentionHeader;
  late final Animation<double> navBarSlide;
  late final Animation<double> navActiveCircle;
  late final Animation<double> navLabelsFade;

  final Map<int, Animation<double>> _recentPatientAvatars = {};
  final Map<int, Animation<double>> _laterTodayCards = {};
  final Map<int, Animation<double>> _needsAttentionRows = {};

  DashboardEntranceAnimation(this.controller) {
    _initAnimations();
  }

  void _initAnimations() {
    // 0ms - 150ms: Headline opacity 0 to 1
    headlineFade = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.0, 150 / 1100, curve: easeOutCubic),
    );

    // 100ms - 500ms: Next patient card fade and 8px translateY
    nextPatientCard = CurvedAnimation(
      parent: controller,
      curve: const Interval(100 / 1100, 500 / 1100, curve: easeOutCubic),
    );

    // 180ms - 500ms: Date and time chips fade (80ms after card starts)
    nextPatientChips = CurvedAnimation(
      parent: controller,
      curve: const Interval(180 / 1100, 500 / 1100, curve: easeOutCubic),
    );

    // 180ms - 500ms: Buttons translateY 24->0, rotation -4deg->0 with ~3% overshoot
    nextPatientButtons = CurvedAnimation(
      parent: controller,
      curve: const Interval(180 / 1100, 500 / 1100, curve: nextPatientButtonsCurve),
    );

    // 300ms - 500ms: Recent patients section header fade
    recentPatientsHeader = CurvedAnimation(
      parent: controller,
      curve: const Interval(300 / 1100, 500 / 1100, curve: easeOutCubic),
    );

    // 400ms - 600ms: Later today section header fade
    laterTodayHeader = CurvedAnimation(
      parent: controller,
      curve: const Interval(400 / 1100, 600 / 1100, curve: easeOutCubic),
    );

    // 500ms - 700ms: Needs attention section header fade
    needsAttentionHeader = CurvedAnimation(
      parent: controller,
      curve: const Interval(500 / 1100, 700 / 1100, curve: easeOutCubic),
    );

    // 550ms - 850ms: Bottom nav bar container rise (translateY 40 -> 0)
    navBarSlide = CurvedAnimation(
      parent: controller,
      curve: const Interval(550 / 1100, 850 / 1100, curve: easeOutCubic),
    );

    // ~750ms - 950ms: Active tab circle pop from inside bar (scale 0.6 -> 1, small spring)
    navActiveCircle = CurvedAnimation(
      parent: controller,
      curve: const Interval(750 / 1100, 950 / 1100, curve: navActiveCircleCurve),
    );

    // ~900ms - 1050ms: Tab labels fade in
    navLabelsFade = CurvedAnimation(
      parent: controller,
      curve: const Interval(900 / 1100, 1050 / 1100, curve: easeOutCubic),
    );
  }

  /// Recent patients avatar pop: 300-700ms, 40ms apart (scale 0.85 -> 1 + opacity)
  Animation<double> recentPatientAvatar(int index) {
    return _recentPatientAvatars.putIfAbsent(index, () {
      final startMs = (340 + index * 40).clamp(300, 580);
      final endMs = (startMs + 180).clamp(startMs + 50, 700);
      return CurvedAnimation(
        parent: controller,
        curve: Interval(startMs / 1100, endMs / 1100, curve: easeOutCubic),
      );
    });
  }

  /// Later today cards slide in from right: 400-800ms, 60ms apart (translateX 24 -> 0 + opacity)
  Animation<double> laterTodayCard(int index) {
    return _laterTodayCards.putIfAbsent(index, () {
      final startMs = (440 + index * 60).clamp(400, 660);
      final endMs = (startMs + 200).clamp(startMs + 50, 800);
      return CurvedAnimation(
        parent: controller,
        curve: Interval(startMs / 1100, endMs / 1100, curve: easeOutCubic),
      );
    });
  }

  /// Needs attention rows fade in top to bottom: 500-900ms, 70ms apart (translateY 8 -> 0 + opacity)
  Animation<double> needsAttentionRow(int index) {
    return _needsAttentionRows.putIfAbsent(index, () {
      final startMs = (540 + index * 70).clamp(500, 780);
      final endMs = (startMs + 180).clamp(startMs + 50, 900);
      return CurvedAnimation(
        parent: controller,
        curve: Interval(startMs / 1100, endMs / 1100, curve: easeOutCubic),
      );
    });
  }
}
