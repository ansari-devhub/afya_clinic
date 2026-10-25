import 'package:flutter/material.dart';

/// Segmented progress bar for onboarding carousel slides.
///
/// Displays [totalCount] segments. Completed segments are fully filled,
/// the active segment [currentIndex] fills left-to-right based on [animation],
/// and upcoming segments are dim.
class OnboardingProgressBar extends StatelessWidget {
  final int totalCount;
  final int currentIndex;
  final Animation<double> animation;
  final double barHeight;
  final double spacing;
  final Color activeColor;
  final Color dimColor;
  final BorderRadius borderRadius;

  const OnboardingProgressBar({
    super.key,
    required this.totalCount,
    required this.currentIndex,
    required this.animation,
    this.barHeight = 4.0,
    this.spacing = 6.0,
    this.activeColor = Colors.white,
    this.dimColor = const Color(0x4DFFFFFF), // 30% white
    this.borderRadius = const BorderRadius.all(Radius.circular(2.0)),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.max,
          children: List.generate(totalCount, (index) {
            final double fillFactor;
            if (index < currentIndex) {
              fillFactor = 1.0;
            } else if (index == currentIndex) {
              fillFactor = animation.value.clamp(0.0, 1.0);
            } else {
              fillFactor = 0.0;
            }

            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                child: Container(
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: dimColor,
                    borderRadius: borderRadius,
                  ),
                  child: ClipRRect(
                    borderRadius: borderRadius,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: fillFactor,
                        child: Container(
                          height: barHeight,
                          color: activeColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
