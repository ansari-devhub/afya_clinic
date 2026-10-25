import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

/// Bottom sheet card for the onboarding screen.
///
/// Contains:
/// - Rounded top corners (radius 24)
/// - Title: "Welcome to [AppName]"
/// - Subtitle (grey, 2 lines max): "Quality care, right from your phone."
/// - Primary filled button (full width, height 52, radius 8): "Log in"
/// - Secondary outlined button (same size): "Sign up"
class OnboardingBottomSheet extends StatelessWidget {
  final String appName;
  final VoidCallback? onLogin;
  final VoidCallback? onSignUp;

  const OnboardingBottomSheet({
    super.key,
    this.appName = 'Afya Clinic',
    this.onLogin,
    this.onSignUp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXl), // 24.0
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingLg, // 24.0
            vertical: AppTheme.spacingLg,   // 24.0
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                'Welcome to $appName',
                textAlign: TextAlign.center,
                style: (textTheme.headlineSmall ?? const TextStyle()).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm), // 8.0

              // Subtitle
              Text(
                'Quality care, right from your phone.',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: (textTheme.bodyMedium ?? const TextStyle()).copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg), // 24.0

              // Primary Filled Button: "Log in"
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: onLogin ?? () => Navigator.of(context).pushNamed('/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusDefault), // 8.0
                    ),
                    textStyle: (textTheme.titleMedium ?? const TextStyle()).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  child: const Text('Log in'),
                ),
              ),
              const SizedBox(height: 12),

              // Secondary Outlined Button: "Sign up"
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: onSignUp ?? () => Navigator.of(context).pushNamed('/signup'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    minimumSize: const Size.fromHeight(52),
                    side: BorderSide(
                      color: colorScheme.primary,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusDefault), // 8.0
                    ),
                    textStyle: (textTheme.titleMedium ?? const TextStyle()).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  child: const Text('Sign up'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
