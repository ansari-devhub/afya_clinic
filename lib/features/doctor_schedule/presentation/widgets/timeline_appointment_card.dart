import 'package:flutter/material.dart';
import '../../../../core/theme/clinical_tokens.dart';
import '../../../../core/widgets/clinical_status_chip.dart';
import '../../data/models/doctor_schedule_data.dart';

/// Appointment card for timeline matching spec:
/// a) Regular: surface, 0.5px border, radius 12, padding 10.
///    32px avatar circle, name (13 medium), "visit type · mode" (11 secondary),
///    trailing status chip, or primary video icon for telehealth.
/// b) Completed: same card at 60% opacity with a success "Completed" chip.
class TimelineAppointmentCard extends StatelessWidget {
  final ScheduleAppointment appointment;
  final bool isCompleted;
  final VoidCallback? onTap;
  final VoidCallback? onVideoTap;

  const TimelineAppointmentCard({
    super.key,
    required this.appointment,
    this.isCompleted = false,
    this.onTap,
    this.onVideoTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = ClinicalTokens.of(context);

    final cardContent = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(ClinicalTokens.radiusCard),
        border: Border.all(
          color: tokens.border,
          width: ClinicalTokens.borderWidth,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 32px circular avatar (photo or initials fallback)
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tokens.accentTint,
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

          // Name (13 medium) + Subtitle "visit type · mode" (11 secondary)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  appointment.patientName,
                  style: tokens.cardTitleStyle.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  appointment.subtitle,
                  style: tokens.secondaryStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Trailing: video icon for telehealth or status chip
          if (appointment.isTelehealth && !isCompleted)
            Semantics(
              button: true,
              label: 'Launch video call with ${appointment.patientName}',
              child: InkWell(
                onTap: onVideoTap ?? onTap,
                borderRadius: BorderRadius.circular(ClinicalTokens.radiusTile),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Icon(
                    Icons.videocam_outlined,
                    size: 20,
                    color: tokens.primary,
                  ),
                ),
              ),
            )
          else
            ClinicalStatusChip(
              status: isCompleted
                  ? ClinicalAppointmentStatus.completed
                  : appointment.status,
            ),
        ],
      ),
    );

    return Opacity(
      opacity: isCompleted ? 0.6 : 1.0,
      child: Semantics(
        button: true,
        label: 'Appointment with ${appointment.patientName}, ${appointment.subtitle}, ${isCompleted ? "Completed" : appointment.status.name}',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ClinicalTokens.radiusCard),
          child: cardContent,
        ),
      ),
    );
  }

  Widget _buildInitialsFallback(ClinicalTokens tokens) {
    return Center(
      child: Text(
        appointment.initials,
        style: tokens.chipStyle.copyWith(
          color: tokens.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
