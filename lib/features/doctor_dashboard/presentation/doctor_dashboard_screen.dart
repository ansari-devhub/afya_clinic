import 'package:flutter/material.dart';
import '../../../core/theme/clinical_tokens.dart';
import '../../../core/widgets/floating_role_nav_bar.dart';
import '../data/doctor_dashboard_repository.dart';
import '../data/models/doctor_dashboard_data.dart';
import 'animations/dashboard_entrance_animation.dart';
import 'widgets/dashboard_headline.dart';
import 'widgets/dashboard_skeleton.dart';
import 'widgets/dashboard_top_bar.dart';
import 'widgets/emergency_strip.dart';
import 'widgets/later_today_section.dart';
import 'widgets/needs_attention_section.dart';
import 'widgets/next_patient_card.dart';
import 'widgets/recent_patients_section.dart';

/// Doctor Dashboard Screen of the clinical app.
///
/// Follows strict specifications:
/// - Fixed section order:
///   1. Top bar
///   2. Headline
///   3. Next patient
///   4. Recent patients
///   5. Later today
///   6. Needs attention
///   7. Emergency
///   8. Floating bottom nav
/// - Single vertical scroll with [RefreshIndicator].
/// - Floating pill bottom nav bar with lifted active tab indicator.
/// - Loading skeleton state.
/// - Repository-driven data.
/// - Load-in entrance animation on cold start.
class DoctorDashboardScreen extends StatefulWidget {
  final DoctorDashboardRepository? repository;
  final bool? playEntranceAnimation;

  /// Tracks cold start across the app run.
  static bool hasPlayedEntranceAnimation = false;

  /// Resets cold start flag (for tests or manual replay).
  static void resetColdStart() {
    hasPlayedEntranceAnimation = false;
  }

  const DoctorDashboardScreen({
    super.key,
    this.repository,
    this.playEntranceAnimation,
  });

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final DoctorDashboardRepository _repository;
  late final AnimationController _entranceController;
  late final DashboardEntranceAnimation _entranceAnimation;

  bool _shouldPlayEntrance = false;
  DoctorDashboardData? _data;
  bool _isLoading = true;
  String? _errorMessage;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? const MockDoctorDashboardRepository();

    _entranceController = AnimationController(
      vsync: this,
      duration: DashboardEntranceAnimation.totalDuration,
    );
    _entranceAnimation = DashboardEntranceAnimation(_entranceController);

    final force = widget.playEntranceAnimation;
    _shouldPlayEntrance = force ?? !DoctorDashboardScreen.hasPlayedEntranceAnimation;

    if (!_shouldPlayEntrance) {
      _entranceController.value = 1.0;
    }

    _loadDashboardData();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    try {
      final data = await _repository.fetchDashboardData();
      if (!mounted) return;
      setState(() {
        _data = data;
        _isLoading = false;
        _errorMessage = null;
      });

      if (_shouldPlayEntrance) {
        final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
        if (reduceMotion) {
          _entranceController.value = 1.0;
        } else {
          _entranceController.forward(from: 0.0);
        }
        DoctorDashboardScreen.hasPlayedEntranceAnimation = true;
        _shouldPlayEntrance = false;
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _loadDashboardData();
  }

  void _onNotificationsTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifications (1 unread critical alert)'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onStartConsult(NextPatientAppointment appointment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting consultation for ${appointment.name}...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onViewChart(String patientName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening medical chart for $patientName...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onVideoCall(NextPatientAppointment appointment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Launching telehealth video call with ${appointment.name}...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onSeeAllPatients() {
    setState(() => _currentNavIndex = 2); // Switch to Patients tab
  }

  void _onSeeAllSchedule() {
    Navigator.of(context).pushNamed('/doctor-schedule');
  }

