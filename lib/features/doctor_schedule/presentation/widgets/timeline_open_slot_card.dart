import 'package:flutter/material.dart';
import '../../../../core/theme/clinical_tokens.dart';
import '../../../../core/widgets/dashed_border_box.dart';
import '../../data/models/doctor_schedule_data.dart';

/// Open slot card matching spec:
/// - 1px dashed border, radius 12, surface fill
/// - Plus icon in primary
/// - "Open slot" in primary (13 medium)
/// - "start - end · tap to block" (11 secondary)
/// - Tap opens the block-time sheet prefilled with that range
class TimelineOpenSlotCard extends StatelessWidget {
  final OpenSlot openSlot;
  final VoidCallback onTap;

  const TimelineOpenSlotCard({
    super.key,
    required this.openSlot,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = ClinicalTokens.of(context);

    return Semantics(
      button: true,
      label: 'Open slot ${openSlot.timeRangeFormatted}, tap to block',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ClinicalTokens.radiusCard),
        child: DashedBorderBox(
          color: tokens.primary.withValues(alpha: 0.6),
          backgroundColor: tokens.surface,
          radius: ClinicalTokens.radiusCard,
          strokeWidth: 1.0,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Plus icon in primary
              Icon(
                Icons.add_circle_outline_rounded,
                size: 20,
                color: tokens.primary,
              ),
              const SizedBox(width: 10),

              // "Open slot" + "start - end · tap to block"
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Open slot',
                      style: tokens.cardTitleStyle.copyWith(
                        fontSize: 13,
                        color: tokens.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${openSlot.timeRangeFormatted} · tap to block',
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
        ),
      ),
    );
  }
}
