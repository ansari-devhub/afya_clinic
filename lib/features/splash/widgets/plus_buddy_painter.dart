import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Renders the Plus Buddy character body (tile, 4-lobed cloud body, cheeks, smile).
/// Can optionally render eyes, or leave the eye space open for independent eye animation.
class PlusBuddyBodyPainter extends CustomPainter {
  final Color tileColor;
  final bool showCheeksAndSmile;

  const PlusBuddyBodyPainter({
    this.tileColor = const Color(0xFF3B6FE0),
    this.showCheeksAndSmile = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = s / 2;

    // 1. Primary blue rounded-square background tile
    final tileRadius = Radius.circular(s * 0.24);
    final tileRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, s, s),
      tileRadius,
    );
    final tilePaint = Paint()
      ..color = tileColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(tileRect, tilePaint);

    // 2. White 4-lobed Plus Buddy body with filleted inner corners
    final bodyPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final bodyPath = PlusBuddyPath.create(s);
    canvas.drawPath(bodyPath, bodyPaint);

    if (showCheeksAndSmile) {
      // 3. Pink blush cheeks
      final cheekRadius = s * 0.0375;
      final cheekY = c + s * 0.0375;
      final cheekPaint = Paint()
        ..color = const Color(0xFFFFAAA8)
        ..style = PaintingStyle.fill;

      // Left cheek
      canvas.drawCircle(
        Offset(c - s * 0.1375, cheekY),
        cheekRadius,
        cheekPaint,
      );
      // Right cheek
      canvas.drawCircle(
        Offset(c + s * 0.1375, cheekY),
        cheekRadius,
        cheekPaint,
      );

      // 4. Dark charcoal smile arc
      final smilePaint = Paint()
        ..color = const Color(0xFF1A1D29)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.021
        ..strokeCap = StrokeCap.round;

      final smilePath = Path()
        ..moveTo(c - s * 0.05, c + s * 0.02)
        ..quadraticBezierTo(
          c,
          c + s * 0.054,
          c + s * 0.05,
          c + s * 0.02,
        );
      canvas.drawPath(smilePath, smilePaint);
    }
  }

  @override
  bool shouldRepaint(covariant PlusBuddyBodyPainter oldDelegate) {
    return oldDelegate.tileColor != tileColor ||
        oldDelegate.showCheeksAndSmile != showCheeksAndSmile;
  }
}

/// Renders only the dark eyes with white catchlights at their intended face position.
class PlusBuddyEyesPainter extends CustomPainter {
  final Color eyeColor;

  const PlusBuddyEyesPainter({
    this.eyeColor = const Color(0xFF1A1D29),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = s / 2;

    final eyeRadius = s * 0.03;
    final eyeY = c - s * 0.025;

    // Dark charcoal eye circles
    final eyePaint = Paint()
      ..color = eyeColor
      ..style = PaintingStyle.fill;

    // Left eye
    canvas.drawCircle(
      Offset(c - s * 0.065, eyeY),
      eyeRadius,
      eyePaint,
    );
    // Right eye
    canvas.drawCircle(
      Offset(c + s * 0.065, eyeY),
      eyeRadius,
      eyePaint,
    );

    // Specular catchlights (subtle white gleam)
    final catchlightPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final catchlightRadius = s * 0.009;

    canvas.drawCircle(
      Offset(c - s * 0.057, eyeY - s * 0.008),
      catchlightRadius,
      catchlightPaint,
    );
    canvas.drawCircle(
      Offset(c + s * 0.073, eyeY - s * 0.008),
      catchlightRadius,
      catchlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant PlusBuddyEyesPainter oldDelegate) {
    return oldDelegate.eyeColor != eyeColor;
  }
}

/// Path generator for the Plus Buddy 4-lobed cloud character.
class PlusBuddyPath {
  const PlusBuddyPath._();

  static Path create(double size) {
    final c = size / 2;
    final armRadius = size * 0.14;
    final halfSpan = size * 0.31;
    final r = size * 0.035;

    final path = Path();

    // 1. Top cap (semi-circle from left to right)
    path.arcTo(
      Rect.fromCircle(
        center: Offset(c, c - halfSpan + armRadius),
        radius: armRadius,
      ),
      math.pi,
      math.pi,
      false,
    );

    // 2. Line down right side of top arm
    path.lineTo(c + armRadius, c - armRadius - r);

    // 3. Top-right inner fillet
    path.quadraticBezierTo(
      c + armRadius,
      c - armRadius,
      c + armRadius + r,
      c - armRadius,
    );

    // 4. Line along top of right arm to right cap
    path.lineTo(c + halfSpan - armRadius, c - armRadius);

    // 5. Right cap (semi-circle from top to bottom)
    path.arcTo(
      Rect.fromCircle(
        center: Offset(c + halfSpan - armRadius, c),
        radius: armRadius,
      ),
      -math.pi / 2,
      math.pi,
      false,
    );

    // 6. Line along bottom of right arm
    path.lineTo(c + armRadius + r, c + armRadius);

    // 7. Bottom-right inner fillet
    path.quadraticBezierTo(
      c + armRadius,
      c + armRadius,
      c + armRadius,
      c + armRadius + r,
    );

    // 8. Line down right side of bottom arm to bottom cap
    path.lineTo(c + armRadius, c + halfSpan - armRadius);

    // 9. Bottom cap (semi-circle from right to left)
    path.arcTo(
      Rect.fromCircle(
        center: Offset(c, c + halfSpan - armRadius),
        radius: armRadius,
      ),
      0,
      math.pi,
      false,
    );

    // 10. Line up left side of bottom arm
    path.lineTo(c - armRadius, c + armRadius + r);

    // 11. Bottom-left inner fillet
    path.quadraticBezierTo(
      c - armRadius,
      c + armRadius,
      c - armRadius - r,
      c + armRadius,
    );

    // 12. Line along bottom of left arm to left cap
    path.lineTo(c - halfSpan + armRadius, c + armRadius);

    // 13. Left cap (semi-circle from bottom to top)
    path.arcTo(
      Rect.fromCircle(
        center: Offset(c - halfSpan + armRadius, c),
        radius: armRadius,
      ),
      math.pi / 2,
      math.pi,
      false,
    );

    // 14. Line along top of left arm
    path.lineTo(c - armRadius - r, c - armRadius);

    // 15. Top-left inner fillet
    path.quadraticBezierTo(
      c - armRadius,
      c - armRadius,
      c - armRadius,
      c - armRadius - r,
    );

    path.close();
    return path;
  }
}

/// Standalone Plus Buddy logo widget.
class PlusBuddyLogo extends StatelessWidget {
  final double size;
  final bool showEyes;
  final double eyeOffsetY;
  final Color? tileColor;

  const PlusBuddyLogo({
    super.key,
    this.size = 120.0,
    this.showEyes = true,
    this.eyeOffsetY = 0.0,
    this.tileColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTileColor = tileColor ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: PlusBuddyBodyPainter(tileColor: effectiveTileColor),
          ),
          if (showEyes)
            Transform.translate(
              offset: Offset(0, eyeOffsetY),
              child: CustomPaint(
                size: Size(size, size),
                painter: const PlusBuddyEyesPainter(),
              ),
            ),
        ],
      ),
    );
  }
}
