import 'package:flutter/material.dart';
import '../../../../core/theme/clinical_tokens.dart';
import '../../data/models/doctor_dashboard_data.dart';

/// Section 6: Needs Attention
///
/// Specs:
/// - One surface card with divider-separated rows (icon, label with count, chevron).
/// - Rows: lab results to review, refill requests, unsigned visit notes, unread messages.
/// - Each row deep-links to its list.
/// - Hide any row whose count is 0; hide the whole section when all are 0.
/// - Minimum 44px touch targets.
class NeedsAttentionSection extends StatelessWidget {
  final List<NeedsAttentionItem> items;
  final ValueChanged<NeedsAttentionItem>? onItemTap;
  final Animation<double>? headerFadeAnimation;
  final Animation<double> Function(int index)? rowAnimationProvider;

  const NeedsAttentionSection({
    super.key,
    required this.items,
    this.onItemTap,
    this.headerFadeAnimation,
    this.rowAnimationProvider,
  });

  @override
  Widget build(BuildContext context) {
    // Hide any row whose count is 0; hide the whole section when all are 0.
    final activeItems = items.where((i) => i.count > 0).toList();
    if (activeItems.isEmpty) {
      return const SizedBox.shrink();
    }

    final tokens = ClinicalTokens.of(context);

    final titleWidget = Text(
      'Needs attention',
      style: tokens.sectionTitleStyle,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        if (headerFadeAnimation == null)
          titleWidget
        else
          AnimatedBuilder(
            animation: headerFadeAnimation!,
            builder: (context, child) => Opacity(
              opacity: headerFadeAnimation!.value.clamp(0.0, 1.0),
              child: child,
            ),
            child: titleWidget,
          ),
        const SizedBox(height: ClinicalTokens.sectionLabelToContent),

        // Surface card with divider-separated rows
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: tokens.surface,
            borderRadius: BorderRadius.circular(ClinicalTokens.radiusCard),
            border: Border.all(
              color: tokens.border,
              width: ClinicalTokens.borderWidth,
            ),
          ),
          child: Column(
            children: List.generate(activeItems.length, (index) {
              final item = activeItems[index];
              final isLast = index == activeItems.length - 1;

              final rowContent = Column(
                children: [
                  Semantics(
                    button: true,
                    label: item.title,
                    child: InkWell(
                      onTap: () => onItemTap?.call(item),
                      borderRadius: BorderRadius.vertical(
                        top: index == 0
                            ? const Radius.circular(ClinicalTokens.radiusCard)
                            : Radius.zero,
                        bottom: isLast
                            ? const Radius.circular(ClinicalTokens.radiusCard)
                            : Radius.zero,
                      ),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 48),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            // Outline Icon (20px)
                            Icon(
                              item.icon,
                              size: ClinicalTokens.defaultIconSize,
                              color: tokens.textSecondary,
                            ),
                            const SizedBox(width: 12),

                            // Label with count (e.g. "4 lab results to review")
                            Expanded(
                              child: Text(
                                item.title,
                                style: tokens.cardTitleStyle.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            // Chevron
                            Icon(
                              Icons.chevron_right,
                              size: ClinicalTokens.defaultIconSize,
                              color: tokens.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: ClinicalTokens.borderWidth,
                      color: tokens.border,
                      indent: 14,
                      endIndent: 14,
                    ),
                ],
              );

              if (rowAnimationProvider == null) return rowContent;

              final anim = rowAnimationProvider!(index);
              return AnimatedBuilder(
                animation: anim,
                builder: (context, child) {
                  final val = anim.value.clamp(0.0, 1.0);
                  return Transform.translate(
                    offset: Offset(0, 8.0 * (1.0 - val)),
                    child: Opacity(
                      opacity: val,
                      child: child,
                    ),
                  );
                },
                child: rowContent,
              );
            }),
          ),
        ),
      ],
    );
  }
}
