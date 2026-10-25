import 'package:flutter/material.dart';
import '../../config/app_assets.dart';
import '../../core/constants/app_motion.dart';
import '../../core/navigation/splash_to_onboarding_route.dart';
import '../onboarding/onboarding_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/patient_dashboard_screen.dart';
import 'splash_controller.dart';
import 'widgets/animated_splash_logo.dart';

/// Animated splash screen with entrance animation and smart routing.
///
/// Phase 1 (Entrance - ~1.6s):
/// - Logo fades in and scales from 0.8 to 1.0 (easeOutBack)
/// - Circular glow expands and fades behind the logo
/// - App name fades in and slides up
/// - Tagline fades in
///
/// After entrance completes:
/// - Logo pulses gently (1.0 to 1.03) while waiting for initialization
///
/// Phase 2 (Exit - ~700ms):
/// - Custom transition to destination (onboarding/login/home)
/// - Onboarding gets special coordinated transition
/// - Login/home get simple fade
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final SplashController _splashController;

  late final Animation<double> _appNameOpacity;
  late final Animation<Offset> _appNameSlide;
  late final Animation<double> _taglineOpacity;

  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: AppMotion.splashEntranceDuration,
    );

    // App name animation: fade in + slide up
    _appNameOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(
          AppMotion.splashAppNameIntervalStart,
          AppMotion.splashAppNameIntervalEnd,
          curve: AppMotion.splashAppNameCurve,
        ),
      ),
    );

    _appNameSlide = Tween<Offset>(
      begin: const Offset(0.0, AppMotion.splashAppNameSlideOffset),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(
          AppMotion.splashAppNameIntervalStart,
          AppMotion.splashAppNameIntervalEnd,
          curve: AppMotion.splashAppNameCurve,
        ),
      ),
    );

    // Tagline animation: fade in
    _taglineOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(
          AppMotion.splashTaglineIntervalStart,
          AppMotion.splashTaglineIntervalEnd,
          curve: AppMotion.splashTaglineCurve,
        ),
      ),
    );

    // Initialize controller
    _splashController = SplashController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Now safe to access MediaQuery
    if (!_hasNavigated) {
      _initializeApp();
      _precacheOnboardingImage();
    }
  }

  Future<void> _initializeApp() async {
    // Check for reduced motion preference
    final reduceAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    // Start entrance animation
    if (reduceAnimations) {
      _entranceController.value = 1.0;
    } else {
      _entranceController.forward();
    }

    // Run initialization (enforces minimum duration internally)
    await _splashController.initialize();

    // Navigate when ready
    if (mounted && !_hasNavigated) {
      _navigateToDestination();
    }
  }

  void _precacheOnboardingImage() {
    try {
      precacheImage(
        const AssetImage(AppAssets.onboarding1),
        context,
      );
    } catch (e) {
      debugPrint('Failed to precache onboarding image: $e');
    }
  }

  void _navigateToDestination() {
    if (_hasNavigated) return;
    _hasNavigated = true;

    final destination = _splashController.destination;
    if (destination == null) {
      // Fallback if destination is not set
      debugPrint('No destination set, defaulting to onboarding');
      _navigateToOnboarding();
      return;
    }

    switch (destination) {
      case SplashDestination.onboarding:
        _navigateToOnboarding();
        break;
      case SplashDestination.login:
        _navigateToLogin();
        break;
      case SplashDestination.home:
        _navigateToHome();
        break;
    }
  }

  void _navigateToOnboarding() {
    Navigator.of(context).pushReplacement(
      SplashToOnboardingRoute(
        builder: (_) => const OnboardingScreen(),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionDuration: AppMotion.genericFadeDuration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation.drive(
              CurveTween(curve: AppMotion.genericFadeCurve),
            ),
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const PatientDashboardScreen(),
        transitionDuration: AppMotion.genericFadeDuration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation.drive(
              CurveTween(curve: AppMotion.genericFadeCurve),
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _splashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated logo with glow
            AnimatedSplashLogo(
              entranceController: _entranceController,
              showIdlePulse: true,
              size: 120.0,
              heroTag: 'app_logo',
            ),

            const SizedBox(height: 32),

            // App name with fade + slide animation
            AnimatedBuilder(
              animation: _entranceController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _appNameOpacity,
                  child: Transform.translate(
                    offset: _appNameSlide.value,
                    child: child,
                  ),
                );
              },
              child: Text(
                'Afya Clinic',
                style: textTheme.displayLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 12),

            // Tagline with fade animation
            FadeTransition(
              opacity: _taglineOpacity,
              child: Text(
                'Care  •  Convenience  •  Confidence',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
