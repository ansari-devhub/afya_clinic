import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/phone_utils.dart';
import '../../../core/widgets/neo/neo.dart';
import '../../../providers/auth_provider.dart' as app_providers;
import '../data/auth_repository.dart';
import 'widgets/logo_tile.dart';
import 'widgets/password_strength_indicator.dart';

/// Neomorphic Sign Up Screen for Afya Clinic.
class SignUpScreen extends StatefulWidget {
  final AuthRepository? authRepository;

  const SignUpScreen({
    super.key,
    this.authRepository,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;

  late final AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();
    _authRepository = widget.authRepository ?? const FakeAuthRepository();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();

    super.dispose();
  }

  app_providers.AuthProvider? _getAuthProvider() {
    try {
      return Provider.of<app_providers.AuthProvider>(context, listen: false);
    } catch (_) {
      return null;
    }
  }

  bool _isValidEmail(String input) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(input.trim());
  }

  bool _validateForm() {
    bool isValid = true;

    // Full name
    if (_nameController.text.trim().isEmpty) {
      _nameError = 'Please enter your full name';
      isValid = false;
    } else {
      _nameError = null;
    }

    // Email
    if (_emailController.text.trim().isEmpty) {
      _emailError = 'Please enter your email';
      isValid = false;
    } else if (!_isValidEmail(_emailController.text)) {
      _emailError = 'Please enter a valid email address';
      isValid = false;
    } else {
      _emailError = null;
    }

    // Phone
    if (_phoneController.text.trim().isEmpty) {
      _phoneError = 'Please enter your phone number';
      isValid = false;
    } else if (!PhoneUtils.isValidKenyanPhone(_phoneController.text)) {
      _phoneError = 'Enter a valid 9-digit Kenyan phone number';
      isValid = false;
    } else {
      _phoneError = null;
    }

    // Password
    if (_passwordController.text.isEmpty) {
      _passwordError = 'Please enter a password';
      isValid = false;
    } else if (_passwordController.text.length < 8) {
      _passwordError = 'Password must be at least 8 characters';
      isValid = false;
    } else {
      _passwordError = null;
    }

    // Confirm password
    if (_confirmPasswordController.text.isEmpty) {
      _confirmPasswordError = 'Please confirm your password';
      isValid = false;
    } else if (_confirmPasswordController.text != _passwordController.text) {
      _confirmPasswordError = 'Passwords do not match';
      isValid = false;
    } else {
      _confirmPasswordError = null;
    }

    setState(() {});
    return isValid && _agreeToTerms;
  }

  bool get _isFormReadyToSubmit {
    return _nameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _isValidEmail(_emailController.text) &&
        _phoneController.text.trim().isNotEmpty &&
        PhoneUtils.isValidKenyanPhone(_phoneController.text) &&
        _passwordController.text.length >= 8 &&
        _confirmPasswordController.text == _passwordController.text &&
        _agreeToTerms;
  }

