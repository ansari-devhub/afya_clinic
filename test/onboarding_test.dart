import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:afya_clinic/config/app_assets.dart';
import 'package:afya_clinic/config/app_theme.dart';
import 'package:afya_clinic/features/onboarding/onboarding_bottom_sheet.dart';
import 'package:afya_clinic/features/onboarding/onboarding_data.dart';
import 'package:afya_clinic/features/onboarding/onboarding_progress_bar.dart';
import 'package:afya_clinic/features/onboarding/onboarding_screen.dart';
import 'package:afya_clinic/features/onboarding/onboarding_slide.dart';

void main() {
  group('Onboarding Data & Model Tests', () {
    test('onboardingSlides has 5 slides with correct content and AppAssets', () {
      expect(onboardingSlides.length, 5);

      expect(onboardingSlides[0].title, 'Book in seconds');
      expect(onboardingSlides[0].subtitle,
          'Pick a doctor and a time that suits you. No queues.');
      expect(onboardingSlides[0].imageAsset, AppAssets.onboarding1);

      expect(onboardingSlides[1].title, 'See a doctor from home');
      expect(onboardingSlides[1].subtitle,
          'Video consultations with licensed doctors, wherever you are.');
      expect(onboardingSlides[1].imageAsset, AppAssets.onboarding2);

      expect(onboardingSlides[2].title, 'Your records, in your pocket');
      expect(onboardingSlides[2].subtitle,
          'Prescriptions, lab results and visit history, all in one place.');
      expect(onboardingSlides[2].imageAsset, AppAssets.onboarding3);

      expect(onboardingSlides[3].title, 'Never miss a dose');
      expect(onboardingSlides[3].subtitle,
          'Smart reminders for medication and follow-up visits.');
      expect(onboardingSlides[3].imageAsset, AppAssets.onboarding4);

      expect(onboardingSlides[4].title, 'Pay your way');
      expect(onboardingSlides[4].subtitle,
          'Settle bills with M-Pesa or your insurance cover, right in the app.');
      expect(onboardingSlides[4].imageAsset, AppAssets.onboarding5);
    });
  });

  group('OnboardingProgressBar Tests', () {
    testWidgets('renders correct number of segments and reflects animation',
        (tester) async {
      final animationController = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(seconds: 4),
      );
      animationController.value = 0.5;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingProgressBar(
              totalCount: 5,
              currentIndex: 2,
              animation: animationController,
            ),
          ),
        ),
      );

      final rowFinder = find.byType(Row);
      expect(rowFinder, findsOneWidget);

      final fractionallySizedBoxes = tester.widgetList<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      ).toList();

      expect(fractionallySizedBoxes.length, 5);
      // Index 0: completed -> 1.0
      expect(fractionallySizedBoxes[0].widthFactor, 1.0);
      // Index 1: completed -> 1.0
      expect(fractionallySizedBoxes[1].widthFactor, 1.0);
      // Index 2: active -> animation.value (0.5)
      expect(fractionallySizedBoxes[2].widthFactor, 0.5);
      // Index 3: upcoming -> 0.0
      expect(fractionallySizedBoxes[3].widthFactor, 0.0);
      // Index 4: upcoming -> 0.0
      expect(fractionallySizedBoxes[4].widthFactor, 0.0);

      animationController.dispose();
    });
  });

  group('OnboardingBottomSheet Tests', () {
    testWidgets('renders title, subtitle, and both buttons with theme styles',
        (tester) async {
      bool loginTapped = false;
      bool signUpTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: OnboardingBottomSheet(
              appName: 'Afya Clinic',
              onLogin: () => loginTapped = true,
              onSignUp: () => signUpTapped = true,
            ),
          ),
        ),
      );

      // Verify title & subtitle
      expect(find.text('Welcome to Afya Clinic'), findsOneWidget);
      expect(
          find.text('Quality care, right from your phone.'), findsOneWidget);

      // Verify buttons
      final loginBtnFinder = find.widgetWithText(ElevatedButton, 'Log in');
      final signUpBtnFinder = find.widgetWithText(OutlinedButton, 'Sign up');
      expect(loginBtnFinder, findsOneWidget);
      expect(signUpBtnFinder, findsOneWidget);

      // Tap buttons
      await tester.tap(loginBtnFinder);
      expect(loginTapped, isTrue);

      await tester.tap(signUpBtnFinder);
      expect(signUpTapped, isTrue);
    });

    testWidgets('navigates to /login and /signup when callbacks are null',
        (tester) async {
      String? currentRoute;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          initialRoute: '/',
          routes: {
            '/': (context) => const Scaffold(
                  body: OnboardingBottomSheet(appName: 'Afya Clinic'),
                ),
            '/login': (context) {
              currentRoute = '/login';
              return const Scaffold(body: Text('Login Screen'));
            },
            '/signup': (context) {
              currentRoute = '/signup';
              return const Scaffold(body: Text('Sign Up Screen'));
            },
          },
        ),
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Log in'));
      await tester.pumpAndSettle();
      expect(currentRoute, '/login');
      expect(find.text('Login Screen'), findsOneWidget);
    });
  });

  group('OnboardingSlide Tests', () {
    testWidgets('renders slide title and subtitle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: OnboardingSlide(
              slide: onboardingSlides[0],
            ),
          ),
        ),
      );

      expect(find.text('Book in seconds'), findsOneWidget);
      expect(
        find.text('Pick a doctor and a time that suits you. No queues.'),
        findsOneWidget,
      );
    });
  });

  group('OnboardingScreen Flow Tests', () {
    testWidgets('displays initial slide and bottom sheet', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OnboardingScreen(),
        ),
      );

      expect(find.text('Book in seconds'), findsOneWidget);
      expect(find.text('Welcome to Afya Clinic'), findsOneWidget);
      expect(find.text('Log in'), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);
    });

    testWidgets('auto-advances to next slide after 4 seconds', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OnboardingScreen(),
        ),
      );

      expect(find.text('Book in seconds'), findsOneWidget);

      // Advance 4 seconds for auto-advance
      await tester.pump(const Duration(seconds: 4));
      // First frame to start the page animation
      await tester.pump(const Duration(milliseconds: 50));
      // Second frame to complete the page animation (350ms transition)
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('See a doctor from home'), findsOneWidget);
    });

    testWidgets('tapping right advances to next slide', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OnboardingScreen(),
        ),
      );

      expect(find.text('Book in seconds'), findsOneWidget);

      // Tap on the right side of the screen (e.g. 75% width, 30% height)
      await tester.tapAt(const Offset(600, 200));
      // Pump for short tap duration
      await tester.pump(const Duration(milliseconds: 50));
      // Allow PageView transition animation
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('See a doctor from home'), findsOneWidget);
    });

    testWidgets('holding down on image pauses auto-advance', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OnboardingScreen(),
        ),
      );

      expect(find.text('Book in seconds'), findsOneWidget);

      // Start a hold at 1 second
      await tester.pump(const Duration(seconds: 1));
      final gesture = await tester.startGesture(const Offset(400, 200));

      // Advance 5 seconds while holding
      await tester.pump(const Duration(seconds: 5));

      // It should NOT have advanced because it was held
      expect(find.text('Book in seconds'), findsOneWidget);

      // Release hold
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 50));

      // After releasing, it resumes the remaining ~3 seconds
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 400));

      // Now it advances
      expect(find.text('See a doctor from home'), findsOneWidget);
    });

    testWidgets('loops back to slide 1 after slide 5', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OnboardingScreen(),
        ),
      );

      // Advance through all 5 slides (4s each + 50ms + 400ms transition)
      // Slide 1 -> 2
      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('See a doctor from home'), findsOneWidget);

      // Slide 2 -> 3
      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Your records, in your pocket'), findsOneWidget);

      // Slide 3 -> 4
      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Never miss a dose'), findsOneWidget);

      // Slide 4 -> 5
      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Pay your way'), findsOneWidget);

      // Slide 5 -> loops back to 1!
      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Book in seconds'), findsOneWidget);
    });
  });
}
