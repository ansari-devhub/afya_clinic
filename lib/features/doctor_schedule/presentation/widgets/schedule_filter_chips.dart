import 'package:flutter/material.dart';
import '../../../../core/theme/clinical_tokens.dart';
import '../../data/models/doctor_schedule_data.dart';

/// Single-select filter chips matching spec:
/// - All, In person, Telehealth, Completed
/// - Pill radius 16, text 11
/// - Selected = primary fill with on-primary text
/// - Horizontally scrollable
class ScheduleFilterChips extends StatelessWidget {
  final ScheduleFilter selectedFilter;
  final ValueChanged<ScheduleFilter> onFilterSelected;

  const ScheduleFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = ClinicalTokens.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: ScheduleFilter.values.map((filter) {
          final isSelected = filter == selectedFilter;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Semantics(
              button: true,
              selected: isSelected,
              label: '${filter.label} filter',
              child: InkWell(
                onTap: () => onFilterSelected(filter),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  constraints: const BoxConstraints(minHeight: 32),
                  decoration: BoxDecoration(
                    color: isSelected ? tokens.primary : tokens.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected
                        ? null
                        : Border.all(
                            color: tokens.border,
                            width: ClinicalTokens.borderWidth,
                          ),
                  ),
                  child: Center(
                    child: Text(
                      filter.label,
                      style: tokens.secondaryStyle.copyWith(
                        color: isSelected ? tokens.onPrimary : tokens.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
