import 'package:flutter/material.dart';
import '../../../../core/theme/clinical_tokens.dart';
import '../../data/models/doctor_schedule_data.dart';

/// Date Navigation component matching spec:
/// - Month label with down chevron opens full month calendar sheet
/// - Day | Week segmented control on the right (Day default; selected segment primary fill)
/// - Below it: week strip of 40px-wide chips, radius 12:
///   weekday letter (10 secondary) over date (14 medium),
///   plus a 4px dot when the day has appointments.
/// - Selected day = primary fill with on-primary text.
/// - Swiping changes week; selecting a date reloads the timeline.
class ScheduleDateNav extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime currentWeekStart;
  final ScheduleViewMode viewMode;
  final Set<int> appointmentDays;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<ScheduleViewMode> onViewModeChanged;
  final VoidCallback onMonthTap;
  final ValueChanged<bool> onSwipeWeek; // true for next week, false for previous

  const ScheduleDateNav({
    super.key,
    required this.selectedDate,
    required this.currentWeekStart,
    required this.viewMode,
    required this.appointmentDays,
    required this.onDateSelected,
    required this.onViewModeChanged,
    required this.onMonthTap,
    required this.onSwipeWeek,
  });

  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  static const List<String> _weekdayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final tokens = ClinicalTokens.of(context);
    final monthName = _months[selectedDate.month - 1];
    final monthYearText = '$monthName ${selectedDate.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: Month dropdown button + Day | Week segmented control
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Month label with down chevron
            Semantics(
              button: true,
              label: 'Select month and year',
              child: InkWell(
                onTap: onMonthTap,
                borderRadius: BorderRadius.circular(ClinicalTokens.radiusTile),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        monthYearText,
                        style: tokens.cardTitleStyle.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: tokens.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Day | Week segmented control
            _buildSegmentedControl(tokens),
          ],
        ),
        const SizedBox(height: 12),

        // Week strip: 7 chips for current week with swipe gesture detection
        GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null) {
              if (details.primaryVelocity! < -200) {
                // Swiped left -> next week
                onSwipeWeek(true);
              } else if (details.primaryVelocity! > 200) {
                // Swiped right -> previous week
                onSwipeWeek(false);
              }
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dayDate = currentWeekStart.add(Duration(days: index));
              final isSelected = dayDate.year == selectedDate.year &&
                  dayDate.month == selectedDate.month &&
                  dayDate.day == selectedDate.day;
              final hasAppointments = appointmentDays.contains(dayDate.day);
              final weekdayLetter = _weekdayLetters[index];

              return _buildDayChip(
                tokens: tokens,
                date: dayDate,
                weekdayLetter: weekdayLetter,
                isSelected: isSelected,
                hasAppointments: hasAppointments,
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedControl(ClinicalTokens tokens) {
    return Container(
      height: 32,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(ClinicalTokens.radiusPill),
        border: Border.all(
          color: tokens.border,
          width: ClinicalTokens.borderWidth,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSegmentButton(
            tokens: tokens,
            label: 'Day',
            isSelected: viewMode == ScheduleViewMode.day,
            onTap: () => onViewModeChanged(ScheduleViewMode.day),
          ),
          _buildSegmentButton(
            tokens: tokens,
            label: 'Week',
            isSelected: viewMode == ScheduleViewMode.week,
            onTap: () => onViewModeChanged(ScheduleViewMode.week),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required ClinicalTokens tokens,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: '$label view',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ClinicalTokens.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? tokens.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(ClinicalTokens.radiusPill),
          ),
          child: Center(
            child: Text(
              label,
              style: tokens.chipStyle.copyWith(
                color: isSelected ? tokens.onPrimary : tokens.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayChip({
    required ClinicalTokens tokens,
    required DateTime date,
    required String weekdayLetter,
    required bool isSelected,
    required bool hasAppointments,
  }) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: '${date.day} $weekdayLetter, ${hasAppointments ? "has appointments" : "no appointments"}',
      child: InkWell(
        onTap: () => onDateSelected(date),
        borderRadius: BorderRadius.circular(ClinicalTokens.radiusCard),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 40,
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? tokens.primary : tokens.surface,
            borderRadius: BorderRadius.circular(ClinicalTokens.radiusCard),
            border: isSelected
                ? null
                : Border.all(
                    color: tokens.border,
                    width: ClinicalTokens.borderWidth,
                  ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: tokens.primary.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Weekday letter (10 secondary / onPrimary)
              Text(
                weekdayLetter,
                style: tokens.chipStyle.copyWith(
                  color: isSelected
                      ? tokens.onPrimary.withValues(alpha: 0.85)
                      : tokens.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),

              // Date number (14 medium)
              Text(
                '${date.day}',
                style: tokens.cardTitleStyle.copyWith(
                  color: isSelected ? tokens.onPrimary : tokens.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),

              // 4px dot when day has appointments
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasAppointments
                      ? (isSelected ? tokens.onPrimary : tokens.primary)
                      : Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
