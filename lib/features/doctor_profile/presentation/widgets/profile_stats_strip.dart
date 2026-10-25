import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/clinical_tokens.dart';
import '../../data/models/doctor_profile_data.dart';

/// Frosted stats panel for the Doctor Profile hero header.
///
/// Features:
/// - Inside the hero: 12px margin, radius 16, frosted glass (surface at ~90% opacity, 0.5px border, background blur).
/// - 3 equal columns: Experience (value + " yrs"), Patients, Consults.
/// - 26px accent-tint circle icon beside value (13 medium) over label (10 secondary).
/// - Count-up animation:
///   * Counts from 0 (or previous value) to target in ~1200ms with ease-out cubic curve.
///   * Staggered by 120ms between stats.
///   * Static "yrs" suffix.
///   * Tabular figures (monospaced digits) to prevent jitter.
///   * Thousands separators on every frame.
///   * Re-runs only when values change (e.g. after refresh), does nothing if unchanged.
///   * Reduced-motion accessibility (renders final value immediately).
///   * Exposes final value to screen readers via Semantics.
class ProfileStatsStrip extends StatefulWidget {
  final DoctorStats stats;
  final bool isFrosted;

  const ProfileStatsStrip({
    super.key,
    required this.stats,
    this.isFrosted = true,
  });

  @override
  State<ProfileStatsStrip> createState() => ProfileStatsStripState();
}

class ProfileStatsStripState extends State<ProfileStatsStrip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animExperience;
  late Animation<double> _animPatients;
  late Animation<double> _animConsults;

  int _oldExperience = 0;
  int _oldPatients = 0;
  int _oldConsults = 0;

  int _targetExperience = 0;
  int _targetPatients = 0;
  int _targetConsults = 0;

  // Stagger intervals: total duration 1440ms (1200ms animation + 240ms stagger)
  static const int _baseDurationMs = 1200;
  static const int _staggerMs = 120;
  static const int _totalDurationMs = _baseDurationMs + (_staggerMs * 2); // 1440ms

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _totalDurationMs),
    );

    _targetExperience = widget.stats.experienceYears;
    _targetPatients = widget.stats.totalPatients;
    _targetConsults = widget.stats.totalConsults;

    _oldExperience = 0;
    _oldPatients = 0;
    _oldConsults = 0;

    _setupAnimations();
    _controller.forward(from: 0.0);
  }

  void _setupAnimations() {
    const totalD = 1440.0;

    // 1. Experience: 0ms -> 1200ms
    _animExperience = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.0 / totalD,
        1200.0 / totalD,
        curve: Curves.easeOutCubic,
      ),
    );

    // 2. Patients: 120ms -> 1320ms
    _animPatients = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        120.0 / totalD,
        1320.0 / totalD,
        curve: Curves.easeOutCubic,
      ),
    );

    // 3. Consults: 240ms -> 1440ms
    _animConsults = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        240.0 / totalD,
        1.0,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant ProfileStatsStrip oldWidget) {
    super.didUpdateWidget(oldWidget);

    final expChanged = widget.stats.experienceYears != oldWidget.stats.experienceYears;
    final patChanged = widget.stats.totalPatients != oldWidget.stats.totalPatients;
    final conChanged = widget.stats.totalConsults != oldWidget.stats.totalConsults;

    if (expChanged || patChanged || conChanged) {
      // Interpolate current values as starting points for animation
      _oldExperience = _calculateCurrent(_oldExperience, _targetExperience, _animExperience.value);
      _oldPatients = _calculateCurrent(_oldPatients, _targetPatients, _animPatients.value);
      _oldConsults = _calculateCurrent(_oldConsults, _targetConsults, _animConsults.value);

      _targetExperience = widget.stats.experienceYears;
      _targetPatients = widget.stats.totalPatients;
      _targetConsults = widget.stats.totalConsults;

      _setupAnimations();
      _controller.forward(from: 0.0);
    }
  }

  int _calculateCurrent(int start, int target, double progress) {
    return (start + (target - start) * progress).round();
  }

  /// Manually retrigger count-up animation (e.g. for testing / demo).
  void replay() {
    _oldExperience = 0;
    _oldPatients = 0;
    _oldConsults = 0;
    _setupAnimations();
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = ClinicalTokens.of(context);
    final reduceAnimations = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final expVal = reduceAnimations
            ? _targetExperience
            : _calculateCurrent(_oldExperience, _targetExperience, _animExperience.value);
        final patVal = reduceAnimations
            ? _targetPatients
            : _calculateCurrent(_oldPatients, _targetPatients, _animPatients.value);
        final conVal = reduceAnimations
            ? _targetConsults
            : _calculateCurrent(_oldConsults, _targetConsults, _animConsults.value);

        final expFormatted = '${DoctorStats.formatThousands(expVal)} yrs';
        final patFormatted = DoctorStats.formatThousands(patVal);
        final conFormatted = DoctorStats.formatThousands(conVal);

        final content = Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isFrosted
                ? tokens.surface.withValues(alpha: 0.90)
                : tokens.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: tokens.border.withValues(alpha: widget.isFrosted ? 0.20 : 1.0),
              width: ClinicalTokens.borderWidth,
            ),
          ),
          child: Row(
            children: [
              // 1. Experience
              Expanded(
                child: _buildStatItem(
                  tokens: tokens,
                  icon: Icons.history_edu_outlined,
                  value: expFormatted,
                  finalValueForSemantics: '${DoctorStats.formatThousands(_targetExperience)} yrs',
                  label: 'Experience',
                ),
              ),

              // Divider
              Container(
                height: 24,
                width: ClinicalTokens.borderWidth,
                color: tokens.border.withValues(alpha: 0.35),
              ),

              // 2. Patients
              Expanded(
                child: _buildStatItem(
                  tokens: tokens,
                  icon: Icons.people_outline_rounded,
                  value: patFormatted,
                  finalValueForSemantics: DoctorStats.formatThousands(_targetPatients),
                  label: 'Patients',
                ),
              ),

              // Divider
              Container(
                height: 24,
                width: ClinicalTokens.borderWidth,
                color: tokens.border.withValues(alpha: 0.35),
              ),

              // 3. Consults
              Expanded(
                child: _buildStatItem(
                  tokens: tokens,
                  icon: Icons.chat_bubble_outline_rounded,
                  value: conFormatted,
                  finalValueForSemantics: DoctorStats.formatThousands(_targetConsults),
                  label: 'Consults',
                ),
              ),
            ],
          ),
        );

        if (!widget.isFrosted) return content;

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: content,
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required ClinicalTokens tokens,
    required IconData icon,
    required String value,
    required String finalValueForSemantics,
    required String label,
  }) {
    return Semantics(
      label: '$label: $finalValueForSemantics',
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 26px accent-tint circle icon
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: tokens.accentTint,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                size: 14,
                color: tokens.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Value over label
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: tokens.bodyStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: tokens.chipStyle.copyWith(
                    color: tokens.textSecondary,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
