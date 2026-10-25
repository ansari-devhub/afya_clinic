import 'package:flutter/material.dart';
import '../../../../core/theme/clinical_tokens.dart';

/// Section 2: Headline
///
/// Spec:
/// - Exactly "Here is an overview of your clinical dashboard today".
/// - Same visual weight as section titles, slightly larger (15/medium).
/// - Max 2 lines.
class DashboardHeadline extends StatelessWidget {
  final Animation<double>? fadeAnimation;

  const DashboardHeadline({
    super.key,
    this.fadeAnimation,
  });

  static const String text = 'Here is an overview of your clinical dashboard today';

  @override
  Widget build(BuildContext context) {
    final tokens = ClinicalTokens.of(context);

    final textWidget = Text(
      text,
      style: tokens.headlineStyle,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );

    if (fadeAnimation == null) {
      return textWidget;
    }

    return AnimatedBuilder(
      animation: fadeAnimation!,
      builder: (context, child) {
        return Opacity(
          opacity: fadeAnimation!.value.clamp(0.0, 1.0),
          child: child,
        );
      },
      child: textWidget,
    );
  }
}
