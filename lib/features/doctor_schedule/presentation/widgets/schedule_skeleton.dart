import 'package:flutter/material.dart';
import '../../../../core/theme/clinical_tokens.dart';

/// Loading skeleton for the Doctor Schedule screen matching the timeline structure.
class ScheduleSkeleton extends StatefulWidget {
  const ScheduleSkeleton({super.key});

  @override
  State<ScheduleSkeleton> createState() => _ScheduleSkeletonState();
}

class _ScheduleSkeletonState extends State<ScheduleSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = ClinicalTokens.of(context);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final shimmerColor = Color.lerp(
          tokens.surface,
          tokens.border.withValues(alpha: 0.3),
          _animation.value,
        )!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month + Segmented control skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 120,
                  height: 24,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: 90,
                  height: 32,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(ClinicalTokens.radiusPill),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Week strip skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                return Container(
                  width: 40,
                  height: 60,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(ClinicalTokens.radiusCard),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Filter chips skeleton
            Row(
              children: List.generate(4, (i) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Container(
                    width: 70,
                    height: 32,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Summary row skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 140,
                  height: 18,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: 80,
                  height: 16,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Timeline rows skeleton
            for (int i = 0; i < 5; i++) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 44px time column
                  Container(
                    width: 44,
                    height: 14,
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Content card skeleton
                  Expanded(
                    child: Container(
                      height: i == 1 ? 90 : 54,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(ClinicalTokens.radiusCard),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}
