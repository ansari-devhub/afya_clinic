import 'package:flutter/material.dart';
import '../../../../core/theme/clinical_tokens.dart';
import '../../data/models/doctor_dashboard_data.dart';
import 'section_header.dart';

/// Section 4: Recent Patients
///
/// Specs:
/// - Header "Recent patients" with a "See all" link (opens the Patients tab).
/// - Horizontally scrolling row of 52px circles in accent-tint with initials (or photo),
///   name beneath in secondary 11.
/// - Tapping opens that patient's chart.
/// - Hide the section if there is no history.
class RecentPatientsSection extends StatelessWidget {
  final List<RecentPatient> patients;
  final VoidCallback? onSeeAll;
  final ValueChanged<RecentPatient>? onPatientTap;
  final Animation<double>? headerFadeAnimation;
  final Animation<double> Function(int index)? avatarAnimationProvider;

  const RecentPatientsSection({
    super.key,
    required this.patients,
    this.onSeeAll,
    this.onPatientTap,
    this.headerFadeAnimation,
    this.avatarAnimationProvider,
  });

  @override
  Widget build(BuildContext context) {
    // Hide section if there is no history
    if (patients.isEmpty) {
      return const SizedBox.shrink();
    }

    final tokens = ClinicalTokens.of(context);

    final header = SectionHeader(
      title: 'Recent patients',
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
          height: 82,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: patients.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final patient = patients[index];

              final itemWidget = Semantics(
                button: true,
                label: 'View chart for ${patient.name}',
                child: InkWell(
                  onTap: () => onPatientTap?.call(patient),
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 62,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 52px circle in accent-tint with initials
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: tokens.accentTint,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              patient.initials,
                              style: tokens.cardTitleStyle.copyWith(
                                color: tokens.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Name beneath in secondary 11
                        Text(
                          patient.name,
                          style: tokens.secondaryStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );

              if (avatarAnimationProvider == null) return itemWidget;

              final anim = avatarAnimationProvider!(index);
              return AnimatedBuilder(
                animation: anim,
                builder: (context, child) {
                  final val = anim.value.clamp(0.0, 1.0);
                  return Transform.scale(
                    scale: 0.85 + 0.15 * val,
                    child: Opacity(
                      opacity: val,
                      child: child,
                    ),
                  );
                },
                child: itemWidget,
              );
            },
          ),
        ),
      ],
    );
  }
}
