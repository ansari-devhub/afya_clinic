import 'package:flutter/material.dart';

/// Decorative neomorphic background widget.
///
/// Wraps the screen with the theme's surface color and 3-4 soft decorative circles
/// positioned partly off-screen in the corners (using theme primary at low opacity,
/// with one circle having a subtle ring border).
/// Decorative elements are wrapped in [IgnorePointer] so touches pass through cleanly.
class NeoBackground extends StatelessWidget {
  final Widget child;

  const NeoBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surface;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: surfaceColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Decorative background circles - ignored by touch
          IgnorePointer(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Top-left soft glow circle
                Positioned(
                  top: -80,
                  left: -80,
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withValues(alpha: 0.06),
                    ),
                  ),
                ),

                // Top-right circle with subtle ring border
                Positioned(
                  top: -60,
                  right: -70,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withValues(alpha: 0.04),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.12),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                // Bottom-right soft circle
                Positioned(
                  bottom: -100,
                  right: -90,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withValues(alpha: 0.05),
                    ),
                  ),
                ),

                // Bottom-left smaller subtle accent circle
                Positioned(
                  bottom: 60,
                  left: -50,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withValues(alpha: 0.03),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Foreground child
          SafeArea(
            child: child,
          ),
        ],
      ),
    );
  }
}
