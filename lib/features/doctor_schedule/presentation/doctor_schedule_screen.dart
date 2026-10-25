import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/clinical_tokens.dart';
import '../../../core/widgets/floating_role_nav_bar.dart';
import '../data/doctor_schedule_repository.dart';
import '../data/models/doctor_schedule_data.dart';
import 'widgets/block_time_bottom_sheet.dart';
import 'widgets/schedule_date_nav.dart';
import 'widgets/schedule_filter_chips.dart';
import 'widgets/schedule_skeleton.dart';
import 'widgets/schedule_summary_row.dart';
import 'widgets/schedule_timeline.dart';
import 'widgets/schedule_title_bar.dart';
import 'widgets/schedule_week_view.dart';

/// Doctor Schedule Screen (2nd tab) of role-based clinical app.
///
/// Follows strict specifications:
/// - Single vertical scroll, floating role nav pinned at bottom.
/// - Exact section order:
///   1. Title bar: "Schedule" + [Today] + [Block time button]
///   2. Date nav: Month label + Day | Week segmented control + Week strip with dots
///   3. Filter chips: All, In person, Telehealth, Completed
///   4. Summary row: "Today · N appointments" and "N telehealth"
///   5. Timeline (Day) or Week view (Week)
///   6. Floating bottom nav with Schedule active (index 1)
/// - Live "Now line" (updates every minute).
/// - Block-time modal sheet.
/// - Scroll to current time (today) or first appointment on open.
class DoctorScheduleScreen extends StatefulWidget {
  final DoctorScheduleRepository? repository;
  final DateTime? initialDate;
  final VoidCallback? onNavigateToDashboard;
  final VoidCallback? onNavigateToPatients;
  final VoidCallback? onNavigateToProfile;

