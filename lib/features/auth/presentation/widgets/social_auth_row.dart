import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../config/app_assets.dart';
import '../../../../core/widgets/neo/neo_icon_button.dart';

/// Social and biometric authentication row.
///
/// Features:
/// - Divider with "or continue with"
/// - Google auth raised square button
/// - Biometric fingerprint button (automatically hidden if device lacks hardware support)
class SocialAuthRow extends StatefulWidget {
  final VoidCallback? onGooglePressed;
  final VoidCallback? onBiometricPressed;

  const SocialAuthRow({
    super.key,
    this.onGooglePressed,
    this.onBiometricPressed,
  });

  @override
  State<SocialAuthRow> createState() => _SocialAuthRowState();
}

class _SocialAuthRowState extends State<SocialAuthRow> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricsSupport();
  }

  Future<void> _checkBiometricsSupport() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      if (mounted) {
        setState(() {
          _canCheckBiometrics = isSupported && canCheck;
        });
      }
    } catch (_) {
      // Gracefully fall back to non-biometric if exception occurs (e.g. desktop/unsupported platform)
      if (mounted) {
        setState(() {
          _canCheckBiometrics = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final dividerColor = colorScheme.outlineVariant.withValues(alpha: 0.50);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // "or continue with" Divider
        Row(
          children: [
            Expanded(child: Divider(color: dividerColor, thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or continue with',
                style: (textTheme.bodySmall ?? const TextStyle()).copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(child: Divider(color: dividerColor, thickness: 1)),
          ],
        ),
        const SizedBox(height: 20),

        // Action buttons row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google Button
            NeoIconButton(
              tooltip: 'Sign in with Google',
              onPressed: widget.onGooglePressed,
              icon: SvgPicture.asset(
                AppAssets.google,
                width: 24,
                height: 24,
              ),
            ),

            // Biometric Button (shown only if supported)
            if (_canCheckBiometrics) ...[
              const SizedBox(width: 20),
              NeoIconButton(
                tooltip: 'Sign in with Biometrics',
                onPressed: widget.onBiometricPressed,
                icon: Icon(
                  Icons.fingerprint_rounded,
                  size: 26,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
