import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import 'onboarding_bottom_sheet.dart';
import 'onboarding_data.dart';
import 'onboarding_progress_bar.dart';
import 'onboarding_slide.dart';

/// Full onboarding screen displayed after the splash screen.
///
/// Layout:
/// - Top ~65%: Full-bleed PageView carousel with gradient, title, subtitle,
///   and segmented progress bar.
/// - Bottom ~35%: White rounded bottom sheet with title, subtitle, Log in and Sign up buttons.
class OnboardingScreen extends StatefulWidget {
  final List<OnboardingSlideData> slides;
  final String appName;
  final VoidCallback? onLogin;
  final VoidCallback? onSignUp;

  const OnboardingScreen({
    super.key,
    this.slides = onboardingSlides,
    this.appName = 'Afya Clinic',
    this.onLogin,
    this.onSignUp,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _animationController;

  int _currentIndex = 0;
  Offset? _pointerDownPosition;
  DateTime? _pointerDownTime;
  bool _isHolding = false;

  static const Duration _slideDuration = Duration(seconds: 4);
  static const Duration _transitionDuration = Duration(milliseconds: 350);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _animationController = AnimationController(
      vsync: this,
      duration: _slideDuration,
    );

    _animationController.addStatusListener(_handleAnimationStatus);
    _animationController.forward();
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _advanceToNextSlide(isAuto: true);
    }
  }

  void _advanceToNextSlide({bool isAuto = false}) {
    if (!mounted || widget.slides.isEmpty) return;

    final nextIndex = (_currentIndex + 1) % widget.slides.length;
    _pageController.animateToPage(
      nextIndex,
      duration: _transitionDuration,
      curve: Curves.easeInOut,
    );
  }

