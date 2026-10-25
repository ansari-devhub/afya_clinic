import 'package:flutter/material.dart';
import '../../../../core/theme/clinical_tokens.dart';

/// Title bar for Doctor Schedule screen matching spec:
/// - "Schedule" (15 medium) left
/// - "Today" outlined pill (primary text and border) jumps to the current date
/// - 32px bordered square button (calendar-off icon) opens the block-time sheet
/// - No back button, no logo
/// - Touch targets minimum 44px
class ScheduleTitleBar extends StatelessWidget {
  final VoidCallback onTodayTap;
  final VoidCallback onBlockTimeTap;

  const ScheduleTitleBar({
    super.key,
    required this.onTodayTap,
    required this.onBlockTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = ClinicalTokens.of(context);

    return SizedBox(
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // "Schedule" title (15 medium)
          Text(
            'Schedule',
            style: tokens.headlineStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          // Actions: [Today] outlined pill + [Block Time] 32px bordered square button
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // "Today" outlined pill button
              Semantics(
                button: true,
                label: 'Jump to today',
                child: SizedBox(
                  height: 32,
                  child: OutlinedButton(
                    onPressed: onTodayTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: tokens.primary,
                      side: BorderSide(color: tokens.primary, width: 1.0),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ClinicalTokens.radiusPill),
                      ),
                      minimumSize: const Size(44, 32),
                    ),
                    child: Text(
                      'Today',
                      style: tokens.secondaryStyle.copyWith(
                        color: tokens.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 32px bordered square button with calendar-off icon
              Semantics(
                button: true,
                label: 'Block time',
                child: InkWell(
                  onTap: onBlockTimeTap,
                  borderRadius: BorderRadius.circular(ClinicalTokens.radiusTile),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: tokens.surface,
                      borderRadius: BorderRadius.circular(ClinicalTokens.radiusTile),
                      border: Border.all(
                        color: tokens.border,
                        width: ClinicalTokens.borderWidth,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.event_busy_outlined,
                        size: 18,
                        color: tokens.textPrimary,
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
}
