import 'package:flutter/material.dart';

/// Raised neomorphic card component.
///
/// Features:
/// - Rounded corners (16-20 dp)
/// - Soft light highlight shadow on top-left
/// - Soft dark shadow on bottom-right
/// - Hairline highlight border
/// - Colors derived from [ThemeData.colorScheme.surface] to support light and dark modes
class NeoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;

  const NeoCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surface;
    final isDark = theme.brightness == Brightness.dark;

    final effectiveRadius = borderRadius ?? BorderRadius.circular(18);

    // Derive light and dark shadows from the surface color
    final lightShadow = isDark
        ? BoxShadow(
            color: Color.lerp(surfaceColor, Colors.white, 0.06)!,
            offset: const Offset(-3, -3),
            blurRadius: 8,
          )
        : BoxShadow(
            color: Colors.white.withValues(alpha: 0.95),
            offset: const Offset(-4, -4),
            blurRadius: 10,
          );

    final darkShadow = isDark
        ? BoxShadow(
            color: Colors.black.withValues(alpha: 0.50),
            offset: const Offset(4, 4),
            blurRadius: 12,
          )
        : BoxShadow(
            color: Color.lerp(surfaceColor, Colors.black, 0.14)!.withValues(alpha: 0.45),
            offset: const Offset(4, 5),
            blurRadius: 12,
          );

    final borderColor = isDark
        ? Color.lerp(surfaceColor, Colors.white, 0.12)!
        : Colors.white.withValues(alpha: 0.85);

    final cardBgColor = isDark
        ? Color.lerp(surfaceColor, Colors.white, 0.04)!
        : Color.lerp(surfaceColor, Colors.white, 0.50)!;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: effectiveRadius,
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
        boxShadow: [
          lightShadow,
          darkShadow,
        ],
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}
