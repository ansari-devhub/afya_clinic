import 'package:flutter/material.dart';

/// Primary neomorphic pill button widget.
///
/// Features:
/// - Pill shape (stadium border)
/// - Gradient built from theme [ColorScheme.primary] and [ColorScheme.primaryContainer]
/// - Soft glow shadow
/// - Centered label with circular trailing arrow icon
/// - Loading state with spinner
class NeoButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;
  final Widget? trailingIcon;
  final bool showArrow;

  const NeoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.height = 52.0,
    this.trailingIcon,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final primaryColor = colorScheme.primary;
    final primaryContainer = colorScheme.primaryContainer;
    final onPrimaryColor = colorScheme.onPrimary;

    final isEnabled = onPressed != null && !isLoading;

    final gradientColors = isEnabled
        ? [
            primaryContainer,
            primaryColor,
          ]
        : [
            primaryColor.withValues(alpha: 0.4),
            primaryContainer.withValues(alpha: 0.4),
          ];

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(height / 2),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(onPrimaryColor),
                      ),
                    )
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        // Centered Label
                        Text(
                          label,
                          style: (textTheme.titleMedium ?? const TextStyle()).copyWith(
                            color: isEnabled
                                ? onPrimaryColor
                                : onPrimaryColor.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),

                        // Trailing Circular Arrow Icon on the right
                        if (showArrow)
                          Align(
                            alignment: Alignment.centerRight,
                            child: trailingIcon ??
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: onPrimaryColor.withValues(alpha: 0.20),
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 16,
                                    color: onPrimaryColor,
                                  ),
                                ),
                          ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
