import 'package:flutter/material.dart';
import '../../../core/constants/app_motion.dart';
import 'plus_buddy_painter.dart';

/// Animated logo component for the splash screen featuring the Plus Buddy character.
///
/// Features:
/// 1. Primary-blue rounded-square tile with cute white cloud-like 4-lobed body.
/// 2. Body entrance: fades in + scales from 0.8 to 1.0 (AppMotion.splashLogoCurve) with circular glow.
/// 3. Independent Eye Animation (driven by [entranceController]):
///    - Stage 1 (Initial state): Body appears with cheeks and smile, leaving space for eyes. Eyes remain above screen.
///    - Stage 2 (Eyes entering): Eyes enter from above the visible screen boundary, moving downward.
///    - Stage 3 (Eyes settling): Eyes arrive at their intended face position and settle naturally into place.
///    - Stage 4 (Return movement): Eyes move upward, reversing their downward direction back above screen.
/// 4. Idle pulse: gentle breathing effect (scale 1.0 to 1.03) after entrance completes.
class AnimatedSplashLogo extends StatefulWidget {
  /// Animation controller for the entrance animation
  final AnimationController entranceController;

  /// Whether to show the idle pulse after entrance completes
  final bool showIdlePulse;

  /// Size of the logo
  final double size;

  /// Hero tag for hero transitions
  final String? heroTag;

  /// Optional override for tile color (defaults to theme primary)
  final Color? tileColor;

  const AnimatedSplashLogo({
    super.key,
    required this.entranceController,
    this.showIdlePulse = true,
    this.size = 120.0,
    this.heroTag = 'app_logo',
    this.tileColor,
  });

  @override
  State<AnimatedSplashLogo> createState() => _AnimatedSplashLogoState();
}

