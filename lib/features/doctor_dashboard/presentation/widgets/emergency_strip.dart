import 'package:flutter/material.dart';
import '../../../../core/theme/clinical_tokens.dart';

/// Section 7: Emergency Strip
///
/// Specs:
/// - Section label "Emergency".
/// - Single row, danger-tint background with a danger-colored border,
///   alert icon, text "Emergency alerts and on-call", chevron.
/// - It stays visually distinct from every other element; do not restyle it as a normal list row.
/// - Minimum 44px touch target.
class EmergencyStrip extends StatelessWidget {
  final VoidCallback? onTap;
  final String text;

  const EmergencyStrip({
    super.key,
    this.onTap,
    this.text = 'Emergency alerts and on-call',
  });

  @override
  Widget build(BuildContext context) {
    final tokens = ClinicalTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Text(
          'Emergency',
          style: tokens.sectionTitleStyle,
        ),
        const SizedBox(height: ClinicalTokens.sectionLabelToContent),

        // Distinct emergency strip
        Semantics(
          button: true,
          label: text,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(ClinicalTokens.radiusCard),
              child: Container(
                constraints: const BoxConstraints(minHeight: 48),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: tokens.dangerContainer,
                  borderRadius: BorderRadius.circular(ClinicalTokens.radiusCard),
                  border: Border.all(
                    color: tokens.danger.withValues(alpha: 0.60),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    // Danger Alert Icon
                    Icon(
                      Icons.error_outline_rounded,
                      size: ClinicalTokens.defaultIconSize,
                      color: tokens.danger,
                    ),
                    const SizedBox(width: 12),

                    // Label
                    Expanded(
                      child: Text(
                        text,
                        style: tokens.cardTitleStyle.copyWith(
                          color: tokens.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Danger Chevron
                    Icon(
                      Icons.chevron_right,
                      size: ClinicalTokens.defaultIconSize,
                      color: tokens.danger,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
