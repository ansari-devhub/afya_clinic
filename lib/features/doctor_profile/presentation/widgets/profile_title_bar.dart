import 'package:flutter/material.dart';
import '../../../../core/theme/clinical_tokens.dart';

/// Title bar for Doctor Profile:
/// - In Hero (default): "Profile" (15 medium, on-primary) top-left, 34px translucent-white circle top-right.
/// - Pencil toggles edit mode (pencil becomes check, saves on confirm).
/// - Minimum 44px touch target with semantic label.
class ProfileTitleBar extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onToggleEdit;
  final bool inHero;

  const ProfileTitleBar({
    super.key,
    required this.isEditing,
    required this.onToggleEdit,
    this.inHero = true,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = ClinicalTokens.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Title: "Profile" (15 medium, on-primary when in hero)
        Text(
          'Profile',
          style: tokens.headlineStyle.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: inHero ? tokens.onPrimary : tokens.textPrimary,
          ),
        ),

        // Pencil/check button
        Semantics(
          button: true,
          label: isEditing ? 'Save profile changes' : 'Edit profile details',
          child: InkWell(
            onTap: onToggleEdit,
            borderRadius: BorderRadius.circular(inHero ? 17 : 8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 44,
              ),
              child: Center(
                child: inHero
                    ? Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: isEditing
                              ? Colors.white.withValues(alpha: 0.35)
                              : Colors.white.withValues(alpha: 0.20),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.30),
                            width: ClinicalTokens.borderWidth,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            isEditing ? Icons.check_rounded : Icons.edit_outlined,
                            size: 16,
                            color: tokens.onPrimary,
                          ),
                        ),
                      )
                    : Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isEditing
                              ? tokens.primary.withValues(alpha: 0.12)
                              : tokens.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isEditing ? tokens.primary : tokens.border,
                            width: ClinicalTokens.borderWidth,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            isEditing ? Icons.check_rounded : Icons.edit_outlined,
                            size: 16,
                            color: isEditing ? tokens.primary : tokens.textPrimary,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
