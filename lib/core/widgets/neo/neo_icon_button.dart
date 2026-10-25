import 'package:flutter/material.dart';

/// Raised square neomorphic button for social and biometric authentication.
///
/// Features:
/// - Square raised surface with rounded corners (16 dp)
/// - Top-left light highlight shadow and bottom-right dark shadow
/// - Hairline border derived from theme surface
/// - Touch interaction with ripple feedback
class NeoIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final double size;
  final String? tooltip;

  const NeoIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 54.0,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surface;
    final isDark = theme.brightness == Brightness.dark;

    final borderRadius = BorderRadius.circular(16);

    final lightShadow = isDark
        ? BoxShadow(
            color: Color.lerp(surfaceColor, Colors.white, 0.06)!,
            offset: const Offset(-2.5, -2.5),
            blurRadius: 6,
          )
        : BoxShadow(
            color: Colors.white.withValues(alpha: 0.95),
            offset: const Offset(-3, -3),
            blurRadius: 8,
          );

    final darkShadow = isDark
        ? BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            offset: const Offset(3, 4),
            blurRadius: 8,
          )
        : BoxShadow(
            color: Color.lerp(surfaceColor, Colors.black, 0.12)!.withValues(alpha: 0.4),
            offset: const Offset(3, 4),
            blurRadius: 8,
          );

    final borderColor = isDark
        ? Color.lerp(surfaceColor, Colors.white, 0.10)!
        : Colors.white.withValues(alpha: 0.9);

    final buttonBgColor = isDark
        ? Color.lerp(surfaceColor, Colors.white, 0.03)!
        : Color.lerp(surfaceColor, Colors.white, 0.60)!;

    final button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: buttonBgColor,
        borderRadius: borderRadius,
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
        boxShadow: [
          lightShadow,
          darkShadow,
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: borderRadius,
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: Center(child: icon),
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}