  const DoctorScheduleScreen({
    super.key,
    this.repository,
    this.initialDate,
    this.onNavigateToDashboard,
    this.onNavigateToPatients,
    this.onNavigateToProfile,
  });

  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> {
  late final DoctorScheduleRepository _repository;
  late final ScrollController _scrollController;

  late DateTime _selectedDate;
  late DateTime _currentWeekStart;
  DateTime _currentTime = DateTime.now();

  ScheduleViewMode _viewMode = ScheduleViewMode.day;
  ScheduleFilter _selectedFilter = ScheduleFilter.all;

  bool _isLoading = true;
  String? _errorMessage;

  List<TimelineRowItem> _timelineItems = [];
  DayScheduleSummary? _summary;
  Set<int> _appointmentDaysInWeek = {};
  Map<DateTime, List<TimelineRowItem>> _weekItemsByDay = {};

  Timer? _minuteTimer;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? MockDoctorScheduleRepository();
    _scrollController = ScrollController();

    _selectedDate = widget.initialDate ?? DateTime.now();
    _currentWeekStart = _getStartOfWeek(_selectedDate);

    _loadScheduleData(isInitial: true);

    // Live update for the Now line every minute
    _minuteTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _minuteTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  DateTime _getStartOfWeek(DateTime date) {
    // Week starts on Monday (1)
    final diff = date.weekday - DateTime.monday;
    return DateTime(date.year, date.month, date.day - diff);
  }

  Future<void> _loadScheduleData({bool isInitial = false}) async {
    try {
      final summary = await _repository.fetchDaySummary(_selectedDate);
      final timeline = await _repository.fetchTimeline(
        date: _selectedDate,
        filter: _selectedFilter,
      );
      final weekDays = await _repository.fetchAppointmentDaysForWeek(_currentWeekStart);

      // If week view is active, load each day of the week
      Map<DateTime, List<TimelineRowItem>> weekItems = {};
      if (_viewMode == ScheduleViewMode.week) {
        for (int i = 0; i < 7; i++) {
          final day = _currentWeekStart.add(Duration(days: i));
          final dayKey = DateTime(day.year, day.month, day.day);
          final items = await _repository.fetchTimeline(
            date: day,
            filter: _selectedFilter,
          );
          weekItems[dayKey] = items;
        }
      }

      if (!mounted) return;
      setState(() {
        _summary = summary;
        _timelineItems = timeline;
        _appointmentDaysInWeek = weekDays;
        _weekItemsByDay = weekItems;
        _isLoading = false;
        _errorMessage = null;
      });

      if (isInitial) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToAppropriatePosition();
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _scrollToAppropriatePosition() {
    if (!_scrollController.hasClients) return;

    final now = DateTime.now();
    final isToday = _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;

    if (isToday) {
      // Scroll to approximate position near current time or next appointment
      _scrollController.animateTo(
        60.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else if (_timelineItems.isNotEmpty) {
      // Scroll to start of appointments
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleRefresh() async {
    await _loadScheduleData();
  }

  void _onJumpToToday() {
    final now = DateTime.now();
    setState(() {
      _selectedDate = now;
      _currentWeekStart = _getStartOfWeek(now);
      _isLoading = true;
    });
    _loadScheduleData(isInitial: true);
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _isLoading = true;
    });
    _loadScheduleData(isInitial: true);
  }

  void _onSwipeWeek(bool toNext) {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(Duration(days: toNext ? 7 : -7));
      _selectedDate = _currentWeekStart;
      _isLoading = true;
    });
    _loadScheduleData();
  }

  Future<void> _onMonthTap() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _currentWeekStart = _getStartOfWeek(picked);
        _isLoading = true;
      });
      _loadScheduleData(isInitial: true);
    }
  }

  void _onViewModeChanged(ScheduleViewMode mode) {
    if (_viewMode == mode) return;
    setState(() {
      _viewMode = mode;
      _isLoading = true;
    });
    _loadScheduleData();
  }

  void _onFilterSelected(ScheduleFilter filter) {
    if (_selectedFilter == filter) return;
    setState(() {
      _selectedFilter = filter;
      _isLoading = true;
    });
    _loadScheduleData();
  }

  void _onBlockTimeTap({OpenSlot? prefilledSlot}) {
    final now = DateTime.now();
    final defaultStart = prefilledSlot != null
        ? TimeOfDay(
            hour: prefilledSlot.startTime.hour,
            minute: prefilledSlot.startTime.minute,
          )
        : TimeOfDay(hour: now.hour < 23 ? now.hour + 1 : 12, minute: 0);

    final defaultEnd = prefilledSlot != null
        ? TimeOfDay(
            hour: prefilledSlot.endTime.hour,
            minute: prefilledSlot.endTime.minute,
          )
        : TimeOfDay(
            hour: (defaultStart.hour + 1) % 24,
            minute: defaultStart.minute,
          );

    BlockTimeBottomSheet.show(
      context,
      initialDate: _selectedDate,
      initialStartTime: defaultStart,
      initialEndTime: defaultEnd,
      initialReason: prefilledSlot != null ? 'Blocked slot' : 'Lunch break',
      onConfirm: ({
        required DateTime date,
        required TimeOfDay startTime,
        required TimeOfDay endTime,
        required String reason,
        required String repeat,
      }) async {
        await _repository.blockTime(
          date: date,
          startTime: startTime,
          endTime: endTime,
          reason: reason,
          repeat: repeat,
        );
        _loadScheduleData();
      },
    );
  }

  void _onAppointmentTap(ScheduleAppointment appointment) {
    // Wire route: open appointment detail, or fallback to floating snackbar
    try {
      Navigator.of(context).pushNamed(
        '/appointment-detail',
        arguments: appointment,
      );
    } catch (_) {
      _showInfoSnackBar('Appointment detail for ${appointment.patientName}');
    }
  }

  void _onVideoCall(ScheduleAppointment appointment) {
    _showInfoSnackBar('Launching telehealth video call with ${appointment.patientName}...');
  }

  void _onStartConsult(ScheduleAppointment appointment) {
    _showInfoSnackBar('Starting consultation with ${appointment.patientName}...');
  }

  void _onViewChart(ScheduleAppointment appointment) {
    _showInfoSnackBar('Opening clinical chart for ${appointment.patientName}...');
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
    if (index == 1) return; // Already on Schedule

    if (index == 0) {
      if (widget.onNavigateToDashboard != null) {
        widget.onNavigateToDashboard!();
      } else {
        Navigator.of(context).pushReplacementNamed('/doctor-dashboard');
      }
    } else if (index == 2) {
      if (widget.onNavigateToPatients != null) {
        widget.onNavigateToPatients!();
      } else {
        _showInfoSnackBar('Opening Patients tab...');
      }
    } else if (index == 3) {
      if (widget.onNavigateToProfile != null) {
        widget.onNavigateToProfile!();
      } else {
        Navigator.of(context).pushReplacementNamed('/doctor-profile');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = ClinicalTokens.of(context);
    final now = DateTime.now();
    final isToday = _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;

    return Scaffold(
      backgroundColor: tokens.background,
      body: Stack(
        children: [
          // Single vertical scroll with RefreshIndicator
          RefreshIndicator(
            onRefresh: _handleRefresh,
            color: tokens.primary,
            backgroundColor: tokens.surface,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.only(
                left: ClinicalTokens.screenSidePadding,
                right: ClinicalTokens.screenSidePadding,
                top: MediaQuery.of(context).padding.top + 12.0,
                // Bottom scroll padding so last item clears the pinned floating nav
                bottom: 120.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Title bar: "Schedule", [Today], [Block time button]
                  ScheduleTitleBar(
                    onTodayTap: _onJumpToToday,
                    onBlockTimeTap: () => _onBlockTimeTap(),
                  ),
                  const SizedBox(height: 12),

                  // 2. Date nav: Month label + Day | Week segmented control + Week strip
                  ScheduleDateNav(
                    selectedDate: _selectedDate,
                    currentWeekStart: _currentWeekStart,
                    viewMode: _viewMode,
                    appointmentDays: _appointmentDaysInWeek,
                    onDateSelected: _onDateSelected,
                    onViewModeChanged: _onViewModeChanged,
                    onMonthTap: _onMonthTap,
                    onSwipeWeek: _onSwipeWeek,
                  ),
                  const SizedBox(height: 14),

                  // 3. Filter chips: All, In person, Telehealth, Completed
                  ScheduleFilterChips(
                    selectedFilter: _selectedFilter,
                    onFilterSelected: _onFilterSelected,
                  ),
                  const SizedBox(height: 14),

                  // 4. Summary row: "Today · 8 appointments", "2 telehealth"
                  if (_summary != null) ...[
                    ScheduleSummaryRow(summary: _summary!),
                    const SizedBox(height: 14),
                  ],

                  // 5. Timeline or Week view
                  if (_isLoading)
                    const ScheduleSkeleton()
                  else if (_errorMessage != null)
                    _buildErrorView(tokens)
                  else if (_viewMode == ScheduleViewMode.day)
                    ScheduleTimeline(
                      items: _timelineItems,
                      isToday: isToday,
                      currentTime: _currentTime,
                      onAppointmentTap: _onAppointmentTap,
                      onVideoTap: _onVideoCall,
                      onStartConsult: _onStartConsult,
                      onViewChart: _onViewChart,
                      onOpenSlotTap: (slot) => _onBlockTimeTap(prefilledSlot: slot),
                    )
                  else
                    ScheduleWeekView(
                      weekStart: _currentWeekStart,
                      weekItemsByDay: _weekItemsByDay,
                      onAppointmentTap: _onAppointmentTap,
                      onVideoTap: _onVideoCall,
                      onOpenSlotTap: (slot) => _onBlockTimeTap(prefilledSlot: slot),
                    ),
                ],
              ),
            ),
          ),

          // 6. Floating Bottom Nav Bar (floats pinned at bottom with Schedule active)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingRoleNavBar(
              currentIndex: 1, // Schedule tab active
              onTap: _onBottomNavTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(ClinicalTokens tokens) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 36, color: tokens.danger),
            const SizedBox(height: 10),
            Text('Failed to load schedule', style: tokens.cardTitleStyle),
            const SizedBox(height: 4),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              style: tokens.secondaryStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
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
