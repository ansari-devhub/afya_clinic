import 'package:flutter/material.dart';
import '../../../../core/theme/clinical_tokens.dart';
import '../../data/models/doctor_schedule_data.dart';

/// Compact filled next-patient card for the timeline matching spec:
/// - Filled primary background, radius 16
/// - 36px avatar, name (14 medium), "visit type · age, sex",
///   translucent "Checked in" chip
/// - "Start consult" (white background, primary text) and
///   "View chart" (translucent white, on-primary text) pill buttons
/// - Exactly one card, only when viewing today: first non-completed appointment
class TimelineNextPatientCard extends StatelessWidget {
  final ScheduleAppointment appointment;
  final VoidCallback? onStartConsult;
  final VoidCallback? onViewChart;
  final VoidCallback? onTap;

  const TimelineNextPatientCard({
    super.key,
    required this.appointment,
    this.onStartConsult,
    this.onViewChart,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = ClinicalTokens.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: tokens.primary,
        borderRadius: BorderRadius.circular(ClinicalTokens.radiusNextPatient),
        boxShadow: [
          BoxShadow(
            color: tokens.primary.withValues(alpha: 0.28),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Avatar + Name + Subtitle + Translucent "Checked in" chip
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 36px Avatar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tokens.onPrimary.withValues(alpha: 0.2),
                ),
                clipBehavior: Clip.antiAlias,
                child: appointment.patientPhotoUrl != null
                    ? Image.network(
                        appointment.patientPhotoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildInitialsFallback(tokens),
                      )
                    : _buildInitialsFallback(tokens),
              ),
              const SizedBox(width: 10),

              // Name + Subtitle (age, sex)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      appointment.patientName,
                      style: tokens.cardTitleStyle.copyWith(
                        color: tokens.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      appointment.compactSubtitle,
                      style: tokens.secondaryStyle.copyWith(
                        color: tokens.onPrimary.withValues(alpha: 0.85),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Translucent "Checked in" chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(ClinicalTokens.radiusChip),
                ),
                child: Text(
                  'Checked in',
                  style: tokens.chipStyle.copyWith(
                    color: tokens.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Bottom Row: "Start consult" and "View chart" pill buttons
          Row(
            children: [
              // Start consult (white pill, primary text)
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: onStartConsult,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tokens.surface,
                      foregroundColor: tokens.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ClinicalTokens.radiusPill),
                      ),
                    ),
                    child: Text(
                      'Start consult',
                      style: tokens.secondaryStyle.copyWith(
                        color: tokens.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // View chart (translucent white, on-primary text)
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: OutlinedButton(
                    onPressed: onViewChart,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.18),
                      foregroundColor: tokens.onPrimary,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1.0,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ClinicalTokens.radiusPill),
                      ),
                    ),
                    child: Text(
                      'View chart',
                      style: tokens.secondaryStyle.copyWith(
                        color: tokens.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInitialsFallback(ClinicalTokens tokens) {
    return Center(
      child: Text(
        appointment.initials,
        style: tokens.chipStyle.copyWith(
          color: tokens.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
