import 'package:flutter/material.dart';
import '../../../../core/theme/clinical_tokens.dart';
import '../../data/models/doctor_schedule_data.dart';

/// Summary row matching spec:
/// - Left: "Today · N appointments" (13 medium, shows the date when not today)
/// - Right: "N telehealth" (11 secondary)
class ScheduleSummaryRow extends StatelessWidget {
  final DayScheduleSummary summary;

  const ScheduleSummaryRow({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = ClinicalTokens.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: "Today · N appointments" (13 medium)
        Text(
          summary.getFormattedTitle(),
          style: tokens.sectionTitleStyle.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),

        // Right: "N telehealth" (11 secondary)
        Text(
          summary.formattedTelehealth,
          style: tokens.secondaryStyle.copyWith(
            color: tokens.textSecondary,
          ),
        ),
      ],
    );
  }
}
