import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:afya_clinic/features/splash/widgets/animated_splash_logo.dart';
import 'package:afya_clinic/features/splash/widgets/plus_buddy_painter.dart';

void main() {
  group('PlusBuddy Logo & Path Tests', () {
    test('PlusBuddyPath creates valid, closed, non-empty path', () {
      final path = PlusBuddyPath.create(120.0);
      expect(path, isNotNull);
      final bounds = path.getBounds();
      // Should be centered around (60, 60) with span ~74.4
      expect(bounds.width, closeTo(74.4, 1.0));
      expect(bounds.height, closeTo(74.4, 1.0));
      expect(bounds.center.dx, closeTo(60.0, 0.5));
      expect(bounds.center.dy, closeTo(60.0, 0.5));
    });

    testWidgets('PlusBuddyLogo renders correctly with and without eyes', (WidgetTester tester) async {
      // 1. With eyes
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: PlusBuddyLogo(size: 100),
            ),
          ),
        ),
      );

      expect(find.byType(PlusBuddyLogo), findsOneWidget);
      final customPaintsWithEyes = find.descendant(
        of: find.byType(PlusBuddyLogo),
        matching: find.byType(CustomPaint),
      );
      expect(customPaintsWithEyes, findsNWidgets(2)); // Body + Eyes

      // 2. Without eyes (leaving eye space empty)
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: PlusBuddyLogo(size: 100, showEyes: false),
            ),
          ),
        ),
      );

      final customPaintsWithoutEyes = find.descendant(
        of: find.byType(PlusBuddyLogo),
        matching: find.byType(CustomPaint),
      );
      expect(customPaintsWithoutEyes, findsOneWidget); // Body only
    });
  });

  group('AnimatedSplashLogo Eye Animation Sequence Tests', () {
    Widget buildTestHarness(AnimationController controller, {bool disableAnimations = false}) {
      return MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(400, 800),
            disableAnimations: disableAnimations,
          ),
          child: Scaffold(
            body: Center(
              child: AnimatedSplashLogo(
                entranceController: controller,
                size: 120.0,
                showIdlePulse: false,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('1. Initial state (0.0): logo body rendered, eyes are above screen boundary', (WidgetTester tester) async {
      late AnimationController controller;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            controller = AnimationController(
              vsync: tester,
              duration: const Duration(milliseconds: 1600),
            );
            return buildTestHarness(controller);
          },
        ),
      );

      controller.value = 0.0;
      await tester.pump();

      // Verify body and eyes are present in tree
      expect(find.byKey(const Key('splash_logo_body')), findsOneWidget);
      expect(find.byKey(const Key('splash_logo_eyes')), findsOneWidget);

      // Verify eyes translation is above the screen boundary (screen height is 800, center is 400)
      // screenTopDistance = 400 + 150 = 550. Eye offset at progress -1.0 is -550
      final eyeTransform = tester.widget<Transform>(
        find.byKey(const Key('splash_logo_eyes_translate')),
      );
      final translation = eyeTransform.transform.getTranslation();
      expect(translation.y, lessThan(-400.0)); // Far above visible screen boundary
    });

    testWidgets('2. Eyes entering: moves downward from above screen toward face', (WidgetTester tester) async {
      late AnimationController controller;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            controller = AnimationController(
              vsync: tester,
              duration: const Duration(milliseconds: 1600),
            );
            return buildTestHarness(controller);
          },
        ),
      );

      // At progress 0.10: still held above visible boundary
      controller.value = 0.10;
      await tester.pump();
      final transformAt10 = tester.widget<Transform>(
        find.byKey(const Key('splash_logo_eyes_translate')),
      );
      final y10 = transformAt10.transform.getTranslation().y;
      expect(y10, lessThan(-400.0));

      // At progress 0.38: moving downward (closer to 0.0 than at 0.10)
      controller.value = 0.38;
      await tester.pump();
      final transformAt38 = tester.widget<Transform>(
        find.byKey(const Key('splash_logo_eyes_translate')),
      );
      final y38 = transformAt38.transform.getTranslation().y;
      expect(y38, greaterThan(y10)); // Moved downward
      expect(y38, lessThan(0.0)); // Not yet fully settled
    });

    testWidgets('3. Eyes settling: arrives at 0.0 and settles naturally into face position', (WidgetTester tester) async {
      late AnimationController controller;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            controller = AnimationController(
              vsync: tester,
              duration: const Duration(milliseconds: 1600),
            );
            return buildTestHarness(controller);
          },
        ),
      );

      // At progress 0.65: settled on face at 0.0
      controller.value = 0.65;
      await tester.pump();
      final transformAt65 = tester.widget<Transform>(
        find.byKey(const Key('splash_logo_eyes_translate')),
      );
      final y65 = transformAt65.transform.getTranslation().y;
      expect(y65, closeTo(0.0, 0.001));

      // At progress 0.70: remains settled on face at 0.0
      controller.value = 0.70;
      await tester.pump();
      final transformAt70 = tester.widget<Transform>(
        find.byKey(const Key('splash_logo_eyes_translate')),
      );
      final y70 = transformAt70.transform.getTranslation().y;
      expect(y70, closeTo(0.0, 0.001));
    });

    testWidgets('4. Return movement: moves upward, reversing downward direction', (WidgetTester tester) async {
      late AnimationController controller;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            controller = AnimationController(
              vsync: tester,
              duration: const Duration(milliseconds: 1600),
            );
            return buildTestHarness(controller);
          },
        ),
      );

      // At progress 0.88: moving upward (more negative than 0.0)
      controller.value = 0.88;
      await tester.pump();
      final transformAt88 = tester.widget<Transform>(
        find.byKey(const Key('splash_logo_eyes_translate')),
      );
      final y88 = transformAt88.transform.getTranslation().y;
      expect(y88, lessThan(0.0)); // Moving back up

      // At progress 1.00: fully returned upward above screen boundary
      controller.value = 1.00;
      await tester.pump();
      final transformAt100 = tester.widget<Transform>(
        find.byKey(const Key('splash_logo_eyes_translate')),
      );
      final y100 = transformAt100.transform.getTranslation().y;
      expect(y100, lessThan(-400.0)); // Fully exited upward past visible screen boundary
    });

    testWidgets('5. Reduced motion: eyes remain resting on face when animations disabled', (WidgetTester tester) async {
      late AnimationController controller;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            controller = AnimationController(
              vsync: tester,
              duration: const Duration(milliseconds: 1600),
            );
            return buildTestHarness(controller, disableAnimations: true);
          },
        ),
      );

      controller.value = 0.0;
      await tester.pump();
      final transform = tester.widget<Transform>(
        find.byKey(const Key('splash_logo_eyes_translate')),
      );
      final y = transform.transform.getTranslation().y;
      expect(y, closeTo(0.0, 0.001));
    });
  });
}
