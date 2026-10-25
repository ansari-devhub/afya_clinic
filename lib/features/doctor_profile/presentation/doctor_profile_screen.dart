import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/clinical_tokens.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/floating_role_nav_bar.dart';
import '../../../core/widgets/settings/clinical_settings_group.dart';
import '../../../core/widgets/settings/clinical_settings_row.dart';
import '../../../providers/auth_provider.dart' as app_providers;
import '../data/doctor_profile_repository.dart';
import '../data/models/doctor_profile_data.dart';
import 'widgets/logout_button.dart';
import 'widgets/profile_hero_card.dart';
import 'widgets/profile_skeleton.dart';

/// Doctor Profile screen (4th tab) of the role-based clinical app.
///
/// Follows exact layout & behavior specifications:
/// - Title bar: "Profile" + 32px bordered pencil/check button (inline editing)
/// - Hero card: ~196 tall, gradient, chips, camera button
/// - Stats strip: 3 equal columns (Experience, Patients, Consults)
/// - Availability group: optimistic switches, confirm on turn-off, working hours editor
/// - Professional group: personal info, license, bio, facility
/// - Preferences group: notifications, language, dark mode (instant theme toggle)
/// - Security & privacy group: change password, biometric unlock with device check, sessions, audit
/// - Support group: help, terms & about
/// - Danger Log out button with confirm dialog
/// - App version string
/// - Reusable floating bottom nav with Profile active (index 3)
class DoctorProfileScreen extends StatefulWidget {
  final DoctorProfileRepository? repository;
  final VoidCallback? onNavigateToDashboard;
  final VoidCallback? onNavigateToSchedule;
  final VoidCallback? onNavigateToPatients;

  const DoctorProfileScreen({
    super.key,
    this.repository,
    this.onNavigateToDashboard,
    this.onNavigateToSchedule,
    this.onNavigateToPatients,
  });

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  late final DoctorProfileRepository _repository;
  final LocalAuthentication _localAuth = LocalAuthentication();

  DoctorProfileData? _data;
  bool _isLoading = true;
  String? _errorMessage;

