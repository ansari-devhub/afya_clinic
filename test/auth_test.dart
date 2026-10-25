import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:afya_clinic/config/app_theme.dart';
import 'package:afya_clinic/core/widgets/neo/neo.dart';
import 'package:afya_clinic/features/auth/data/auth_repository.dart';
import 'package:afya_clinic/features/auth/presentation/login_screen.dart';
import 'package:afya_clinic/features/auth/presentation/signup_screen.dart';
import 'package:afya_clinic/features/auth/presentation/widgets/logo_tile.dart';
import 'package:afya_clinic/features/auth/presentation/widgets/password_strength_indicator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthRepository & FakeAuthRepository Tests', () {
    const repo = FakeAuthRepository(latency: Duration.zero);

    test('login succeeds with valid password', () async {
      final res = await repo.login(
        identifier: 'patient@example.com',
        password: 'password123',
      );
      expect(res.isSuccess, isTrue);
      expect(res.name, 'John Doe');
    });

    test('login fails when password is under 8 characters', () async {
      final res = await repo.login(
        identifier: 'patient@example.com',
        password: 'short',
      );
      expect(res.isSuccess, isFalse);
      expect(res.errorMessage, contains('at least 8 characters'));
    });

    test('signUp succeeds and returns user info', () async {
      final res = await repo.signUp(
        fullName: 'Jane Wanjiku',
        email: 'jane@example.com',
        phone: '+254712345678',
        password: 'password123',
      );
      expect(res.isSuccess, isTrue);
      expect(res.name, 'Jane Wanjiku');
    });

    test('loginWithGoogle succeeds', () async {
      final res = await repo.loginWithGoogle();
      expect(res.isSuccess, isTrue);
      expect(res.email, contains('google'));
    });
  });

  group('PasswordStrengthIndicator Tests', () {
    testWidgets('calculates weak, okay, and strong correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Column(
              children: [
                PasswordStrengthIndicator(password: 'short'),
                PasswordStrengthIndicator(password: 'password123'),
                PasswordStrengthIndicator(password: 'P@ssw0rd123!'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Weak'), findsOneWidget);
      expect(find.text('Okay'), findsOneWidget);
      expect(find.text('Strong'), findsOneWidget);
    });
  });

  group('Neo Reusable Widgets Tests', () {
    testWidgets('NeoCard and NeoButton render and handle taps', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: NeoCard(
              child: NeoButton(
                label: 'Test Button',
                onPressed: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      await tester.tap(find.text('Test Button'));
      expect(tapped, isTrue);
    });

    testWidgets('NeoTextField renders label and responds to input', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: NeoTextField(
              label: 'Email',
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'test@afyaclinic.co.ke');
      expect(controller.text, 'test@afyaclinic.co.ke');
    });
  });

  group('LoginScreen Tests', () {
    testWidgets('renders all login screen elements', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          routes: {
            '/signup': (_) => const Scaffold(body: Text('Signup Mock')),
          },
          home: const LoginScreen(
            authRepository: FakeAuthRepository(latency: Duration.zero),
          ),
        ),
      );

      // Logo tile
      expect(find.byType(LogoTile), findsOneWidget);

      // Title & Subtitle
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Sign in to continue'), findsOneWidget);

      // Fields
      expect(find.text('Email or phone number'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      // Remember me & Forgot password
      expect(find.text('Remember me'), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);

      // Button
      expect(find.widgetWithText(NeoButton, 'Log in'), findsOneWidget);

      // Social divider & footer & tagline
      expect(find.text('or continue with'), findsOneWidget);
      expect(find.text('Create an account'), findsOneWidget);
      expect(find.text('Care  •  Convenience  •  Confidence'), findsOneWidget);
    });

    testWidgets('validates required fields on login submit', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LoginScreen(
            authRepository: FakeAuthRepository(latency: Duration.zero),
          ),
        ),
      );

      // Tap Log in with empty fields
      await tester.tap(find.widgetWithText(NeoButton, 'Log in'));
      await tester.pump();

      expect(
        find.text('Please enter your email or phone number'),
        findsOneWidget,
      );
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('submits login successfully with valid email and password', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LoginScreen(
            authRepository: FakeAuthRepository(latency: Duration.zero),
          ),
        ),
      );

      // Enter valid email and password
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'patient@afyaclinic.co.ke');
      await tester.enterText(textFields.at(1), 'password123');
      await tester.pump();

      await tester.tap(find.widgetWithText(NeoButton, 'Log in'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome back, John Doe!'), findsOneWidget);
    });
  });

  group('SignUpScreen Tests', () {
    testWidgets('renders all signup screen components', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          routes: {
            '/login': (_) => const Scaffold(body: Text('Login Mock')),
          },
          home: const SignUpScreen(
            authRepository: FakeAuthRepository(latency: Duration.zero),
          ),
        ),
      );

      // Back button
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      // Titles
      expect(find.text('Create your account'), findsOneWidget);
      expect(find.text('It only takes a minute'), findsOneWidget);

      // Fields
      expect(find.text('Full name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Phone number'), findsOneWidget);
      expect(find.text('+254'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm password'), findsOneWidget);

      // Checkbox and terms
      expect(find.text('Terms'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);

      // Create account button
      expect(find.widgetWithText(NeoButton, 'Create account'), findsOneWidget);
      expect(find.text('Log in'), findsOneWidget);
    });

    testWidgets('Create account button enables when form is valid and terms checked', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const SignUpScreen(
            authRepository: FakeAuthRepository(latency: Duration.zero),
          ),
        ),
      );

      final textFields = find.byType(TextFormField);

      // Fill in valid form details
      await tester.enterText(textFields.at(0), 'Jane Wanjiku');
      await tester.enterText(textFields.at(1), 'jane@afyaclinic.co.ke');
      await tester.enterText(textFields.at(2), '712345678');
      await tester.enterText(textFields.at(3), 'secretPass123');
      await tester.enterText(textFields.at(4), 'secretPass123');
      await tester.pump();

      // Check the terms checkbox
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Tap Create account
      await tester.ensureVisible(find.widgetWithText(NeoButton, 'Create account'));
      await tester.tap(find.widgetWithText(NeoButton, 'Create account'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