  void _onNeedsAttentionTap(NeedsAttentionItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to: ${item.title}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onEmergencyTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emergency alerts and on-call roster opened'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = ClinicalTokens.of(context);

    return Scaffold(
      backgroundColor: tokens.background,
      body: Stack(
        children: [
          // Main scrollable content
          RefreshIndicator(
            onRefresh: _handleRefresh,
            color: tokens.primary,
            backgroundColor: tokens.surface,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.only(
                left: ClinicalTokens.screenSidePadding,
                right: ClinicalTokens.screenSidePadding,
                top: MediaQuery.of(context).padding.top + 12.0,
                // Extra bottom scroll padding so last section is never hidden by floating nav
                bottom: 110.0,
              ),
              child: _isLoading
                  ? const DashboardSkeleton()
                  : _errorMessage != null
                      ? _buildErrorView(tokens)
                      : _buildDashboardContent(tokens, _data!),
            ),
          ),

          // 8. Floating Bottom Nav Bar (floats and stays visible)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingRoleNavBar(
              currentIndex: _currentNavIndex,
              barSlideAnimation: _entranceAnimation.navBarSlide,
              activeCircleScaleAnimation: _entranceAnimation.navActiveCircle,
              labelsFadeAnimation: _entranceAnimation.navLabelsFade,
              onTap: (index) {
                if (index == 1) {
                  Navigator.of(context).pushNamed('/doctor-schedule');
                } else if (index == 3) {
                  Navigator.of(context).pushNamed('/doctor-profile');
                } else {
                  setState(() => _currentNavIndex = index);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(ClinicalTokens tokens, DoctorDashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Top bar: app logo, greeting + Dr. Surname, bell with red dot
        DashboardTopBar(
          doctor: data.doctor,
          onNotificationsTap: _onNotificationsTap,
        ),
        const SizedBox(height: ClinicalTokens.sectionSpacing),

        // 2. Headline: "Here is an overview of your clinical dashboard today"
        DashboardHeadline(fadeAnimation: _entranceAnimation.headlineFade),
        const SizedBox(height: ClinicalTokens.sectionSpacing),

        // 3. Next patient card (or empty state)
        NextPatientCard(
          appointment: data.nextPatient,
          onStartConsult: data.nextPatient != null
              ? () => _onStartConsult(data.nextPatient!)
              : null,
          onViewChart: data.nextPatient != null
              ? () => _onViewChart(data.nextPatient!.name)
              : null,
          onVideoCall: data.nextPatient != null
              ? () => _onVideoCall(data.nextPatient!)
              : null,
          cardAnimation: _entranceAnimation.nextPatientCard,
          chipsAnimation: _entranceAnimation.nextPatientChips,
          buttonsAnimation: _entranceAnimation.nextPatientButtons,
        ),
        const SizedBox(height: ClinicalTokens.sectionSpacing),

        // 4. Recent patients: horizontal circles (hidden if empty)
        RecentPatientsSection(
          patients: data.recentPatients,
          onSeeAll: _onSeeAllPatients,
          onPatientTap: (p) => _onViewChart(p.name),
          headerFadeAnimation: _entranceAnimation.recentPatientsHeader,
          avatarAnimationProvider: _entranceAnimation.recentPatientAvatar,
        ),
        if (data.recentPatients.isNotEmpty)
          const SizedBox(height: ClinicalTokens.sectionSpacing),

        // 5. Later today: horizontal cards (excludes next patient)
        LaterTodaySection(
          appointments: data.laterToday,
          onSeeAll: _onSeeAllSchedule,
          onAppointmentTap: (a) => _onViewChart(a.patientName),
          onViewChart: (a) => _onViewChart(a.patientName),
          headerFadeAnimation: _entranceAnimation.laterTodayHeader,
          cardAnimationProvider: _entranceAnimation.laterTodayCard,
        ),
        if (data.laterToday.isNotEmpty)
          const SizedBox(height: ClinicalTokens.sectionSpacing),

        // 6. Needs attention: rows with counts & chevrons (hidden if all 0)
        NeedsAttentionSection(
          items: data.needsAttention,
          onItemTap: _onNeedsAttentionTap,
          headerFadeAnimation: _entranceAnimation.needsAttentionHeader,
          rowAnimationProvider: _entranceAnimation.needsAttentionRow,
        ),
        if (data.needsAttention.any((i) => i.count > 0))
          const SizedBox(height: ClinicalTokens.sectionSpacing),

        // 7. Emergency: danger strip
        EmergencyStrip(
          text: data.emergency.title,
          onTap: _onEmergencyTap,
        ),
      ],
    );
  }

  Widget _buildErrorView(ClinicalTokens tokens) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 40, color: tokens.danger),
            const SizedBox(height: 12),
            Text(
              'Failed to load dashboard',
              style: tokens.cardTitleStyle,
            ),
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
