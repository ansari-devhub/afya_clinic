import 'package:flutter/material.dart';
import '../../../../core/theme/clinical_tokens.dart';

/// Log out button matching the spec:
/// - Danger-tint background and border, danger icon and text
/// - Opens confirm dialog, then triggers onLogout
/// - Minimum 44px touch target
class LogoutButton extends StatelessWidget {
  final Future<void> Function() onLogout;
  final String appVersion;

  const LogoutButton({
    super.key,
    required this.onLogout,
    this.appVersion = '1.0.0',
  });

  void _showConfirmDialog(BuildContext context, ClinicalTokens tokens) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tokens.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ClinicalTokens.radiusCard),
          side: BorderSide(
            color: tokens.border,
            width: ClinicalTokens.borderWidth,
          ),
        ),
        title: Text(
          'Log out',
          style: tokens.headlineStyle.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to log out of your clinical session?',
          style: tokens.bodyStyle.copyWith(
            color: tokens.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: tokens.bodyStyle.copyWith(
                color: tokens.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: tokens.danger,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ClinicalTokens.radiusPill),
              ),
            ),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = ClinicalTokens.of(context);

    return Column(
      children: [
        // Danger-tint Log out button
        Semantics(
          button: true,
          label: 'Log out of clinic',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showConfirmDialog(context, tokens),
              borderRadius: BorderRadius.circular(ClinicalTokens.radiusCard),
              child: Container(
                constraints: const BoxConstraints(minHeight: 48),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: tokens.dangerContainer,
                  borderRadius: BorderRadius.circular(ClinicalTokens.radiusCard),
                  border: Border.all(
                    color: tokens.danger.withValues(alpha: 0.60),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      size: ClinicalTokens.defaultIconSize,
                      color: tokens.danger,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Log out',
                      style: tokens.cardTitleStyle.copyWith(
                        color: tokens.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // App version text (11 secondary)
        Text(
          'App version $appVersion',
          style: tokens.secondaryStyle.copyWith(
            color: tokens.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
