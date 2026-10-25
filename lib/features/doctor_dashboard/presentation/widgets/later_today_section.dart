import 'package:flutter/material.dart';
import '../../../../core/theme/clinical_tokens.dart';
import '../../data/models/doctor_dashboard_data.dart';
import 'section_header.dart';

/// Section 5: Later Today
///
/// Specs:
/// - Header with "See all" (opens the Schedule tab).
/// - Horizontally scrolling cards, each 176px wide, surface background, 0.5px border,
///   radius 12, padding 10:
///   - 84px image area (patient photo; icon fallback)
///   - patient name (13 medium)
///   - "visit type · mode" (11 secondary)
///   - a clock icon with the time
///   - optional status chip on the right of the time row ("Checked in" in success style)
///   - optional pill button "View chart" in primary on the card whose visit is next.
/// - Exclude the patient already shown in the Next patient card.
class LaterTodaySection extends StatelessWidget {
  final List<LaterAppointment> appointments;
  final VoidCallback? onSeeAll;
  final ValueChanged<LaterAppointment>? onAppointmentTap;
  final ValueChanged<LaterAppointment>? onViewChart;
  final Animation<double>? headerFadeAnimation;
  final Animation<double> Function(int index)? cardAnimationProvider;

  const LaterTodaySection({
    super.key,
    required this.appointments,
    this.onSeeAll,
    this.onAppointmentTap,
    this.onViewChart,
    this.headerFadeAnimation,
    this.cardAnimationProvider,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return const SizedBox.shrink();
    }

    final tokens = ClinicalTokens.of(context);

    // Height calculated to comfortably house the 84px image, info rows, and optional "View chart" pill button.
    final hasNextVisitButton = appointments.any((a) => a.isNextVisit);
    final cardHeight = hasNextVisitButton ? 218.0 : 184.0;

    final header = SectionHeader(
      title: 'Later today',
      onSeeAll: onSeeAll,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (headerFadeAnimation == null)
          header
        else
          AnimatedBuilder(
            animation: headerFadeAnimation!,
            builder: (context, child) => Opacity(
              opacity: headerFadeAnimation!.value.clamp(0.0, 1.0),
              child: child,
            ),
            child: header,
          ),
        const SizedBox(height: ClinicalTokens.sectionLabelToContent),
        SizedBox(
          height: cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: appointments.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = appointments[index];
              final cardWidget = _buildCard(context, tokens, item);

              if (cardAnimationProvider == null) return cardWidget;

              final anim = cardAnimationProvider!(index);
              return AnimatedBuilder(
                animation: anim,
                builder: (context, child) {
                  final val = anim.value.clamp(0.0, 1.0);
                  return Transform.translate(
                    offset: Offset(24.0 * (1.0 - val), 0),
                    child: Opacity(
                      opacity: val,
                      child: child,
                    ),
                  );
                },
                child: cardWidget,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context,
    ClinicalTokens tokens,
    LaterAppointment item,
  ) {
    return Container(
      width: 176,
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(ClinicalTokens.radiusCard),
        border: Border.all(
          color: tokens.border,
          width: ClinicalTokens.borderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 84px Image area (photo or icon fallback)
          Container(
            height: 84,
            width: double.infinity,
            decoration: BoxDecoration(
              color: tokens.accentTint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                item.mode.contains('telehealth')
                    ? Icons.videocam_outlined
                    : Icons.person_outline_rounded,
                size: 32,
                color: tokens.primary.withValues(alpha: 0.70),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Patient name (13 medium)
          Text(
            item.patientName,
            style: tokens.sectionTitleStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          // Visit type · mode (11 secondary)
          Text(
            item.subtitle,
            style: tokens.secondaryStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),

          // Clock icon + Time row + Optional "Checked in" status chip
          Row(
            children: [
              Icon(
                Icons.access_time_outlined,
                size: 14,
                color: tokens.textSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item.time,
                  style: tokens.secondaryStyle.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (item.isCheckedIn)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: tokens.successContainer,
                    borderRadius: BorderRadius.circular(ClinicalTokens.radiusChip),
                  ),
                  child: Text(
                    'Checked in',
                    style: tokens.chipStyle.copyWith(
                      color: tokens.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          // Optional pill button "View chart" in primary on the card whose visit is next
          if (item.isNextVisit) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 32,
              child: ElevatedButton(
                onPressed: () => onViewChart?.call(item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.primary,
                  foregroundColor: tokens.onPrimary,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ClinicalTokens.radiusPill),
                  ),
                ),
                child: Text(
                  'View chart',
                  style: tokens.chipStyle.copyWith(
                    color: tokens.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
