import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:afya_clinic/features/splash/widgets/plus_buddy_painter.dart';

void main() {
  test('Generate high-resolution launcher icon PNGs', () async {
    const size = 1024.0;

    // 1. Generate app_icon.png (Full icon with primary blue background)
    {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, size, size));

      // Background: primary blue #3B6FE0
      final bgPaint = Paint()..color = const Color(0xFF3B6FE0);
      canvas.drawRect(const Rect.fromLTWH(0, 0, size, size), bgPaint);

      // Draw Plus Buddy Body, cheeks, smile
      final bodyPainter = PlusBuddyBodyPainter(
        tileColor: const Color(0xFF3B6FE0),
        showCheeksAndSmile: true,
      );
      bodyPainter.paint(canvas, const Size(size, size));

      // Draw Plus Buddy Eyes
      const eyesPainter = PlusBuddyEyesPainter();
      eyesPainter.paint(canvas, const Size(size, size));

      final picture = recorder.endRecording();
      final img = await picture.toImage(size.toInt(), size.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final file = File('assets/icons/app_icon.png');
      await file.writeAsBytes(buffer);
      expect(file.existsSync(), isTrue);
      debugPrint('Saved app_icon.png (${buffer.length} bytes)');
    }

    // 2. Generate app_icon_foreground.png for Android Adaptive Icons
    // Sized to ~54% of canvas so it stays perfectly within Android's 66% safe zone
    {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, size, size));

      // Scale and center character within 1024x1024 matching app_icon.png proportions
      const characterScale = 1.0; // Exact 0.62 span matching reference launcher icon
      canvas.save();
      canvas.translate(size / 2, size / 2);
      canvas.scale(characterScale);
      canvas.translate(-size / 2, -size / 2);

      // Transparent background - draw ONLY white body
      final bodyPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      final bodyPath = PlusBuddyPath.create(size);
      canvas.drawPath(bodyPath, bodyPaint);

      // Cheeks and smile
      final c = size / 2;
      final cheekRadius = size * 0.0375;
      final cheekY = c + size * 0.0375;
      final cheekPaint = Paint()
        ..color = const Color(0xFFFFAAA8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(c - size * 0.1375, cheekY), cheekRadius, cheekPaint);
      canvas.drawCircle(Offset(c + size * 0.1375, cheekY), cheekRadius, cheekPaint);

      final smilePaint = Paint()
        ..color = const Color(0xFF1A1D29)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size * 0.021
        ..strokeCap = StrokeCap.round;
      final smilePath = Path()
        ..moveTo(c - size * 0.05, c + size * 0.02)
        ..quadraticBezierTo(c, c + size * 0.054, c + size * 0.05, c + size * 0.02);
      canvas.drawPath(smilePath, smilePaint);

      // Eyes
      const eyesPainter = PlusBuddyEyesPainter();
      eyesPainter.paint(canvas, const Size(size, size));

      canvas.restore();

      final picture = recorder.endRecording();
      final img = await picture.toImage(size.toInt(), size.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final file = File('assets/icons/app_icon_foreground.png');
      await file.writeAsBytes(buffer);
      expect(file.existsSync(), isTrue);
      debugPrint('Saved app_icon_foreground.png (${buffer.length} bytes)');
    }
  });
}