  // Edit mode state & text controllers
  bool _isEditing = false;
  late final TextEditingController _nameController;
  late final TextEditingController _specialtyController;
  late final TextEditingController _facilityController;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? MockDoctorProfileRepository();
    _nameController = TextEditingController();
    _specialtyController = TextEditingController();
    _facilityController = TextEditingController();
    _loadProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    _facilityController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    try {
      final data = await _repository.fetchProfileData();
      if (!mounted) return;
      setState(() {
        _data = data;
        _isLoading = false;
        _errorMessage = null;
        _nameController.text = data.details.name;
        _specialtyController.text = data.details.specialty;
        _facilityController.text = data.details.facility;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _loadProfileData();
  }

  void _toggleEditMode() async {
    if (_data == null) return;

    if (_isEditing) {
      // Save changes
      final updatedDetails = _data!.details.copyWith(
        name: _nameController.text.trim(),
        specialty: _specialtyController.text.trim(),
        facility: _facilityController.text.trim(),
      );

      setState(() {
        _isEditing = false;
        _data = _data!.copyWith(details: updatedDetails);
      });

      try {
        await _repository.updateProfileDetails(updatedDetails);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile details updated successfully'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save changes: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } else {
      // Enter edit mode
      setState(() => _isEditing = true);
    }
  }

  void _onChangePhoto() {
    final tokens = ClinicalTokens.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: tokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: tokens.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Change Profile Photo',
                style: tokens.headlineStyle.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(Icons.camera_alt_outlined, color: tokens.primary),
                title: Text('Take photo', style: tokens.rowLabelStyle),
                onTap: () {
                  Navigator.pop(ctx);
                  _showInfoSnackBar('Camera opened');
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library_outlined, color: tokens.primary),
                title: Text('Choose from gallery', style: tokens.rowLabelStyle),
                onTap: () {
                  Navigator.pop(ctx);
                  _showInfoSnackBar('Gallery opened');
                },
              ),
              if (_data?.details.photoUrl != null)
                ListTile(
                  leading: Icon(Icons.delete_outline_rounded, color: tokens.danger),
                  title: Text(
                    'Remove photo',
                    style: tokens.rowLabelStyle.copyWith(color: tokens.danger),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    if (_data != null) {
                      setState(() {
                        _data = _data!.copyWith(
                          details: _data!.details.copyWith(photoUrl: ''),
                        );
                      });
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _onToggleAcceptingAppointments(bool newValue) {
    if (_data == null) return;

    // Turning off "Accepting appointments" with upcoming bookings opens a confirm dialog
    if (!newValue && _data!.availability.upcomingBookingsCount > 0) {
      final tokens = ClinicalTokens.of(context);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: tokens.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ClinicalTokens.radiusCard),
          ),
          title: Text(
            'Pause Appointments?',
            style: tokens.headlineStyle.copyWith(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'You currently have ${_data!.availability.upcomingBookingsCount} upcoming appointments scheduled. Are you sure you want to stop accepting new bookings?',
            style: tokens.bodyStyle.copyWith(color: tokens.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _applyAcceptingAppointments(false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: tokens.primary,
                foregroundColor: tokens.onPrimary,
              ),
              child: const Text('Pause Bookings'),
            ),
          ],
        ),
      );
    } else {
      _applyAcceptingAppointments(newValue);
    }
  }

  Future<void> _applyAcceptingAppointments(bool newValue) async {
    if (_data == null) return;
    final previousValue = _data!.availability.acceptingAppointments;

    // Optimistic update
    final updatedAvailability = _data!.availability.copyWith(
      acceptingAppointments: newValue,
    );
    setState(() {
      _data = _data!.copyWith(availability: updatedAvailability);
    });

    try {
      await _repository.updateAvailability(updatedAvailability);
    } catch (e) {
      // Roll back on failure
      if (mounted) {
        setState(() {
          _data = _data!.copyWith(
            availability: _data!.availability.copyWith(
              acceptingAppointments: previousValue,
            ),
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update availability: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _onToggleOnCall(bool newValue) async {
    if (_data == null) return;
    final previousValue = _data!.availability.onCallToday;

    // Optimistic update
    final updatedAvailability = _data!.availability.copyWith(
      onCallToday: newValue,
    );
    setState(() {
      _data = _data!.copyWith(availability: updatedAvailability);
    });

    try {
      await _repository.updateAvailability(updatedAvailability);
    } catch (e) {
      // Roll back on failure
      if (mounted) {
        setState(() {
          _data = _data!.copyWith(
            availability: _data!.availability.copyWith(
              onCallToday: previousValue,
            ),
          );
        });
      }
    }
  }

  void _onOpenWorkingHoursEditor() {
    if (_data == null) return;
    final tokens = ClinicalTokens.of(context);
    final hoursController = TextEditingController(
      text: _data!.availability.workingHours,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: tokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Working Hours',
                  style: tokens.headlineStyle.copyWith(fontWeight: FontWeight.w600),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Set your regular consultation and clinic operating hours.',
              style: tokens.bodyStyle.copyWith(color: tokens.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: hoursController,
              decoration: InputDecoration(
                labelText: 'Weekly Schedule',
                hintText: 'e.g. Mon - Fri: 08:00 - 17:00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ClinicalTokens.radiusCard),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  final newHours = hoursController.text.trim();
                  if (newHours.isNotEmpty) {
                    final updatedAvailability = _data!.availability.copyWith(
                      workingHours: newHours,
                    );
                    setState(() {
                      _data = _data!.copyWith(availability: updatedAvailability);
                    });
                    _repository.updateAvailability(updatedAvailability);
                  }
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.primary,
                  foregroundColor: tokens.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ClinicalTokens.radiusPill),
                  ),
                ),
                child: const Text('Save Working Hours'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onToggleBiometric(bool newValue) async {
    if (_data == null) return;

    if (newValue) {
      // Enabling Biometric unlock first requests device biometric enrollment
      try {
        final canCheckBiometrics = await _localAuth.canCheckBiometrics;
        final isDeviceSupported = await _localAuth.isDeviceSupported();

        if (!canCheckBiometrics && !isDeviceSupported) {
          if (mounted) {
            _showInfoSnackBar('Biometric authentication is not supported on this device.');
          }
          return;
        }

        final didAuthenticate = await _localAuth.authenticate(
          localizedReason: 'Scan fingerprint or face to enable biometric unlock',
          biometricOnly: true,
        );

        if (!didAuthenticate) {
          if (mounted) {
            _showInfoSnackBar('Biometric verification cancelled.');
          }
          return;
        }
      } catch (e) {
        if (mounted) {
          _showInfoSnackBar('Biometric setup note: $e');
        }
      }
    }

    // Update state
    final updatedSecurity = _data!.security.copyWith(biometricUnlock: newValue);
    setState(() {
      _data = _data!.copyWith(security: updatedSecurity);
    });
    _repository.updateSecurity(updatedSecurity);
  }

  Future<void> _handleLogout() async {
    try {
      // Check if real Firebase Auth is available in context
      try {
        final authProvider = Provider.of<app_providers.AuthProvider>(
          context,
          listen: false,
        );
        await authProvider.signOut();
      } catch (_) {
        // Fallback to repository logout
        await _repository.logout();
      }

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        _showInfoSnackBar('Error signing out: $e');
      }
    }
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onBottomNavTap(int index) {
    if (index == 3) return; // Already on Profile

    if (index == 0) {
      if (widget.onNavigateToDashboard != null) {
        widget.onNavigateToDashboard!();
      } else {
        Navigator.of(context).pushReplacementNamed('/doctor-dashboard');
      }
    } else if (index == 1) {
      if (widget.onNavigateToSchedule != null) {
        widget.onNavigateToSchedule!();
      } else {
        Navigator.of(context).pushReplacementNamed('/doctor-schedule');
      }
    } else if (index == 2) {
      widget.onNavigateToPatients?.call();
      _showInfoSnackBar('Opening Patients tab...');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = ClinicalTokens.of(context);
    final themeController = ClinicalThemeController.instance;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: tokens.background,
        body: Stack(
          children: [
            // Single vertical scroll with RefreshIndicator
            RefreshIndicator(
              onRefresh: _handleRefresh,
              color: tokens.primary,
              backgroundColor: tokens.surface,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.only(
                  // Bottom scroll padding so Log out and version clear the floating nav
                  bottom: 120.0,
                ),
                child: _isLoading
                    ? const ProfileSkeleton()
                    : _errorMessage != null
                        ? _buildErrorView(tokens)
                        : _buildProfileContent(tokens, themeController),
              ),
            ),

            // Pinned Floating Bottom Nav Bar with Profile active (index 3)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FloatingRoleNavBar(
                currentIndex: 3,
                onTap: _onBottomNavTap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    ClinicalTokens tokens,
    ClinicalThemeController themeController,
  ) {
    final data = _data!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Full-bleed Hero header (Profile title, ECG line, details, photo, camera, frosted stats panel)
        ProfileHeroCard(
          details: data.details,
          stats: data.stats,
          isEditing: _isEditing,
          nameController: _nameController,
          specialtyController: _specialtyController,
          facilityController: _facilityController,
          onChangePhoto: _onChangePhoto,
          onToggleEdit: _toggleEditMode,
        ),

        // Content below hero with 14px side padding (untouched)
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ClinicalTokens.screenSidePadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: ClinicalTokens.sectionSpacing),

              // 4. Availability group
              ClinicalSettingsGroup(
          title: 'Availability',
          rows: [
            ClinicalSettingsRow.customSwitch(
              icon: Icons.check_circle_outline,
              label: 'Accepting appointments',
              value: data.availability.acceptingAppointments,
              onChanged: _onToggleAcceptingAppointments,
            ),
            ClinicalSettingsRow.customSwitch(
              icon: Icons.phone_in_talk_outlined,
              label: 'On-call today',
              value: data.availability.onCallToday,
              onChanged: _onToggleOnCall,
            ),
            ClinicalSettingsRow.chevron(
              icon: Icons.access_time_outlined,
              label: 'Working hours',
              subtitle: data.availability.workingHours,
              onTap: _onOpenWorkingHoursEditor,
            ),
          ],
        ),
        const SizedBox(height: ClinicalTokens.sectionSpacing),

        // 5. Professional group
        ClinicalSettingsGroup(
          title: 'Professional',
          rows: [
            ClinicalSettingsRow.chevron(
              icon: Icons.badge_outlined,
              label: 'Personal information',
              onTap: () => _showInfoSnackBar('Personal information details'),
            ),
            ClinicalSettingsRow.chevron(
              icon: Icons.card_membership_outlined,
              label: 'Qualifications and license',
              onTap: () => _showInfoSnackBar('Qualifications and license verification'),
            ),
            ClinicalSettingsRow.chevron(
              icon: Icons.article_outlined,
              label: 'Bio and specialties',
              onTap: () => _showInfoSnackBar('Bio and specialties editor'),
            ),
            ClinicalSettingsRow.chevron(
              icon: Icons.local_hospital_outlined,
              label: 'Facility and department',
              onTap: () => _showInfoSnackBar('Facility and department assignments'),
            ),
          ],
        ),
        const SizedBox(height: ClinicalTokens.sectionSpacing),

        // 6. Preferences group
        AnimatedBuilder(
          animation: themeController,
          builder: (context, _) {
            final isDark = themeController.isDarkMode ||
                Theme.of(context).brightness == Brightness.dark;

            return ClinicalSettingsGroup(
              title: 'Preferences',
              rows: [
                ClinicalSettingsRow.chevron(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  onTap: () => _showInfoSnackBar('Notification preferences'),
                ),
                ClinicalSettingsRow.value(
                  icon: Icons.language_outlined,
                  label: 'Language',
                  valueText: data.language,
                  onTap: () => _showInfoSnackBar('Language selection: English'),
                ),
                ClinicalSettingsRow.customSwitch(
                  icon: Icons.dark_mode_outlined,
                  label: 'Dark mode',
                  value: isDark,
                  onChanged: (val) {
                    themeController.setDarkMode(val);
                  },
                ),
              ],
            );
          },
        ),
        const SizedBox(height: ClinicalTokens.sectionSpacing),

        // 7. Security and privacy group
        ClinicalSettingsGroup(
          title: 'Security and privacy',
          rows: [
            ClinicalSettingsRow.chevron(
              icon: Icons.lock_outline,
              label: 'Change password',
              onTap: () => _showInfoSnackBar('Change password workflow'),
            ),
            ClinicalSettingsRow.customSwitch(
              icon: Icons.fingerprint_outlined,
              label: 'Biometric unlock',
              value: data.security.biometricUnlock,
              onChanged: _onToggleBiometric,
            ),
            ClinicalSettingsRow.chevron(
              icon: Icons.devices_outlined,
              label: 'Active sessions',
              onTap: () => _showInfoSnackBar('2 active devices logged in'),
            ),
            ClinicalSettingsRow.chevron(
              icon: Icons.shield_outlined,
              label: 'Privacy and audit log',
              onTap: () => _showInfoSnackBar('Access audit log'),
            ),
          ],
        ),
        const SizedBox(height: ClinicalTokens.sectionSpacing),

        // 8. Support group
        ClinicalSettingsGroup(
          title: 'Support',
          rows: [
            ClinicalSettingsRow.chevron(
              icon: Icons.help_outline_rounded,
              label: 'Help and support',
              onTap: () => _showInfoSnackBar('Help Center & FAQs'),
            ),
            ClinicalSettingsRow.chevron(
              icon: Icons.info_outline_rounded,
              label: 'Terms and about',
              onTap: () => _showInfoSnackBar('Terms of Service & Privacy Policy'),
            ),
          ],
        ),
        const SizedBox(height: ClinicalTokens.sectionSpacing),

        // 9. Danger Log out button + App version
        LogoutButton(
          onLogout: _handleLogout,
          appVersion: data.appVersion,
        ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(ClinicalTokens tokens) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 40, color: tokens.danger),
            const SizedBox(height: 12),
            Text('Failed to load profile', style: tokens.cardTitleStyle),
            const SizedBox(height: 4),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              style: tokens.secondaryStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _handleRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: tokens.primary,
                foregroundColor: tokens.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ClinicalTokens.radiusPill),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
