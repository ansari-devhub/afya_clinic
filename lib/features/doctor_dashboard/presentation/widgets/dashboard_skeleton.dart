import 'package:flutter/material.dart';
import '../../../../core/theme/clinical_tokens.dart';

/// Loading state skeleton matching the shape of each section in the Doctor Dashboard.
class DashboardSkeleton extends StatefulWidget {
  const DashboardSkeleton({super.key});

  @override
  State<DashboardSkeleton> createState() => _DashboardSkeletonState();
}

class _DashboardSkeletonState extends State<DashboardSkeleton>
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

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final shimmerOpacity = 0.35 + (_shimmerController.value * 0.40);
        final shimmerColor = tokens.border.withValues(alpha: shimmerOpacity);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top bar skeleton
            Row(
              children: [
                _buildBox(34, 34, ClinicalTokens.radiusTile, shimmerColor),
                const SizedBox(width: ClinicalTokens.rowGap),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBox(80, 12, 4, shimmerColor),
                    const SizedBox(height: 6),
                    _buildBox(120, 14, 4, shimmerColor),
                  ],
                ),
                const Spacer(),
                _buildBox(36, 36, 18, shimmerColor),
              ],
            ),
            const SizedBox(height: ClinicalTokens.sectionSpacing),

            // 2. Headline skeleton
            _buildBox(double.infinity, 15, 4, shimmerColor),
            const SizedBox(height: 6),
            _buildBox(200, 15, 4, shimmerColor),
            const SizedBox(height: ClinicalTokens.sectionSpacing),

            // 3. Next patient card skeleton
            _buildBox(90, 13, 4, shimmerColor),
            const SizedBox(height: ClinicalTokens.sectionLabelToContent),
            _buildBox(
              double.infinity,
              164,
              ClinicalTokens.radiusNextPatient,
              shimmerColor,
            ),
            const SizedBox(height: ClinicalTokens.sectionSpacing),

            // 4. Recent patients skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBox(110, 13, 4, shimmerColor),
                _buildBox(44, 11, 4, shimmerColor),
              ],
            ),
            const SizedBox(height: ClinicalTokens.sectionLabelToContent),
            Row(
              children: List.generate(
                5,
                (i) => Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Column(
                    children: [
                      _buildBox(52, 52, 26, shimmerColor),
                      const SizedBox(height: 6),
                      _buildBox(44, 10, 3, shimmerColor),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: ClinicalTokens.sectionSpacing),

            // 5. Later today skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBox(80, 13, 4, shimmerColor),
                _buildBox(44, 11, 4, shimmerColor),
              ],
            ),
            const SizedBox(height: ClinicalTokens.sectionLabelToContent),
            Row(
              children: [
                _buildBox(176, 184, ClinicalTokens.radiusCard, shimmerColor),
                const SizedBox(width: 12),
                _buildBox(176, 184, ClinicalTokens.radiusCard, shimmerColor),
              ],
            ),
            const SizedBox(height: ClinicalTokens.sectionSpacing),

            // 6. Needs attention skeleton
            _buildBox(110, 13, 4, shimmerColor),
            const SizedBox(height: ClinicalTokens.sectionLabelToContent),
            _buildBox(
              double.infinity,
              180,
              ClinicalTokens.radiusCard,
              shimmerColor,
            ),
            const SizedBox(height: ClinicalTokens.sectionSpacing),

            // 7. Emergency skeleton
            _buildBox(80, 13, 4, shimmerColor),
            const SizedBox(height: ClinicalTokens.sectionLabelToContent),
            _buildBox(
              double.infinity,
              48,
              ClinicalTokens.radiusCard,
              shimmerColor,
            ),
          ],
        );
      },
    );
  }

  Widget _buildBox(double w, double h, double radius, Color color) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
