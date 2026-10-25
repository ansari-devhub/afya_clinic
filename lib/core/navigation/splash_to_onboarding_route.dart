import 'package:flutter/material.dart';
import '../constants/app_motion.dart';

/// Custom page route for the coordinated splash exit → onboarding entrance transition.
///
/// Timeline (700ms total):
/// - 0.0-0.4: Splash text fades out, logo scales down and fades out
/// - 0.2-0.7: Onboarding first image fades in and zooms from 1.08 to 1.0
/// - 0.4-1.0: Onboarding bottom sheet slides up
/// - 0.6-1.0: Onboarding bottom sheet content fades in
///
/// The onboarding screen reads ModalRoute.of(context)!.animation to coordinate
/// its entrance with the route transition.
class SplashToOnboardingRoute<T> extends PageRouteBuilder<T> {
  SplashToOnboardingRoute({
    required WidgetBuilder builder,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) {
            return builder(context);
          },
          transitionDuration: AppMotion.splashExitDuration,
          reverseTransitionDuration: AppMotion.splashExitDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // The onboarding screen itself handles its entrance animation
            // by reading the route animation. We just return the child here.
            // The splash screen exit is handled by fadeOut on the old route.
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Fade out the old route (splash screen)
    // The splash screen elements will fade out via secondaryAnimation
    if (secondaryAnimation.status != AnimationStatus.dismissed) {
      return FadeTransition(
        opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(
            parent: secondaryAnimation,
            curve: const Interval(
              AppMotion.splashTextFadeOutStart,
              AppMotion.splashTextFadeOutEnd,
              curve: AppMotion.splashTextFadeOutCurve,
            ),
          ),
        ),
        child: child,
      );
    }

    // Fade in the new route (onboarding screen)
    return child;
  }
}
