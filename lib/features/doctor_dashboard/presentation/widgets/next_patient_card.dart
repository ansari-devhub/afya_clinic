import 'package:flutter/material.dart';
import '../../../../core/theme/clinical_tokens.dart';
import '../../data/models/doctor_dashboard_data.dart';

/// Section 3: Next Patient Card
///
/// Specs:
/// - Filled primary background, on-primary text, radius 16.
/// - Row 1: circular patient photo (44px; initials fallback), name (14 medium),
///   subtitle "visit type · age, sex" (12, 85% opacity),
///   and a video icon button on the right shown ONLY for telehealth visits.
/// - Row 2: two equal chips with a translucent white background,
///   one for Date (calendar icon, label "Date", value),
///   one for Time (clock icon, label "Time", value as a range).
/// - Row 3: two pill buttons, "Start consult" (white background, primary text)
///   and "View chart" (translucent white, on-primary text).
/// - Empty state: when no patient is left today, show a neutral card, "No more appointments today".
class NextPatientCard extends StatelessWidget {
  final NextPatientAppointment? appointment;
  final VoidCallback? onStartConsult;
  final VoidCallback? onViewChart;
  final VoidCallback? onVideoCall;

  final Animation<double>? cardAnimation;
  final Animation<double>? chipsAnimation;
  final Animation<double>? buttonsAnimation;

  const NextPatientCard({
    super.key,
    this.appointment,
    this.onStartConsult,
    this.onViewChart,
    this.onVideoCall,
    this.cardAnimation,
    this.chipsAnimation,
    this.buttonsAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = ClinicalTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Text(
          'Next patient',
          style: tokens.sectionTitleStyle,
        ),
        const SizedBox(height: ClinicalTokens.sectionLabelToContent),

        // Card content or Empty state
        if (appointment == null)
          _buildEmptyState(tokens)
        else
          _buildCard(context, tokens, appointment!),
      ],
    );
  }

  Widget _buildEmptyState(ClinicalTokens tokens) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(ClinicalTokens.radiusNextPatient),
        border: Border.all(
          color: tokens.border,
          width: ClinicalTokens.borderWidth,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 28,
              color: tokens.textMuted,
            ),
            const SizedBox(height: 8),
            Text(
              'No more appointments today',
              style: tokens.cardTitleStyle.copyWith(
                color: tokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    ClinicalTokens tokens,
    NextPatientAppointment patient,
  ) {
    final cardContent = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: tokens.primary,
        borderRadius: BorderRadius.circular(ClinicalTokens.radiusNextPatient),
        boxShadow: [
          BoxShadow(
            color: tokens.primary.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Avatar, Name, Subtitle, Telehealth Video Button
          Row(
            children: [
              // 44px circular avatar or initials fallback
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    patient.initials,
                    style: tokens.cardTitleStyle.copyWith(
                      color: tokens.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: ClinicalTokens.rowGap),

              // Patient Name & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      patient.name,
                      style: tokens.cardTitleStyle.copyWith(
                        color: tokens.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      patient.subtitle,
                      style: tokens.bodyStyle.copyWith(
                        color: tokens.onPrimary.withValues(alpha: 0.85),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Video button: shown ONLY for telehealth visits
              if (patient.isTelehealth)
                Semantics(
                  button: true,
                  label: 'Video call with ${patient.name}',
                  child: InkWell(
                    onTap: onVideoCall,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.videocam_outlined,
                        size: ClinicalTokens.defaultIconSize + 2,
                        color: tokens.onPrimary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Row 2: Two equal chips with translucent white background
          chipsAnimation == null
              ? _buildChipsRow(tokens, patient)
              : AnimatedBuilder(
                  animation: chipsAnimation!,
                  builder: (context, child) {
                    final progress = chipsAnimation!.value.clamp(0.0, 1.0);
                    return Opacity(
                      opacity: progress,
                      child: child,
                    );
                  },
                  child: _buildChipsRow(tokens, patient),
                ),
          const SizedBox(height: 14),

          // Row 3: Two pill buttons
          buttonsAnimation == null
              ? _buildButtonsRow(tokens)
              : AnimatedBuilder(
                  animation: buttonsAnimation!,
                  builder: (context, child) {
                    final progress = buttonsAnimation!.value;
                    final translateY = 24.0 * (1.0 - progress);
                    // -4 degrees in radians = -0.06981317
                    final rotation = -0.06981317 * (1.0 - progress);
                    return Transform(
                      transform: Matrix4.translationValues(0, translateY, 0)
                        ..rotateZ(rotation),
                      alignment: Alignment.bottomCenter,
                      child: child,
                    );
                  },
                  child: _buildButtonsRow(tokens),
                ),
        ],
      ),
    );

    if (cardAnimation == null) return cardContent;

    return AnimatedBuilder(
      animation: cardAnimation!,
      builder: (context, child) {
        final progress = cardAnimation!.value.clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, 8.0 * (1.0 - progress)),
          child: Opacity(
            opacity: progress,
            child: child,
          ),
        );
      },
      child: cardContent,
    );
  }

  Widget _buildChipsRow(ClinicalTokens tokens, NextPatientAppointment patient) {
    return Row(
      children: [
        // Date Chip
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: tokens.onPrimary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Date',
                        style: tokens.chipStyle.copyWith(
                          color: tokens.onPrimary.withValues(alpha: 0.80),
                          fontSize: 9,
                        ),
                      ),
                      Text(
                        patient.date,
                        style: tokens.bodyStyle.copyWith(
                          color: tokens.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: ClinicalTokens.rowGap),

        // Time Chip
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_outlined,
                  size: 16,
                  color: tokens.onPrimary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Time',
                        style: tokens.chipStyle.copyWith(
                          color: tokens.onPrimary.withValues(alpha: 0.80),
                          fontSize: 9,
                        ),
                      ),
                      Text(
                        patient.timeRange,
                        style: tokens.bodyStyle.copyWith(
                          color: tokens.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtonsRow(ClinicalTokens tokens) {
    return Row(
      children: [
        // Start consult (white background, primary text)
        Expanded(
          child: SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: onStartConsult,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: tokens.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ClinicalTokens.radiusPill),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Text(
                'Start consult',
                style: tokens.cardTitleStyle.copyWith(
                  color: tokens.primary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        const SizedBox(width: ClinicalTokens.rowGap),

        // View chart (translucent white, on-primary text)
        Expanded(
          child: SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: onViewChart,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.22),
                foregroundColor: tokens.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ClinicalTokens.radiusPill),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Text(
                'View chart',
                style: tokens.cardTitleStyle.copyWith(
                  color: tokens.onPrimary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