class _AnimatedSplashLogoState extends State<AnimatedSplashLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _glowOpacity;
  late final Animation<double> _glowScale;
  late final Animation<double> _pulseScale;
  late final Animation<double> _eyeYProgress;

  @override
  void initState() {
    super.initState();

    // 1. Logo entrance: opacity (0.0 - 0.5)
    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: widget.entranceController,
        curve: const Interval(
          AppMotion.splashLogoIntervalStart,
          AppMotion.splashLogoIntervalEnd,
          curve: AppMotion.splashLogoCurve,
        ),
      ),
    );

    // 2. Logo entrance: scale (0.0 - 0.5)
    _logoScale = Tween<double>(
      begin: AppMotion.splashLogoScaleFrom,
      end: AppMotion.splashLogoScaleTo,
    ).animate(
      CurvedAnimation(
        parent: widget.entranceController,
        curve: const Interval(
          AppMotion.splashLogoIntervalStart,
          AppMotion.splashLogoIntervalEnd,
          curve: AppMotion.splashLogoCurve,
        ),
      ),
    );

    // 3. Glow behind logo (0.3 - 0.7)
    _glowOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: AppMotion.splashGlowOpacity),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: AppMotion.splashGlowOpacity, end: 0.0),
        weight: 50.0,
      ),
    ]).animate(
      CurvedAnimation(
        parent: widget.entranceController,
        curve: const Interval(
          AppMotion.splashGlowIntervalStart,
          AppMotion.splashGlowIntervalEnd,
          curve: AppMotion.splashGlowCurve,
        ),
      ),
    );

    _glowScale = Tween<double>(
      begin: AppMotion.splashGlowScaleFrom,
      end: AppMotion.splashGlowScaleTo,
    ).animate(
      CurvedAnimation(
        parent: widget.entranceController,
        curve: const Interval(
          AppMotion.splashGlowIntervalStart,
          AppMotion.splashGlowIntervalEnd,
          curve: AppMotion.splashGlowCurve,
        ),
      ),
    );

    // 4. Independent Eye Animation Sequence (-1.0 = above screen, 0.0 = on face)
    // Stage 1 (0.00 - 0.20): Initial state - eyes held above visible boundary (-1.0)
    // Stage 2 (0.20 - 0.55): Eyes entering downward from above screen to face (-1.0 -> 0.0)
    // Stage 3 (0.55 - 0.75): Eyes settling naturally at intended face position (0.0)
    // Stage 4 (0.75 - 1.00): Return movement - eyes move upward reversing downward direction (0.0 -> -1.0)
    _eyeYProgress = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(-1.0),
        weight: 20.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -1.0, end: 0.0).chain(
          CurveTween(curve: Curves.easeOutCubic),
        ),
        weight: 35.0,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0),
        weight: 20.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -1.0).chain(
          CurveTween(curve: Curves.easeInCubic),
        ),
        weight: 25.0,
      ),
    ]).animate(widget.entranceController);

    // 5. Idle pulse animation (separate controller)
    _pulseController = AnimationController(
      vsync: this,
      duration: AppMotion.splashPulseDuration,
    );

    _pulseScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: AppMotion.splashPulseScaleFrom,
          end: AppMotion.splashPulseScaleTo,
        ).chain(CurveTween(curve: AppMotion.splashPulseCurve)),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: AppMotion.splashPulseScaleTo,
          end: AppMotion.splashPulseScaleFrom,
        ).chain(CurveTween(curve: AppMotion.splashPulseCurve)),
        weight: 50.0,
      ),
    ]).animate(_pulseController);

    // Start idle pulse after entrance completes
    widget.entranceController.addStatusListener(_onEntranceStatusChanged);
  }

  void _onEntranceStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed && widget.showIdlePulse) {
      _pulseController.repeat();
    }
  }

  @override
  void dispose() {
    widget.entranceController.removeStatusListener(_onEntranceStatusChanged);
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = widget.tileColor ?? theme.colorScheme.primary;

    final mediaQuery = MediaQuery.maybeOf(context);
    final screenHeight = mediaQuery?.size.height ?? 800.0;
    final reduceAnimations = mediaQuery?.disableAnimations ?? false;

    // Guaranteed distance to place eyes above the visible screen boundary
    final screenTopDistance = (screenHeight / 2) + 150.0;

    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.entranceController,
        _pulseController,
      ]),
      builder: (context, child) {
        final entranceComplete =
            widget.entranceController.status == AnimationStatus.completed;
        final combinedScale =
            _logoScale.value * (entranceComplete ? _pulseScale.value : 1.0);

        // Effective eye offset in physical pixels
        final eyeOffsetY = reduceAnimations
            ? 0.0
            : _eyeYProgress.value * screenTopDistance;

        final logoContent = SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // 1. Circular glow behind logo (only during entrance)
              if (_glowOpacity.value > 0.0)
                Opacity(
                  opacity: _glowOpacity.value,
                  child: Transform.scale(
                    scale: _glowScale.value,
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),

              // 2. Logo Body: stays centered in position, retains fade + entrance scale + idle pulse
              ScaleTransition(
                scale: AlwaysStoppedAnimation(combinedScale),
                child: FadeTransition(
                  opacity: _logoOpacity,
                  child: SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: CustomPaint(
                      key: const Key('splash_logo_body'),
                      size: Size(widget.size, widget.size),
                      painter: PlusBuddyBodyPainter(tileColor: primaryColor),
                    ),
                  ),
                ),
              ),

              // 3. Eyes: move independently along Y (enters from above, settles, reverses upward)
              Transform.translate(
                key: const Key('splash_logo_eyes_translate'),
                offset: Offset(0, eyeOffsetY),
                child: ScaleTransition(
                  scale: AlwaysStoppedAnimation(
                    entranceComplete ? _pulseScale.value : 1.0,
                  ),
                  child: SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: CustomPaint(
                      key: const Key('splash_logo_eyes'),
                      size: Size(widget.size, widget.size),
                      painter: const PlusBuddyEyesPainter(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

        if (widget.heroTag != null) {
          return Hero(
            tag: widget.heroTag!,
            child: logoContent,
          );
        }

        return logoContent;
      },
    );
  }
}