  void _advanceToPreviousSlide() {
    if (!mounted || widget.slides.isEmpty) return;

    final prevIndex =
        (_currentIndex - 1 + widget.slides.length) % widget.slides.length;
    _pageController.animateToPage(
      prevIndex,
      duration: _transitionDuration,
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    if (!mounted) return;
    setState(() {
      _currentIndex = index;
    });
    // Restart animation from beginning for the newly focused slide
    _animationController.forward(from: 0.0);
  }

  void _handlePointerDown(PointerDownEvent event) {
    _pointerDownPosition = event.position;
    _pointerDownTime = DateTime.now();
    _isHolding = true;

    // Pause auto-advance animation while held down
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    final downPos = _pointerDownPosition;
    final downTime = _pointerDownTime;
    _pointerDownPosition = null;
    _pointerDownTime = null;
    _isHolding = false;

    if (downPos == null || downTime == null) {
      _resumeAnimation();
      return;
    }

    final distanceMoved = (event.position - downPos).distance;
    final pressDurationMs =
        DateTime.now().difference(downTime).inMilliseconds;

    // A short tap without significant movement (<15px, <300ms)
    if (distanceMoved < 15 && pressDurationMs < 300) {
      final screenWidth = MediaQuery.of(context).size.width;
      // Tapping left moves to previous slide, tapping right moves to next slide
      if (event.localPosition.dx < screenWidth * 0.35) {
        _advanceToPreviousSlide();
      } else {
        _advanceToNextSlide();
      }
    } else {
      // User held down or swiped. Resume progress from current position.
      _resumeAnimation();
    }
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    _pointerDownPosition = null;
    _pointerDownTime = null;
    _isHolding = false;
    _resumeAnimation();
  }

  void _resumeAnimation() {
    if (!mounted || _isHolding) return;
    if (_animationController.status != AnimationStatus.forward) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.removeStatusListener(_handleAnimationStatus);
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = widget.slides;
    final route = ModalRoute.of(context);
    final routeAnimation = route?.animation;

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final totalHeight = constraints.maxHeight;
          final totalWidth = constraints.maxWidth;

          // Proportions: ~65% carousel on top, ~35% bottom sheet
          final topHeight = totalHeight * 0.65;
          final overlap = AppTheme.radiusXl; // 24dp overlap behind card corners

          return Stack(
            fit: StackFit.expand,
            children: [
              // Top Carousel Section (~65% + 24dp curve overlap)
              // Animated entrance: fade in + zoom from 1.08 to 1.0 (0.2 - 0.7)
              _buildAnimatedCarousel(
                routeAnimation: routeAnimation,
                topHeight: topHeight,
                overlap: overlap,
                slides: slides,
              ),

              // Bottom Sheet Card (~35%)
              // Animated entrance: slide up (0.4 - 1.0) + content fade (0.6 - 1.0)
              _buildAnimatedBottomSheet(
                routeAnimation: routeAnimation,
                topHeight: topHeight,
                totalHeight: totalHeight,
                totalWidth: totalWidth,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnimatedCarousel({
    required Animation<double>? routeAnimation,
    required double topHeight,
    required double overlap,
    required List<OnboardingSlideData> slides,
  }) {
    final carouselContent = Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _handlePointerDown,
      onPointerUp: _handlePointerUp,
      onPointerCancel: _handlePointerCancel,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // PageView of slides
          PageView.builder(
            controller: _pageController,
            itemCount: slides.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return OnboardingSlide(
                slide: slides[index],
                // Bottom padding so text sits above progress bar and bottom sheet
                bottomPadding: overlap + 44.0,
              );
            },
          ),

          // Segmented progress bar overlay near bottom of image area
          Positioned(
            left: AppTheme.spacingLg,
            right: AppTheme.spacingLg,
            bottom: overlap + 18.0,
            child: OnboardingProgressBar(
              totalCount: slides.length,
              currentIndex: _currentIndex,
              animation: _animationController,
            ),
          ),
        ],
      ),
    );

    // If no route animation (direct navigation), show immediately
    if (routeAnimation == null) {
      return Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: topHeight + overlap,
        child: carouselContent,
      );
    }

    // Coordinated entrance: fade in + zoom from 1.08 to 1.0 (0.2 - 0.7)
    return AnimatedBuilder(
      animation: routeAnimation,
      builder: (context, child) {
        final opacity = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: routeAnimation,
            curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
          ),
        );

        final scale = Tween<double>(
          begin: 1.08,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: routeAnimation,
            curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
          ),
        );

        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: topHeight + overlap,
          child: Opacity(
            opacity: opacity.value,
            child: Transform.scale(
              scale: scale.value,
              child: carouselContent,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBottomSheet({
    required Animation<double>? routeAnimation,
    required double topHeight,
    required double totalHeight,
    required double totalWidth,
  }) {
    final bottomSheetContent = SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: totalHeight - topHeight,
          minWidth: totalWidth,
        ),
        child: IntrinsicHeight(
          child: OnboardingBottomSheet(
            appName: widget.appName,
            onLogin: widget.onLogin,
            onSignUp: widget.onSignUp,
          ),
        ),
      ),
    );

    // If no route animation (direct navigation), show immediately
    if (routeAnimation == null) {
      return Positioned(
        top: topHeight,
        left: 0,
        right: 0,
        bottom: 0,
        child: bottomSheetContent,
      );
    }

    // Coordinated entrance: slide up (0.4 - 1.0)
    return AnimatedBuilder(
      animation: routeAnimation,
      builder: (context, child) {
        final slideOffset = Tween<Offset>(
          begin: const Offset(0.0, 1.0), // Start below screen
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: routeAnimation,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
          ),
        );

        final contentOpacity = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: routeAnimation,
            curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
          ),
        );

        return Positioned(
          top: topHeight,
          left: 0,
          right: 0,
          bottom: 0,
          child: SlideTransition(
            position: slideOffset,
            child: Opacity(
              opacity: contentOpacity.value,
              child: bottomSheetContent,
            ),
          ),
        );
      },
    );
  }
}
