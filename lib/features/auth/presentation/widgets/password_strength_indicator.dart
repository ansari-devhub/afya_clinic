import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';

enum PasswordStrength { none, weak, okay, strong }

/// Visual password strength indicator using theme-derived status colors.
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  PasswordStrength get strength {
    if (password.isEmpty) return PasswordStrength.none;
    if (password.length < 8) return PasswordStrength.weak;

    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    if (score <= 1) return PasswordStrength.weak;
    if (score <= 3) return PasswordStrength.okay;
    return PasswordStrength.strong;
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final currentStrength = strength;

    final Color statusColor;
    final String label;
    final int activeSegments;

    switch (currentStrength) {
      case PasswordStrength.none:
        statusColor = colorScheme.outline;
        label = '';
        activeSegments = 0;
        break;
      case PasswordStrength.weak:
        statusColor = colorScheme.error;
        label = 'Weak';
        activeSegments = 1;
        break;
      case PasswordStrength.okay:
        statusColor = AppTheme.statusPending;
        label = 'Okay';
        activeSegments = 2;
        break;
      case PasswordStrength.strong:
        statusColor = colorScheme.secondary;
        label = 'Strong';
        activeSegments = 3;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
      child: Row(
        children: [
          // 3-segment strength bar
          Expanded(
            child: Row(
              children: List.generate(3, (index) {
                final isFilled = index < activeSegments;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: index < 2 ? 6 : 0),
                    decoration: BoxDecoration(
                      color: isFilled
                          ? statusColor
                          : colorScheme.outlineVariant.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 12),

          // Label
          Text(
            label,
            style: (textTheme.bodySmall ?? const TextStyle()).copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
