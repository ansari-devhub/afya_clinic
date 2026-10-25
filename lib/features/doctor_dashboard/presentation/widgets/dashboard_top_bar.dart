import 'package:flutter/material.dart';
import '../../../../core/theme/clinical_tokens.dart';
import '../../data/models/doctor_dashboard_data.dart';

/// Section 1: Top bar
///
/// Specs:
/// - App logo icon in a rounded-square (9px radius) filled primary tile, 34px.
/// - Next to it, a two-line block: "Good morning" (secondary, time-of-day aware) and the doctor's name (card title weight).
/// - Bell icon on the right with a danger-colored dot when unread notifications exist; tap opens notifications.
/// - No profile avatar (Profile is a nav tab).
/// - Minimum 44px touch target on bell icon with semantic label.
class DashboardTopBar extends StatelessWidget {
  final DoctorProfile doctor;
  final VoidCallback? onNotificationsTap;

  const DashboardTopBar({
    super.key,
    required this.doctor,
    this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = ClinicalTokens.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // App logo icon in 9px radius filled primary tile, 34px
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: tokens.primary,
            borderRadius: BorderRadius.circular(ClinicalTokens.radiusTile),
          ),
          child: Center(
            child: Icon(
              Icons.local_hospital_rounded,
              size: 20,
              color: tokens.onPrimary,
            ),
          ),
        ),
        const SizedBox(width: ClinicalTokens.rowGap),

        // Greeting and Doctor's Name
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                doctor.getGreeting(),
                style: tokens.secondaryStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                doctor.displayName,
                style: tokens.cardTitleStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Bell icon with danger unread indicator
        Semantics(
          button: true,
          label: doctor.unreadNotificationsCount > 0
              ? 'Notifications, ${doctor.unreadNotificationsCount} unread'
              : 'Notifications',
          child: InkWell(
            onTap: onNotificationsTap,
            borderRadius: BorderRadius.circular(22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 44,
              ),
              child: Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      size: ClinicalTokens.defaultIconSize + 2,
                      color: tokens.textPrimary,
                    ),
                    if (doctor.unreadNotificationsCount > 0)
                      Positioned(
                        top: -1,
                        right: -1,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: tokens.danger,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: tokens.background,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
