import 'package:flutter/material.dart';
import '../../../../core/theme/clinical_tokens.dart';
import '../../../../core/widgets/dashed_border_box.dart';
import '../../data/models/doctor_schedule_data.dart';

/// Blocked time or break slot card matching spec:
/// - 1px dashed border, radius 12, surface fill
/// - Icon, title, and "Blocked · start - end"
class TimelineBlockedCard extends StatelessWidget {
  final ScheduleBlock block;

  const TimelineBlockedCard({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = ClinicalTokens.of(context);

    return DashedBorderBox(
      color: tokens.border.withValues(alpha: 0.8),
      backgroundColor: tokens.surface,
      radius: ClinicalTokens.radiusCard,
      strokeWidth: 1.0,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Block icon
          Icon(
            block.icon,
            size: 20,
            color: tokens.textSecondary,
          ),
          const SizedBox(width: 10),

          // Title + "Blocked · start - end"
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  block.title,
                  style: tokens.cardTitleStyle.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Blocked · ${block.timeRangeFormatted}',
                  style: tokens.secondaryStyle.copyWith(
                    color: tokens.textSecondary,
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
