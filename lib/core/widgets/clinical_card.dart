import 'package:flutter/material.dart';
import '../theme/clinical_tokens.dart';

/// Reusable Clinical Card with 12px radius, surface background, and 0.5px low-contrast border.
class ClinicalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double radius;
  final Border? border;
  final VoidCallback? onTap;

  const ClinicalCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12.0),
    this.color,
    this.radius = ClinicalTokens.radiusCard,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = ClinicalTokens.of(context);
    final cardBorder = border ??
        Border.all(
          color: tokens.border,
          width: ClinicalTokens.borderWidth,
        );

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? tokens.surface,
        borderRadius: BorderRadius.circular(radius),
        border: cardBorder,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: content,
        ),
      );
    }

    return content;
  }
}