  Future<void> _handleSignUp() async {
    FocusScope.of(context).unfocus();

    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    final normalizedPhone =
        PhoneUtils.normalizeKenyanPhone(_phoneController.text) ??
            _phoneController.text.trim();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final authProvider = _getAuthProvider();

    // If widget.authRepository was explicitly supplied OR AuthProvider is absent (e.g. tests),
    // use the repository interface.
    if (widget.authRepository != null || authProvider == null) {
      try {
        final result = await _authRepository.signUp(
          fullName: name,
          email: email,
          phone: normalizedPhone,
          password: password,
        );

        if (!mounted) return;

        if (result.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Account created for ${result.name}! Please sign in.'),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          );
          Navigator.of(context).pushReplacementNamed('/login');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? 'Sign up failed'),
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
        if (mounted) setState(() => _isLoading = false);
      }
      return;
    }

    // Real Firebase Auth flow
    try {
      await authProvider.signUp(
        email: email,
        password: password,
        name: name,
        role: UserRole.patient,
        phone: normalizedPhone,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account created for $name! Please sign in.'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showPolicyDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(content),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 7. Back arrow top-left returning to previous screen
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: colorScheme.onSurface,
                      tooltip: 'Back',
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),

                  // Logo tile (smaller than login)
                  const LogoTile(size: 56, iconSize: 32),
                  const SizedBox(height: 16),

                  // 1. Title & Subtitle
                  Text(
                    'Create your account',
                    textAlign: TextAlign.center,
                    style: (textTheme.headlineMedium ?? const TextStyle()).copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'It only takes a minute',
                    textAlign: TextAlign.center,
                    style: (textTheme.bodyMedium ?? const TextStyle()).copyWith(
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 0.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Field: Full name
                  NeoTextField(
                    label: 'Full name',
                    hintText: 'e.g. Jane Wanjiku',
                    controller: _nameController,
                    focusNode: _nameFocus,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    errorText: _nameError,
                    onChanged: (_) => setState(() {}),
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_emailFocus);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Field: Email
                  NeoTextField(
                    label: 'Email',
                    hintText: 'e.g. jane@example.com',
                    controller: _emailController,
                    focusNode: _emailFocus,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.email_outlined),
                    errorText: _emailError,
                    onChanged: (_) => setState(() {}),
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_phoneFocus);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Field: Phone number (+254 prefix chip, digits only)
                  NeoTextField(
                    label: 'Phone number',
                    hintText: '712 345 678',
                    controller: _phoneController,
                    focusNode: _phoneFocus,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    prefix: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+254',
                        style: (textTheme.bodyMedium ?? const TextStyle()).copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    errorText: _phoneError,
                    onChanged: (_) => setState(() {}),
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_passwordFocus);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Field: Password
                  NeoTextField(
                    label: 'Password',
                    hintText: 'At least 8 characters',
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    obscureText: _obscurePassword,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.next,
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
                    onChanged: (_) => setState(() {}),
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_confirmPasswordFocus);
                    },
                  ),

                  // 3. Password strength hint under password field
                  PasswordStrengthIndicator(password: _passwordController.text),
                  const SizedBox(height: 16),

                  // Field: Confirm password
                  NeoTextField(
                    label: 'Confirm password',
                    hintText: 'Re-enter your password',
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocus,
                    obscureText: _obscureConfirmPassword,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    errorText: _confirmPasswordError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    onChanged: (_) => setState(() {}),
                    onFieldSubmitted: (_) => _handleSignUp(),
                  ),
                  const SizedBox(height: 18),

                  // 4. Checkbox: "I agree to the Terms and Privacy Policy" (links tappable)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _agreeToTerms,
                          activeColor: colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _agreeToTerms = val ?? false;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'I agree to the ',
                              style: (textTheme.bodySmall ?? const TextStyle()).copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showPolicyDialog(
                                'Terms of Service',
                                'Afya Clinic Terms of Service ensure patient confidentiality, secure medical handling, and transparent consultations.',
                              ),
                              child: Text(
                                'Terms',
                                style: (textTheme.bodySmall ?? const TextStyle()).copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            Text(
                              ' and ',
                              style: (textTheme.bodySmall ?? const TextStyle()).copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showPolicyDialog(
                                'Privacy Policy',
                                'Your healthcare data and consultations are encrypted and strictly protected under health data privacy guidelines.',
                              ),
                              child: Text(
                                'Privacy Policy',
                                style: (textTheme.bodySmall ?? const TextStyle()).copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 5. Primary button: "Create account", disabled until valid and checked
                  NeoButton(
                    label: 'Create account',
                    isLoading: _isLoading,
                    onPressed: _isFormReadyToSubmit ? _handleSignUp : null,
                  ),
                  const SizedBox(height: 24),

                  // 6. Footer: "Already have an account? Log in"
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: (textTheme.bodyMedium ?? const TextStyle()).copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                        child: Text(
                          'Log in',
                          style: (textTheme.bodyMedium ?? const TextStyle()).copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
