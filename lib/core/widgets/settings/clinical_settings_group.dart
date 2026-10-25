import 'package:flutter/material.dart';
import '../../theme/clinical_tokens.dart';
import 'clinical_settings_row.dart';

/// Generic settings group container matching the spec:
/// - One surface card per group, 0.5px low-contrast border, radius 12
/// - 0.5px dividers between rows
/// - Section label above card
class ClinicalSettingsGroup extends StatelessWidget {
  final String? title;
  final List<ClinicalSettingsRow> rows;

  const ClinicalSettingsGroup({
    super.key,
    this.title,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();

    final tokens = ClinicalTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: tokens.sectionTitleStyle,
          ),
          const SizedBox(height: ClinicalTokens.sectionLabelToContent),
        ],

        // Surface card with 0.5px border & radius 12
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: tokens.surface,
            borderRadius: BorderRadius.circular(ClinicalTokens.radiusCard),
            border: Border.all(
              color: tokens.border,
              width: ClinicalTokens.borderWidth,
            ),
          ),
          child: Column(
            children: List.generate(rows.length, (index) {
              final row = rows[index];
              final isLast = index == rows.length - 1;

              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: index == 0
                          ? const Radius.circular(ClinicalTokens.radiusCard)
                          : Radius.zero,
                      bottom: isLast
                          ? const Radius.circular(ClinicalTokens.radiusCard)
                          : Radius.zero,
                    ),
                    child: row,
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: ClinicalTokens.borderWidth,
                      color: tokens.border,
                      indent: 14,
                      endIndent: 14,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
