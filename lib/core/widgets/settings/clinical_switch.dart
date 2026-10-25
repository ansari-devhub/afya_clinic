import 'package:flutter/material.dart';
import '../../theme/clinical_tokens.dart';

/// Custom clinical switch matching the spec:
/// - 34x20 dimensions
/// - ON = primary track with thumb right
/// - OFF = border-strong track with thumb left
/// - Semantic state exposed
class ClinicalSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const ClinicalSwitch({
    super.key,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = ClinicalTokens.of(context);
    final isEnabled = onChanged != null;

    return Semantics(
      toggled: value,
      enabled: isEnabled,
      child: GestureDetector(
        onTap: isEnabled ? () => onChanged!(!value) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: 34,
          height: 20,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: value ? tokens.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: value ? tokens.primary : tokens.textMuted.withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: value ? tokens.onPrimary : tokens.textMuted,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
