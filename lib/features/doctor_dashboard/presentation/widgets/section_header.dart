import 'package:flutter/material.dart';
import '../../../../core/theme/clinical_tokens.dart';

/// Section header with title and optional "See all" action link.
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  final String actionLabel;

  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
    this.actionLabel = 'See all',
  });

  @override
  Widget build(BuildContext context) {
    final tokens = ClinicalTokens.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: tokens.sectionTitleStyle,
        ),
        if (onSeeAll != null)
          Semantics(
            button: true,
            label: '$actionLabel $title',
            child: InkWell(
              onTap: onSeeAll,
              borderRadius: BorderRadius.circular(4),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 32,
                  minWidth: 44,
                ),
                child: Center(
                  child: Text(
                    actionLabel,
                    style: tokens.secondaryStyle.copyWith(
                      color: tokens.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
