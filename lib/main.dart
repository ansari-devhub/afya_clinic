import 'package:afya_clinic/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'providers/firebase_providers.dart';
import 'providers/auth_provider.dart' as app_providers;
import 'services/auth_service.dart';
import 'services/patient_service.dart';
import 'services/appointment_service.dart';
import 'screens/patient_dashboard_screen.dart';
import 'screens/doctor_dashboard_screen.dart';
import 'screens/doctor_schedule_screen.dart';
import 'screens/doctor_profile_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/signup_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'core/theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (optional - will fail gracefully if offline)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization failed (using mock auth): $e');
  }

  runApp(const AfyaClinicApp());
}

class AfyaClinicApp extends StatelessWidget {
  const AfyaClinicApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set up Firebase providers and service providers
    return FirebaseProviders(
      child: Builder(
        builder: (context) {
          // Get Firebase instances from providers
          final firebaseAuth = FirebaseAuthProvider.of(context);
          final firestore = FirebaseFirestoreProvider.of(context);

          // Create services with injected dependencies
          final authService = AuthService(
            firebaseAuth: firebaseAuth,
            firestore: firestore,
          );

          final patientService = PatientService(firestore: firestore);
          final appointmentService = AppointmentService(firestore: firestore);

          // Set up service providers
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => app_providers.AuthProvider(authService: authService),
              ),
              Provider<PatientService>.value(value: patientService),
              Provider<AppointmentService>.value(value: appointmentService),
            ],
            child: AnimatedBuilder(
              animation: ClinicalThemeController.instance,
              builder: (context, _) {
                return MaterialApp(
                  title: 'Afya Clinic',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: ClinicalThemeController.instance.themeMode,
                  home: const SplashScreen(),
                  routes: {
                    '/onboarding': (context) => const OnboardingScreen(),
                    '/login': (context) => const LoginScreen(),
                    '/signup': (context) => const SignUpScreen(),
                    '/dashboard': (context) => const PatientDashboardScreen(),
                    '/doctor-dashboard': (context) => const DoctorDashboardScreen(),
                    '/doctor-schedule': (context) => const DoctorScheduleScreen(),
                    '/doctor-profile': (context) => const DoctorProfileScreen(),
                    '/admin-dashboard': (context) => const AdminDashboardScreen(),
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
