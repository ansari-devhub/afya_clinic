import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_motion.dart';

/// Represents the destination after splash screen initialization
enum SplashDestination {
  onboarding,
  login,
  home,
}

/// Controller for splash screen initialization and routing logic.
///
/// Handles:
/// - Firebase initialization
/// - Reading onboarding completion status
/// - Checking authentication state
/// - Enforcing minimum splash duration
/// - Timeout handling for failed initialization
class SplashController extends ChangeNotifier {
  SplashDestination? _destination;
  String? _errorMessage;
  bool _isInitialized = false;

  SplashDestination? get destination => _destination;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;

  /// Key for storing onboarding completion status
  static const String _onboardingSeenKey = 'onboarding_seen';

  /// Initialize the app and determine the destination route.
  ///
  /// Runs Firebase init, reads local storage, checks auth state.
  /// Enforces minimum splash time and respects timeout.
  Future<void> initialize() async {
    final startTime = DateTime.now();

    try {
      // Run initialization tasks with timeout
      await Future.any([
        _runInitializationTasks(),
        Future.delayed(AppMotion.splashTimeout, () {
          throw TimeoutException(
            'Initialization timed out after ${AppMotion.splashTimeout.inSeconds}s',
          );
        }),
      ]);
    } on TimeoutException catch (e) {
      debugPrint('Splash initialization timeout: $e');
      _errorMessage = 'Initialization timed out';
      // On timeout, default to onboarding
      _destination = SplashDestination.onboarding;
    } catch (e) {
      debugPrint('Splash initialization error: $e');
      _errorMessage = e.toString();
      // On error, default to onboarding (safest fallback)
      _destination = SplashDestination.onboarding;
    }

    // Enforce minimum splash duration so animation completes
    final elapsed = DateTime.now().difference(startTime);
    final remaining = AppMotion.splashMinimumDuration - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Run all initialization tasks and determine destination
  Future<void> _runInitializationTasks() async {
    // 1. Initialize Firebase (if not already initialized)
    try {
      await Firebase.initializeApp();
      debugPrint('Firebase initialized successfully');
    } catch (e) {
      // Firebase might already be initialized (in main.dart)
      debugPrint('Firebase initialization: $e');
    }

    // 2. Read local storage for onboarding status
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool(_onboardingSeenKey) ?? false;

    // 3. Check authentication state
    // TODO: Replace with actual auth check when auth service is ready
    // For now, we'll use a simple check
    final isLoggedIn = await _checkAuthStatus();

    // 4. Determine destination based on state
    if (isLoggedIn) {
      _destination = SplashDestination.home;
    } else if (!hasSeenOnboarding) {
      _destination = SplashDestination.onboarding;
    } else {
      _destination = SplashDestination.login;
    }

    debugPrint('Splash destination determined: $_destination');
  }

  /// Check if user is currently authenticated
  ///
  /// TODO: Integrate with actual AuthService/AuthProvider
  Future<bool> _checkAuthStatus() async {
    try {
      // Placeholder: check if there's a stored auth token or user ID
      final prefs = await SharedPreferences.getInstance();
      final hasAuthToken = prefs.containsKey('auth_token');
      return hasAuthToken;
    } catch (e) {
      debugPrint('Auth check error: $e');
      return false;
    }
  }

  /// Mark onboarding as seen (call this after onboarding completes)
  static Future<void> markOnboardingSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingSeenKey, true);
      debugPrint('Onboarding marked as seen');
    } catch (e) {
      debugPrint('Failed to mark onboarding as seen: $e');
    }
  }

  /// Clear onboarding status (useful for testing)
  static Future<void> clearOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_onboardingSeenKey);
      debugPrint('Onboarding status cleared');
    } catch (e) {
      debugPrint('Failed to clear onboarding status: $e');
    }
  }
}
