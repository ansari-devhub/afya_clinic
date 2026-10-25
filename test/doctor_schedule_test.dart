import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:afya_clinic/core/theme/clinical_tokens.dart';
import 'package:afya_clinic/core/widgets/clinical_status_chip.dart';
import 'package:afya_clinic/core/widgets/floating_role_nav_bar.dart';
import 'package:afya_clinic/features/doctor_schedule/data/doctor_schedule_repository.dart';
import 'package:afya_clinic/features/doctor_schedule/data/models/doctor_schedule_data.dart';
import 'package:afya_clinic/features/doctor_schedule/presentation/doctor_schedule_screen.dart';
import 'package:afya_clinic/features/doctor_schedule/presentation/widgets/block_time_bottom_sheet.dart';
import 'package:afya_clinic/features/doctor_schedule/presentation/widgets/schedule_date_nav.dart';
import 'package:afya_clinic/features/doctor_schedule/presentation/widgets/schedule_filter_chips.dart';
import 'package:afya_clinic/features/doctor_schedule/presentation/widgets/schedule_summary_row.dart';
import 'package:afya_clinic/features/doctor_schedule/presentation/widgets/schedule_timeline.dart';
import 'package:afya_clinic/features/doctor_schedule/presentation/widgets/schedule_title_bar.dart';
import 'package:afya_clinic/features/doctor_schedule/presentation/widgets/timeline_appointment_card.dart';
import 'package:afya_clinic/features/doctor_schedule/presentation/widgets/timeline_blocked_card.dart';
import 'package:afya_clinic/features/doctor_schedule/presentation/widgets/timeline_next_patient_card.dart';
import 'package:afya_clinic/features/doctor_schedule/presentation/widgets/timeline_now_line.dart';
import 'package:afya_clinic/features/doctor_schedule/presentation/widgets/timeline_open_slot_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget(
    Widget child, {
    Brightness brightness = Brightness.light,
  }) {
    return MaterialApp(
      theme: ThemeData(
        brightness: brightness,
        extensions: [
          brightness == Brightness.dark
              ? ClinicalTokens.dark
              : ClinicalTokens.light,
        ],
      ),
      home: Scaffold(body: child),
    );
  }

  final now = DateTime.now();
  final testDate = DateTime(now.year, now.month, now.day);

  final testAppointment = ScheduleAppointment(
    id: 'apt-test',
    patientName: 'Sarah M. Jenkins',
    age: 45,
    sex: 'Female',
    visitType: 'Cardiology follow-up',
    isTelehealth: false,
    startTime: DateTime(now.year, now.month, now.day, 10, 30),
    endTime: DateTime(now.year, now.month, now.day, 11, 0),
    timeFormatted: '10:30 AM',
    status: ClinicalAppointmentStatus.checkedIn,
  );

  final testTelehealthAppointment = ScheduleAppointment(
    id: 'apt-telehealth',
    patientName: 'David Kim',
    age: 38,
    sex: 'Male',
    visitType: 'Cardiology review',
    isTelehealth: true,
    startTime: DateTime(now.year, now.month, now.day, 11, 15),
    endTime: DateTime(now.year, now.month, now.day, 11, 45),
    timeFormatted: '11:15 AM',
    status: ClinicalAppointmentStatus.upcoming,
  );

  final testBlock = ScheduleBlock(
    id: 'blk-lunch',
    title: 'Lunch break',
    startTime: DateTime(now.year, now.month, now.day, 12, 0),
    endTime: DateTime(now.year, now.month, now.day, 13, 0),
    timeRangeFormatted: '12:00 PM - 1:00 PM',
    reason: 'Lunch',
    repeat: 'Daily',
  );

  final testOpenSlot = OpenSlot(
    id: 'slot-1',
    startTime: DateTime(now.year, now.month, now.day, 13, 0),
    endTime: DateTime(now.year, now.month, now.day, 14, 0),
    timeRangeFormatted: '1:00 PM - 2:00 PM',
  );

  group('Doctor Schedule Unit Components Tests', () {
    testWidgets('1. ScheduleTitleBar renders Schedule title, Today pill, and 32px block button', (tester) async {
      bool todayTapped = false;
      bool blockTapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          ScheduleTitleBar(
            onTodayTap: () => todayTapped = true,
            onBlockTimeTap: () => blockTapped = true,
          ),
        ),
      );

      // "Schedule" title
      expect(find.text('Schedule'), findsOneWidget);

      // "Today" button
      expect(find.text('Today'), findsOneWidget);
      await tester.tap(find.text('Today'));
      expect(todayTapped, isTrue);

      // 32px bordered square button with calendar-off icon
      expect(find.byIcon(Icons.event_busy_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.event_busy_outlined));
      expect(blockTapped, isTrue);
    });

    testWidgets('2. ScheduleDateNav renders month label, Day/Week segments, and week chips with dots', (tester) async {
      DateTime? selectedDate;
      ScheduleViewMode? selectedMode;
      bool monthTapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          ScheduleDateNav(
            selectedDate: testDate,
            currentWeekStart: DateTime(2026, 10, 12),
            viewMode: ScheduleViewMode.day,
            appointmentDays: const {12, 13, 14, 15, 16, 17},
            onDateSelected: (d) => selectedDate = d,
            onViewModeChanged: (m) => selectedMode = m,
            onMonthTap: () => monthTapped = true,
            onSwipeWeek: (_) {},
          ),
        ),
      );

      // Month label
      expect(find.text('October 2026'), findsOneWidget);
      await tester.tap(find.text('October 2026'));
      expect(monthTapped, isTrue);

      // Day | Week segmented control
      expect(find.text('Day'), findsOneWidget);
      expect(find.text('Week'), findsOneWidget);
      await tester.tap(find.text('Week'));
      expect(selectedMode, equals(ScheduleViewMode.week));

      // 7 day chips (12 to 18)
      expect(find.text('16'), findsOneWidget);
      await tester.tap(find.text('15'));
      expect(selectedDate?.day, equals(15));
    });

    testWidgets('3. ScheduleFilterChips renders filter options and handles selection', (tester) async {
      ScheduleFilter? pickedFilter;

      await tester.pumpWidget(
        buildTestableWidget(
          ScheduleFilterChips(
            selectedFilter: ScheduleFilter.all,
            onFilterSelected: (f) => pickedFilter = f,
          ),
        ),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.text('In person'), findsOneWidget);
      expect(find.text('Telehealth'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);

      await tester.tap(find.text('Telehealth'));
      expect(pickedFilter, equals(ScheduleFilter.telehealth));
    });

    testWidgets('4. ScheduleSummaryRow renders appointment count and telehealth count', (tester) async {
      final summary = DayScheduleSummary(
        date: testDate,
        totalAppointments: 8,
        telehealthAppointments: 2,
      );

      await tester.pumpWidget(
        buildTestableWidget(
          ScheduleSummaryRow(summary: summary),
        ),
      );

      expect(find.text(summary.getFormattedTitle()), findsOneWidget);
      expect(find.text('2 telehealth'), findsOneWidget);
    });

    testWidgets('5. TimelineAppointmentCard renders appointment details and status chip or video icon', (tester) async {
      bool cardTapped = false;
      bool videoTapped = false;

      // Regular in-person appointment
      await tester.pumpWidget(
        buildTestableWidget(
          TimelineAppointmentCard(
            appointment: testAppointment,
            onTap: () => cardTapped = true,
          ),
        ),
      );

      expect(find.text('Sarah M. Jenkins'), findsOneWidget);
      expect(find.text('Cardiology follow-up · In person'), findsOneWidget);
      expect(find.text('Checked in'), findsOneWidget);

      await tester.tap(find.text('Sarah M. Jenkins'));
      expect(cardTapped, isTrue);

      // Telehealth appointment
      await tester.pumpWidget(
        buildTestableWidget(
          TimelineAppointmentCard(
            appointment: testTelehealthAppointment,
            onVideoTap: () => videoTapped = true,
          ),
        ),
      );

      expect(find.text('David Kim'), findsOneWidget);
      expect(find.text('Cardiology review · Telehealth'), findsOneWidget);
      expect(find.byIcon(Icons.videocam_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.videocam_outlined));
      expect(videoTapped, isTrue);
    });

    testWidgets('6. TimelineNextPatientCard renders compact filled card with pill action buttons', (tester) async {
      bool consultTapped = false;
      bool chartTapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          TimelineNextPatientCard(
            appointment: testAppointment,
            onStartConsult: () => consultTapped = true,
            onViewChart: () => chartTapped = true,
          ),
        ),
      );

      expect(find.text('Sarah M. Jenkins'), findsOneWidget);
      expect(find.text('Cardiology follow-up · 45 yrs, Female'), findsOneWidget);
      expect(find.text('Checked in'), findsOneWidget);

      // Start consult button
      expect(find.text('Start consult'), findsOneWidget);
      await tester.tap(find.text('Start consult'));
      expect(consultTapped, isTrue);

      // View chart button
      expect(find.text('View chart'), findsOneWidget);
      await tester.tap(find.text('View chart'));
      expect(chartTapped, isTrue);
    });

    testWidgets('7. TimelineNowLine renders danger dot, 1px line, and formatted time', (tester) async {
      final now = DateTime(2026, 10, 16, 10, 15);

      await tester.pumpWidget(
        buildTestableWidget(
          TimelineNowLine(currentTime: now),
        ),
      );

      expect(find.text('10:15'), findsOneWidget);
    });

    testWidgets('8. TimelineBlockedCard and TimelineOpenSlotCard render dashed border cards', (tester) async {
      bool slotTapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          Column(
            children: [
              TimelineBlockedCard(block: testBlock),
              const SizedBox(height: 10),
              TimelineOpenSlotCard(
                openSlot: testOpenSlot,
                onTap: () => slotTapped = true,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Lunch break'), findsOneWidget);
      expect(find.text('Blocked · 12:00 PM - 1:00 PM'), findsOneWidget);

      expect(find.text('Open slot'), findsOneWidget);
      expect(find.text('1:00 PM - 2:00 PM · tap to block'), findsOneWidget);

      await tester.tap(find.text('Open slot'));
      expect(slotTapped, isTrue);
    });

    testWidgets('9. BlockTimeBottomSheet displays fields and confirms block', (tester) async {
      bool blockConfirmed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const [ClinicalTokens.light],
          ),
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  BlockTimeBottomSheet.show(
                    ctx,
                    initialDate: testDate,
                    initialReason: 'Emergency on-call',
                    onConfirm: ({
                      required date,
                      required startTime,
                      required endTime,
                      required reason,
                      required repeat,
                    }) async {
                      blockConfirmed = true;
                    },
                  );
                },
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      );

      // Tap to open sheet
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Block Time'), findsNWidgets(2)); // Title and submit button
      expect(find.text('Date'), findsOneWidget);
      expect(find.text('Start time'), findsOneWidget);
      expect(find.text('End time'), findsOneWidget);
      expect(find.text('Repeat'), findsOneWidget);
      expect(find.text('Reason'), findsOneWidget);

      // Submit
      await tester.tap(find.widgetWithText(ElevatedButton, 'Block Time'));
      await tester.pumpAndSettle();

      expect(blockConfirmed, isTrue);
    });
  });

  group('DoctorScheduleScreen Orchestration Tests', () {
    testWidgets('10. DoctorScheduleScreen renders all sections in fixed order and floating nav bar', (tester) async {
      final repository = MockDoctorScheduleRepository();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            extensions: const [ClinicalTokens.light],
          ),
          home: DoctorScheduleScreen(
            repository: repository,
            initialDate: testDate,
          ),
        ),
      );

      // Wait for repository data load
      await tester.pumpAndSettle();

      // 1. Title bar
      expect(find.byType(ScheduleTitleBar), findsOneWidget);

      // 2. Date nav
      expect(find.byType(ScheduleDateNav), findsOneWidget);

      // 3. Filter chips
      expect(find.byType(ScheduleFilterChips), findsOneWidget);

      // 4. Summary row
      expect(find.byType(ScheduleSummaryRow), findsOneWidget);
      expect(find.text('2 telehealth'), findsOneWidget);

      // 5. Timeline
      expect(find.byType(ScheduleTimeline), findsOneWidget);

      // Row cards exist:
      // a) Completed appointment (James Wilson)
      expect(find.text('James Wilson'), findsOneWidget);
      expect(find.text('Completed'), findsNWidgets(2)); // Filter chip + status chip

      // c) Next patient card (Sarah M. Jenkins)
      expect(find.text('Sarah M. Jenkins'), findsOneWidget);
      expect(find.text('Start consult'), findsOneWidget);
      expect(find.text('View chart'), findsOneWidget);

      // Blocked & Open slot
      expect(find.text('Lunch break'), findsOneWidget);
      expect(find.text('Open slot'), findsOneWidget);

      // 6. Floating Role Nav Bar with Schedule active (index 1)
      final navBarFinder = find.byType(FloatingRoleNavBar);
      expect(navBarFinder, findsOneWidget);
      final navBar = tester.widget<FloatingRoleNavBar>(navBarFinder);
      expect(navBar.currentIndex, equals(1));
    });

    testWidgets('11. Filter chip selection filters timeline appointments', (tester) async {
      final repository = MockDoctorScheduleRepository();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            extensions: const [ClinicalTokens.light],
          ),
          home: DoctorScheduleScreen(
            repository: repository,
            initialDate: testDate,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap "Telehealth" filter chip
      await tester.tap(find.text('Telehealth'));
      await tester.pumpAndSettle();

      // Telehealth appointments should be visible
      expect(find.text('David Kim'), findsOneWidget);
      expect(find.text('Grace Hopper'), findsOneWidget);

      // In-person appointments should not be visible
      expect(find.text('James Wilson'), findsNothing);
      expect(find.text('Emma Watson'), findsNothing);
    });

    testWidgets('12. Pull to refresh reloads schedule timeline data', (tester) async {
      final repository = MockDoctorScheduleRepository();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            extensions: const [ClinicalTokens.light],
          ),
          home: DoctorScheduleScreen(
            repository: repository,
            initialDate: testDate,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Trigger pull to refresh on main vertical scroll view
      await tester.fling(find.byType(SingleChildScrollView).first, const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      expect(find.byType(ScheduleTitleBar), findsOneWidget);
      expect(find.text('Sarah M. Jenkins'), findsOneWidget);
    });
  });
}
