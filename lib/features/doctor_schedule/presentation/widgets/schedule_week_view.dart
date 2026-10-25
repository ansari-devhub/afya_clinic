import 'package:flutter/material.dart';
import '../../../../core/theme/clinical_tokens.dart';
import '../../data/models/doctor_schedule_data.dart';
import 'timeline_appointment_card.dart';
import 'timeline_blocked_card.dart';
import 'timeline_open_slot_card.dart';

/// Week view matching spec:
/// "Week view: the same cards grouped under day headers, kept simple."
class ScheduleWeekView extends StatelessWidget {
  final DateTime weekStart;
  final Map<DateTime, List<TimelineRowItem>> weekItemsByDay;
  final ValueChanged<ScheduleAppointment> onAppointmentTap;
  final ValueChanged<ScheduleAppointment> onVideoTap;
  final ValueChanged<OpenSlot> onOpenSlotTap;

  const ScheduleWeekView({
    super.key,
    required this.weekStart,
    required this.weekItemsByDay,
    required this.onAppointmentTap,
    required this.onVideoTap,
    required this.onOpenSlotTap,
  });

  static const List<String> _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = ClinicalTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(7, (index) {
        final dayDate = DateTime(
          weekStart.year,
          weekStart.month,
          weekStart.day + index,
        );
        final dayKey = DateTime(dayDate.year, dayDate.month, dayDate.day);
        final dayItems = weekItemsByDay[dayKey] ?? [];

        final weekdayName = _weekdays[dayDate.weekday - 1];
        final monthName = _months[dayDate.month - 1];
        final headerText = '$weekdayName, $monthName ${dayDate.day}';

        return Padding(
          padding: const EdgeInsets.only(bottom: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day Header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  headerText,
                  style: tokens.sectionTitleStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Items under day header
              if (dayItems.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: tokens.surface,
                    borderRadius: BorderRadius.circular(ClinicalTokens.radiusCard),
                    border: Border.all(
                      color: tokens.border,
                      width: ClinicalTokens.borderWidth,
                    ),
                  ),
                  child: Text(
                    'No appointments scheduled',
                    style: tokens.secondaryStyle.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                )
              else
                Column(
                  children: dayItems.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 44px time column
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

                          // Content card
                          Expanded(
                            child: _buildCard(item),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCard(TimelineRowItem item) {
    switch (item.type) {
      case TimelineRowType.completed:
        return TimelineAppointmentCard(
          appointment: item.appointment!,
          isCompleted: true,
          onTap: () => onAppointmentTap(item.appointment!),
        );

      case TimelineRowType.next:
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
}
