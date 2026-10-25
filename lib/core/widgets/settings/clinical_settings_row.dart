import 'package:flutter/material.dart';
import '../../theme/clinical_tokens.dart';
import 'clinical_switch.dart';

/// Trailing type for [ClinicalSettingsRow].
enum ClinicalTrailingType {
  chevron,
  valueWithChevron,
  customSwitch,
}

/// Generic settings row matching the clinical spec:
/// - 20px outline icon
/// - 13 medium label
/// - Optional 11 secondary subtitle (second line)
/// - Exactly ONE trailing element: chevron, value + chevron, or switch (never mixed)
/// - Full row is the tap target, minimum 44px height
/// - Switch rows toggle on full row tap
class ClinicalSettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final ClinicalTrailingType trailingType;
  final String? valueText;
  final bool switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? labelColor;

  const ClinicalSettingsRow({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailingType = ClinicalTrailingType.chevron,
    this.valueText,
    this.switchValue = false,
    this.onSwitchChanged,
    this.onTap,
    this.iconColor,
    this.labelColor,
  });

  /// Factory constructor for a standard chevron row
  factory ClinicalSettingsRow.chevron({
    Key? key,
    required IconData icon,
    required String label,
    String? subtitle,
    VoidCallback? onTap,
    Color? iconColor,
    Color? labelColor,
  }) {
    return ClinicalSettingsRow(
      key: key,
      icon: icon,
      label: label,
      subtitle: subtitle,
      trailingType: ClinicalTrailingType.chevron,
      onTap: onTap,
      iconColor: iconColor,
      labelColor: labelColor,
    );
  }

  /// Factory constructor for a value + chevron row (e.g. "Language  English >")
  factory ClinicalSettingsRow.value({
    Key? key,
    required IconData icon,
    required String label,
    required String valueText,
    String? subtitle,
    VoidCallback? onTap,
    Color? iconColor,
    Color? labelColor,
  }) {
    return ClinicalSettingsRow(
      key: key,
      icon: icon,
      label: label,
      subtitle: subtitle,
      trailingType: ClinicalTrailingType.valueWithChevron,
      valueText: valueText,
      onTap: onTap,
      iconColor: iconColor,
      labelColor: labelColor,
    );
  }

  /// Factory constructor for a switch row
  factory ClinicalSettingsRow.customSwitch({
    Key? key,
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? subtitle,
    Color? iconColor,
    Color? labelColor,
  }) {
    return ClinicalSettingsRow(
      key: key,
      icon: icon,
      label: label,
      subtitle: subtitle,
      trailingType: ClinicalTrailingType.customSwitch,
      switchValue: value,
      onSwitchChanged: onChanged,
      onTap: () => onChanged(!value),
      iconColor: iconColor,
      labelColor: labelColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = ClinicalTokens.of(context);

    final rowTap = trailingType == ClinicalTrailingType.customSwitch
        ? () => onSwitchChanged?.call(!switchValue)
        : onTap;

    return Semantics(
      button: trailingType != ClinicalTrailingType.customSwitch,
      label: subtitle != null ? '$label, $subtitle' : label,
      value: trailingType == ClinicalTrailingType.valueWithChevron
          ? valueText
          : null,
      child: InkWell(
        onTap: rowTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 46),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // 20px outline icon
              Icon(
                icon,
                size: ClinicalTokens.defaultIconSize,
                color: iconColor ?? tokens.textSecondary,
              ),
              const SizedBox(width: 12),

              // 13 medium label with optional 11 secondary subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: tokens.rowLabelStyle.copyWith(
                        color: labelColor ?? tokens.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: tokens.secondaryStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Exactly ONE trailing element
              const SizedBox(width: 8),
              _buildTrailing(tokens),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrailing(ClinicalTokens tokens) {
    switch (trailingType) {
      case ClinicalTrailingType.chevron:
        return Icon(
          Icons.chevron_right,
          size: ClinicalTokens.defaultIconSize,
          color: tokens.textMuted,
        );

      case ClinicalTrailingType.valueWithChevron:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (valueText != null)
              Text(
                valueText!,
                style: tokens.secondaryStyle.copyWith(
                  color: tokens.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              size: ClinicalTokens.defaultIconSize,
              color: tokens.textMuted,
            ),
          ],
        );

      case ClinicalTrailingType.customSwitch:
        return ClinicalSwitch(
          value: switchValue,
          onChanged: onSwitchChanged,
        );
    }
  }
}
