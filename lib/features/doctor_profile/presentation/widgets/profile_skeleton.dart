import 'package:flutter/material.dart';
import '../../../../core/theme/clinical_tokens.dart';

/// Loading skeleton matching the full-bleed shape of the Doctor Profile screen.
class ProfileSkeleton extends StatefulWidget {
  const ProfileSkeleton({super.key});

  @override
  State<ProfileSkeleton> createState() => _ProfileSkeletonState();
}

class _ProfileSkeletonState extends State<ProfileSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = ClinicalTokens.of(context);
    final topInset = MediaQuery.paddingOf(context).top;

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final shimmerOpacity = 0.35 + (_shimmerController.value * 0.40);
        final shimmerColor = tokens.border.withValues(alpha: shimmerOpacity);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full-bleed Hero header skeleton
            Container(
              width: double.infinity,
              height: 350.0 + topInset,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
            ),
            const SizedBox(height: ClinicalTokens.sectionSpacing),

            // Content below hero with 14px screen side padding
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ClinicalTokens.screenSidePadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Availability group skeleton
                  _buildGroupSkeleton(shimmerColor, 3),
                  const SizedBox(height: ClinicalTokens.sectionSpacing),

                  // Professional group skeleton
                  _buildGroupSkeleton(shimmerColor, 4),
                  const SizedBox(height: ClinicalTokens.sectionSpacing),

                  // Preferences group skeleton
                  _buildGroupSkeleton(shimmerColor, 3),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGroupSkeleton(Color color, int rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBox(90, 13, 4, color),
        const SizedBox(height: ClinicalTokens.sectionLabelToContent),
        Container(
          width: double.infinity,
          height: (rows * 48).toDouble(),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(ClinicalTokens.radiusCard),
          ),
        ),
      ],
    );
  }

  Widget _buildBox(double w, double h, double r, Color color) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(r),
      ),
    );
  }
}
