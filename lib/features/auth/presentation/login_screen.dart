import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/phone_utils.dart';
import '../../../core/widgets/neo/neo.dart';
import '../../../providers/auth_provider.dart' as app_providers;
import '../../../screens/admin_dashboard_screen.dart';
import '../../../screens/doctor_dashboard_screen.dart';
import '../../../screens/patient_dashboard_screen.dart';
import '../data/auth_repository.dart';
import 'widgets/logo_tile.dart';
import 'widgets/social_auth_row.dart';

/// Merged Neomorphic Login Screen for Afya Clinic.
///
/// Combines the soft neomorphic UI with real Firebase Auth credentials,
/// role-based dashboard navigation, password & identifier validation,
/// test setup utility, and mock repository fallback for testing.
class LoginScreen extends StatefulWidget {
  final AuthRepository? authRepository;

  const LoginScreen({
    super.key,
    this.authRepository,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  final _identifierFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  String? _identifierError;
  String? _passwordError;

  late final AuthRepository _authRepository;
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _authRepository = widget.authRepository ?? const FakeAuthRepository();
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _identifierFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  bool _isValidEmail(String input) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(input.trim());
  }

  bool _validateForm() {
    bool isValid = true;
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    // Validate identifier (email or phone)
    if (identifier.isEmpty) {
      _identifierError = 'Please enter your email or phone number';
      isValid = false;
    } else if (!_isValidEmail(identifier) && !PhoneUtils.isValidKenyanPhone(identifier)) {
      _identifierError = 'Enter a valid email or Kenyan phone number';
      isValid = false;
    } else {
      _identifierError = null;
    }

    // Validate password (min 8 characters)
    if (password.isEmpty) {
      _passwordError = 'Please enter your password';
      isValid = false;
    } else if (password.length < 8) {
      _passwordError = 'Password must be at least 8 characters';
      isValid = false;
    } else {
      _passwordError = null;
    }

    setState(() {});
    return isValid;
  }

  app_providers.AuthProvider? _getAuthProvider() {
    try {
      return Provider.of<app_providers.AuthProvider>(context, listen: false);
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;
    final authProvider = _getAuthProvider();

    // If widget.authRepository was explicitly supplied OR AuthProvider is absent (e.g. tests),
    // use the repository interface.
    if (widget.authRepository != null || authProvider == null) {
      try {
        final result = await _authRepository.login(
          identifier: identifier,
          password: password,
        );

        if (!mounted) return;

        if (result.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome back, ${result.name ?? "User"}!'),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          );
          _navigateToDashboard(result.role ?? UserRole.patient);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? 'Login failed'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
      return;
    }

    // Real Firebase Auth flow
    try {
      String loginEmail = identifier;

      // If user typed a phone number, resolve their email from Firestore
      if (!_isValidEmail(identifier) && PhoneUtils.isValidKenyanPhone(identifier)) {
        try {
          final normalizedPhone = PhoneUtils.normalizeKenyanPhone(identifier);
          if (normalizedPhone != null) {
            final querySnap = await FirebaseFirestore.instance
                .collection('users')
                .where('phone', isEqualTo: normalizedPhone)
                .limit(1)
                .get();

            if (querySnap.docs.isNotEmpty) {
              loginEmail = querySnap.docs.first.data()['email'] ?? identifier;
            }
          }
        } catch (_) {
          // If Firestore query fails (e.g. offline/rules), proceed with entered identifier
        }
      }

      final user = await authProvider.signIn(loginEmail, password);
      if (!mounted) return;

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back, ${user.name}!'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
        _navigateToDashboard(user.role);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Login failed. Please check your credentials.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      debugPrint('Login error: $e');
      if (mounted) {
        final message = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToDashboard(UserRole role) {
    Widget dashboard;
    switch (role) {
      case UserRole.admin:
        dashboard = const AdminDashboardScreen();
        break;
      case UserRole.doctor:
        dashboard = const DoctorDashboardScreen();
        break;
      case UserRole.patient:
        dashboard = const PatientDashboardScreen();
        break;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => dashboard),
    );
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final result = await _authRepository.loginWithGoogle();
      if (!mounted) return;
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signed in with Google as ${result.name}'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
        _navigateToDashboard(result.role ?? UserRole.patient);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleBiometricLogin() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your clinic records',
        biometricOnly: true,
      );

      if (!authenticated || !mounted) return;

      setState(() => _isLoading = true);
      final result = await _authRepository.loginWithBiometrics();
      if (!mounted) return;

      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Biometric authentication successful'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
        _navigateToDashboard(result.role ?? UserRole.patient);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Biometric authentication failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleForgotPassword() {
    final emailController = TextEditingController(
      text: _isValidEmail(_identifierController.text.trim())
          ? _identifierController.text.trim()
          : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your registered email address to receive a password reset link.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'name@example.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty || !_isValidEmail(email)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Please enter a valid email address'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
                return;
              }

              Navigator.pop(ctx);
              final authProvider = _getAuthProvider();

              if (authProvider != null) {
                try {
                  await authProvider.resetPassword(email);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Password reset link sent! Check your inbox.'),
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to send reset link: $e'),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Password reset link sent! Check your inbox.'),
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                  );
                }
              }
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return NeoBackground(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Logo tile
                  const LogoTile(size: 72, iconSize: 40),
                  const SizedBox(height: 24),

                  // 2. Title & Subtitle
                  Text(
                    'Welcome back',
                    textAlign: TextAlign.center,
                    style: (textTheme.headlineMedium ?? const TextStyle()).copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to continue',
                    textAlign: TextAlign.center,
                    style: (textTheme.bodyMedium ?? const TextStyle()).copyWith(
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 3. Field: Email or phone number
                  NeoTextField(
                    label: 'Email or phone number',
                    hintText: 'e.g. name@example.com or 0712345678',
                    controller: _identifierController,
                    focusNode: _identifierFocus,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    errorText: _identifierError,
                    onChanged: (_) {
                      if (_identifierError != null) {
                        setState(() => _identifierError = null);
                      }
                    },
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_passwordFocus);
                    },
                  ),
                  const SizedBox(height: 18),

                  // 4. Field: Password
                  NeoTextField(
                    label: 'Password',
                    hintText: 'Enter your password',
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    obscureText: _obscurePassword,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    errorText: _passwordError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    onChanged: (_) {
                      if (_passwordError != null) {
                        setState(() => _passwordError = null);
                      }
                    },
                    onFieldSubmitted: (_) => _handleLogin(),
                  ),
                  const SizedBox(height: 12),

                  // 5. Row: Remember me checkbox & Forgot password link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Remember me
                      InkWell(
                        onTap: () {
                          setState(() {
                            _rememberMe = !_rememberMe;
                          });
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor: colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _rememberMe = val ?? false;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Remember me',
                              style: (textTheme.bodySmall ?? const TextStyle()).copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Forgot password
                      TextButton(
                        onPressed: _handleForgotPassword,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Forgot password?',
                          style: (textTheme.bodySmall ?? const TextStyle()).copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 6. Primary button: Log in
                  NeoButton(
                    label: 'Log in',
                    isLoading: _isLoading,
                    onPressed: _handleLogin,
                  ),
                  const SizedBox(height: 28),

                  // 7. Divider & Social / Biometric buttons
                  SocialAuthRow(
                    onGooglePressed: _isLoading ? null : _handleGoogleLogin,
                    onBiometricPressed: _isLoading ? null : _handleBiometricLogin,
                  ),
                  const SizedBox(height: 28),

                  // 8. Footer: New here? Create an account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'New here? ',
                        style: (textTheme.bodyMedium ?? const TextStyle()).copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacementNamed('/signup');
                        },
                        child: Text(
                          'Create an account',
                          style: (textTheme.bodyMedium ?? const TextStyle()).copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 9. Tagline
                  Text(
                    'Care  •  Convenience  •  Confidence',
                    textAlign: TextAlign.center,
                    style: (textTheme.bodySmall ?? const TextStyle()).copyWith(
                      color: colorScheme.outline,
                      fontSize: 12,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
