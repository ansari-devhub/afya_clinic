import 'package:flutter/material.dart';
import '../../../../core/theme/clinical_tokens.dart';

/// Now line matching spec:
/// - 8px danger dot plus a 1px danger line
/// - Time label in danger (10 medium, e.g. "10:15")
/// - Only shown when viewing today; updates every minute
class TimelineNowLine extends StatelessWidget {
  final DateTime currentTime;

  const TimelineNowLine({
    super.key,
    required this.currentTime,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = ClinicalTokens.of(context);

    final hour = currentTime.hour;
    final minute = currentTime.minute.toString().padLeft(2, '0');
    final formattedTime = '$hour:$minute';

    return SizedBox(
      height: 18,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 44px Time Column (10 medium, danger, right-aligned)
          SizedBox(
            width: 44,
            child: Text(
              formattedTime,
              textAlign: TextAlign.right,
              style: tokens.chipStyle.copyWith(
                fontSize: 10,
                color: tokens.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Content Column: 8px danger dot + 1px danger line
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 8px danger dot
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tokens.danger,
                  ),
                ),

                // 1px danger line extending across the column
                Expanded(
                  child: Container(
                    height: 1,
                    color: tokens.danger,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
