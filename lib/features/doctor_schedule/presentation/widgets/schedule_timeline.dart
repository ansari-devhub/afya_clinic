import 'package:flutter/material.dart';
import '../../../../core/theme/clinical_tokens.dart';
import '../../data/models/doctor_schedule_data.dart';
import 'timeline_appointment_card.dart';
import 'timeline_blocked_card.dart';
import 'timeline_next_patient_card.dart';
import 'timeline_now_line.dart';
import 'timeline_open_slot_card.dart';

/// Doctor Schedule Timeline component matching spec:
/// - Two columns per row: 44px time column (10 secondary, right-aligned, ~10px top offset)
///   and the content column, 8px gap, 10px between rows.
/// - Row types:
///   a) Appointment card
///   b) Completed card (60% opacity)
///   c) Next patient card (compact filled primary, exactly one, only today)
///   d) Now line (8px danger dot + 1px danger line + danger time label, only today)
///   e) Blocked/break card (dashed border)
///   f) Open slot card (dashed border, tap opens block-time sheet prefilled)
/// - Empty state: "No appointments on this day"
class ScheduleTimeline extends StatelessWidget {
  final List<TimelineRowItem> items;
  final bool isToday;
  final DateTime currentTime;
  final ValueChanged<ScheduleAppointment> onAppointmentTap;
  final ValueChanged<ScheduleAppointment> onVideoTap;
  final ValueChanged<ScheduleAppointment> onStartConsult;
  final ValueChanged<ScheduleAppointment> onViewChart;
  final ValueChanged<OpenSlot> onOpenSlotTap;

  const ScheduleTimeline({
    super.key,
    required this.items,
    required this.isToday,
    required this.currentTime,
    required this.onAppointmentTap,
    required this.onVideoTap,
    required this.onStartConsult,
    required this.onViewChart,
    required this.onOpenSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = ClinicalTokens.of(context);

    // Empty state
    if (items.isEmpty) {
      return _buildEmptyState(tokens);
    }

    // Determine the index where the Now line should be inserted
    // (chronologically between items where item.time <= currentTime and next item.time > currentTime)
    int nowLineIndex = -1;
    if (isToday) {
      final nowMinutes = currentTime.hour * 60 + currentTime.minute;
      for (int i = 0; i < items.length; i++) {
        final itemMinutes = items[i].time.hour * 60 + items[i].time.minute;
        if (itemMinutes > nowMinutes) {
          nowLineIndex = i;
          break;
        }
      }
      if (nowLineIndex == -1) {
        // Now is after all items
        nowLineIndex = items.length;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          // Render Now line if it falls right before this item
          if (isToday && nowLineIndex == i) ...[
            TimelineNowLine(currentTime: currentTime),
            const SizedBox(height: 10),
          ],

          // Render timeline row
          _buildTimelineRow(context, tokens, items[i]),
          const SizedBox(height: 10),
        ],

        // If Now line falls after the last item
        if (isToday && nowLineIndex == items.length) ...[
          TimelineNowLine(currentTime: currentTime),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildTimelineRow(
    BuildContext context,
    ClinicalTokens tokens,
    TimelineRowItem item,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 44px Time Column: 10 secondary, right-aligned, ~10px top offset
        SizedBox(
          width: 44,
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              item.timeLabel,
              textAlign: TextAlign.right,
              style: tokens.chipStyle.copyWith(
                fontSize: 10,
                color: tokens.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Content Column
        Expanded(
          child: _buildCardContent(tokens, item),
        ),
      ],
    );
  }

  Widget _buildCardContent(ClinicalTokens tokens, TimelineRowItem item) {
    switch (item.type) {
      case TimelineRowType.completed:
        return TimelineAppointmentCard(
          appointment: item.appointment!,
          isCompleted: true,
          onTap: () => onAppointmentTap(item.appointment!),
        );

      case TimelineRowType.next:
        return TimelineNextPatientCard(
          appointment: item.appointment!,
          onStartConsult: () => onStartConsult(item.appointment!),
          onViewChart: () => onViewChart(item.appointment!),
          onTap: () => onAppointmentTap(item.appointment!),
        );

      case TimelineRowType.appointment:
        return TimelineAppointmentCard(
          appointment: item.appointment!,
          isCompleted: false,
          onTap: () => onAppointmentTap(item.appointment!),
          onVideoTap: () => onVideoTap(item.appointment!),
        );

      case TimelineRowType.blocked:
        return TimelineBlockedCard(
          block: item.block!,
        );

      case TimelineRowType.openSlot:
        return TimelineOpenSlotCard(
          openSlot: item.openSlot!,
          onTap: () => onOpenSlotTap(item.openSlot!),
        );
    }
  }

  Widget _buildEmptyState(ClinicalTokens tokens) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(ClinicalTokens.radiusCard),
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
              size: 32,
              color: tokens.textMuted,
            ),
            const SizedBox(height: 10),
            Text(
              'No appointments on this day',
              style: tokens.cardTitleStyle.copyWith(
                color: tokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
