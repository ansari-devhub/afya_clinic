import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Provider that manages authentication state
class AuthProvider extends ChangeNotifier {
  final AuthService authService;
  UserModel? _currentUser;
  bool _isLoading = true;
  String? _error;
  StreamSubscription? _authSubscription;

  AuthProvider({required this.authService}) {
    _init();
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get error => _error;

  Future<void> _init() async {
    // Listen to auth state changes
    _authSubscription = authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        _currentUser = await authService.getUserData(firebaseUser.uid);
      } else {
        _currentUser = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<UserModel?> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = await authService.signInWithEmailPassword(email, password);

      // Don't set _isLoading to false here - let the auth state listener handle it
      // but we return the user immediately for navigation
      return user;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phone,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await authService.signUpWithEmailPassword(
        email: email,
        password: password,
        name: name,
        role: role,
        phone: phone,
      );

      // Auth state listener will handle the rest
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    await authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    try {
      await authService.resetPassword(email);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
