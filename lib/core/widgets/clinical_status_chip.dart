import 'package:flutter/material.dart';
import '../theme/clinical_tokens.dart';

/// Clinical appointment status enum matching the specification:
/// - Upcoming: accent tint
/// - Checked in: success tint
/// - Completed: success tint
/// - Cancelled: danger tint
/// - No-show: danger tint
enum ClinicalAppointmentStatus {
  upcoming,
  checkedIn,
  completed,
  cancelled,
  noShow,
}

extension ClinicalAppointmentStatusX on ClinicalAppointmentStatus {
  String get label {
    switch (this) {
      case ClinicalAppointmentStatus.upcoming:
        return 'Upcoming';
      case ClinicalAppointmentStatus.checkedIn:
        return 'Checked in';
      case ClinicalAppointmentStatus.completed:
        return 'Completed';
      case ClinicalAppointmentStatus.cancelled:
        return 'Cancelled';
      case ClinicalAppointmentStatus.noShow:
        return 'No-show';
    }
  }
}

/// Generic status chip matching the clinical design system:
/// - Upcoming (accent tint)
/// - Checked in (success tint)
/// - Completed (success tint)
/// - Cancelled and No-show (danger tint)
class ClinicalStatusChip extends StatelessWidget {
  final ClinicalAppointmentStatus status;
  final String? customLabel;

  const ClinicalStatusChip({
    super.key,
    required this.status,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = ClinicalTokens.of(context);

    Color bgColor;
    Color textColor;

    switch (status) {
      case ClinicalAppointmentStatus.upcoming:
        bgColor = tokens.accentTint;
        textColor = tokens.primary;
        break;
      case ClinicalAppointmentStatus.checkedIn:
      case ClinicalAppointmentStatus.completed:
        bgColor = tokens.successContainer;
        textColor = tokens.success;
        break;
      case ClinicalAppointmentStatus.cancelled:
      case ClinicalAppointmentStatus.noShow:
        bgColor = tokens.dangerContainer;
        textColor = tokens.danger;
        break;
    }

    final displayText = customLabel ?? status.label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(ClinicalTokens.radiusChip),
      ),
      child: Text(
        displayText,
        style: tokens.chipStyle.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
