import 'package:flutter/material.dart';
import 'onboarding_data.dart';

/// Single slide widget for the onboarding carousel.
///
/// Features:
/// - Full-bleed image with [BoxFit.cover]
/// - Memory-efficient decoding with [cacheWidth]
/// - Dark-to-transparent gradient at bottom for text legibility
/// - Slide title (bold, white, ~20sp) and subtitle (white, ~14sp, centered)
/// - Optional [progressBar] slot near bottom
class OnboardingSlide extends StatelessWidget {
  final OnboardingSlideData slide;
  final int? cacheWidth;
  final Widget? progressBar;
  final double bottomPadding;

  const OnboardingSlide({
    super.key,
    required this.slide,
    this.cacheWidth,
    this.progressBar,
    this.bottomPadding = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate optimal cacheWidth if not explicitly supplied
    final effectiveCacheWidth = cacheWidth ??
        (MediaQuery.maybeSizeOf(context) != null
            ? (MediaQuery.sizeOf(context).width *
                    (MediaQuery.maybeDevicePixelRatioOf(context) ?? 1.0))
                .round()
            : null);

    final textTheme = Theme.of(context).textTheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Full-bleed background image
        Image.asset(
          slide.imageAsset,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          cacheWidth: effectiveCacheWidth,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
              child: const Center(
                child: Icon(
                  Icons.local_hospital_rounded,
                  size: 72,
                  color: Colors.white70,
                ),
              ),
            );
          },
        ),

        // Dark-to-transparent gradient for contrast & readability
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.60),
                  Colors.black.withValues(alpha: 0.90),
                ],
                stops: const [0.0, 0.40, 0.75, 1.0],
              ),
            ),
          ),
        ),

        // Title, Subtitle, and optional Progress Bar near bottom
        Positioned(
          left: 24,
          right: 24,
          bottom: bottomPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                slide.title,
                textAlign: TextAlign.center,
                style: (textTheme.titleLarge ?? const TextStyle()).copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                slide.subtitle,
                textAlign: TextAlign.center,
                style: (textTheme.bodyMedium ?? const TextStyle()).copyWith(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.92),
                  height: 1.4,
                ),
              ),
              if (progressBar != null) ...[
                const SizedBox(height: 16),
                progressBar!,
              ],
            ],
          ),
        ),
      ],
    );
  }
}
