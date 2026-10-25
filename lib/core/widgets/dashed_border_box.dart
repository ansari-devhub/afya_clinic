import 'package:flutter/material.dart';

/// Container with a crisp dashed border with rounded corners.
class DashedBorderBox extends StatelessWidget {
  final Widget child;
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  const DashedBorderBox({
    super.key,
    required this.child,
    required this.color,
    this.radius = 12.0,
    this.strokeWidth = 1.0,
    this.dashWidth = 5.0,
    this.dashGap = 3.5,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: color,
        radius: radius,
        strokeWidth: strokeWidth,
        dashWidth: dashWidth,
        dashGap: dashGap,
        backgroundColor: backgroundColor,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(10.0),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;
  final Color? backgroundColor;

  _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashGap,
    this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    if (backgroundColor != null) {
      final fillPaint = Paint()
        ..color = backgroundColor!
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rrect, fillPaint);
    }

    final borderPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final length = dashWidth;
        if (distance + length > metric.length) {
          final extract = metric.extractPath(distance, metric.length);
          canvas.drawPath(extract, borderPaint);
          break;
        }
        final extract = metric.extractPath(distance, distance + length);
        canvas.drawPath(extract, borderPaint);
        distance += length + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
