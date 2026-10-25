import 'dart:async';
import '../../../models/user_model.dart';
export '../../../models/user_model.dart' show UserRole;

/// Result object returned by auth operations.
class AuthResult {
  final bool isSuccess;
  final String? userId;
  final String? email;
  final String? name;
  final UserRole? role;
  final String? errorMessage;

  const AuthResult({
    required this.isSuccess,
    this.userId,
    this.email,
    this.name,
    this.role,
    this.errorMessage,
  });

  factory AuthResult.success({
    required String userId,
    String? email,
    String? name,
    UserRole? role,
  }) {
    return AuthResult(
      isSuccess: true,
      userId: userId,
      email: email,
      name: name,
      role: role,
    );
  }

  factory AuthResult.failure(String message) {
    return AuthResult(
      isSuccess: false,
      errorMessage: message,
    );
  }
}

/// Abstract authentication repository contract.
abstract class AuthRepository {
  Future<AuthResult> login({
    required String identifier,
    required String password,
  });

  Future<AuthResult> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  });

  Future<AuthResult> loginWithGoogle();

  Future<AuthResult> loginWithBiometrics();
}

/// Fake in-memory auth repository implementation for UI testing and mock workflows.
class FakeAuthRepository implements AuthRepository {
  final Duration latency;

  const FakeAuthRepository({
    this.latency = const Duration(milliseconds: 1000),
  });

  // Mock user database with proper credentials and roles
  static const Map<String, Map<String, dynamic>> _mockUsers = {
    'admin@afya.com': {
      'password': 'admin123',
      'userId': 'admin-001',
      'name': 'Admin User',
      'role': UserRole.admin,
    },
    'admin@test.com': {
      'password': 'test123456',
      'userId': 'admin-002',
      'name': 'Admin User',
      'role': UserRole.admin,
    },
    'doctor@afya.com': {
      'password': 'doctor123',
      'userId': 'doctor-001',
      'name': 'Dr. Sarah Jenkins',
      'role': UserRole.doctor,
    },
    'doctor@test.com': {
      'password': 'test123456',
      'userId': 'doctor-002',
      'name': 'Dr. Test Doctor',
      'role': UserRole.doctor,
    },
    'patient@afya.com': {
      'password': 'patient123',
      'userId': 'patient-001',
      'name': 'John Doe',
      'role': UserRole.patient,
    },
    'patient@example.com': {
      'password': 'password123',
      'userId': 'patient-002',
      'name': 'John Doe',
      'role': UserRole.patient,
    },
    'patient@afyaclinic.co.ke': {
      'password': 'password123',
      'userId': 'patient-003',
      'name': 'John Doe',
      'role': UserRole.patient,
    },
    'patient@test.com': {
      'password': 'test123456',
      'userId': 'patient-004',
      'name': 'Test Patient',
      'role': UserRole.patient,
    },
  };

  @override
  Future<AuthResult> login({
    required String identifier,
    required String password,
  }) async {
    await Future.delayed(latency);

    // Validate password length
    if (password.length < 8) {
      return AuthResult.failure('Password must be at least 8 characters long');
    }

    // Normalize email identifier - trim and lowercase
    final email = identifier.trim().toLowerCase();

    // If it doesn't contain @, it's not a valid email for this system
    if (!email.contains('@')) {
      return AuthResult.failure('Please enter a valid email address');
    }

    // Check if user exists
    if (!_mockUsers.containsKey(email)) {
      return AuthResult.failure('No user found with this email');
    }

    final userData = _mockUsers[email]!;

    // Verify password matches
    if (userData['password'] != password) {
      return AuthResult.failure('Incorrect password');
    }

    // Return success with user data including role
    return AuthResult.success(
      userId: userData['userId'] as String,
      email: email,
      name: userData['name'] as String,
      role: userData['role'] as UserRole,
    );
  }

  @override
  Future<AuthResult> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    await Future.delayed(latency);

    return AuthResult.success(
      userId: 'mock-user-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: fullName,
      role: UserRole.patient, // Default role for new signups
    );
  }

  @override
  Future<AuthResult> loginWithGoogle() async {
    await Future.delayed(latency);
    return AuthResult.success(
      userId: 'google-user-123',
      email: 'patient.google@gmail.com',
      name: 'Google Patient',
      role: UserRole.patient,
    );
  }

  @override
  Future<AuthResult> loginWithBiometrics() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return AuthResult.success(
      userId: 'bio-user-456',
      email: 'patient.bio@afyaclinic.co.ke',
      name: 'Biometric Patient',
      role: UserRole.patient,
    );
  }
}
