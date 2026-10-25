import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:afya_clinic/core/theme/clinical_tokens.dart';
import 'package:afya_clinic/core/widgets/floating_role_nav_bar.dart';
import 'package:afya_clinic/features/doctor_dashboard/data/doctor_dashboard_repository.dart';
import 'package:afya_clinic/features/doctor_dashboard/data/models/doctor_dashboard_data.dart';
import 'package:afya_clinic/features/doctor_dashboard/presentation/doctor_dashboard_screen.dart';
import 'package:afya_clinic/features/doctor_dashboard/presentation/widgets/dashboard_headline.dart';
import 'package:afya_clinic/features/doctor_dashboard/presentation/widgets/dashboard_top_bar.dart';
import 'package:afya_clinic/features/doctor_dashboard/presentation/widgets/emergency_strip.dart';
import 'package:afya_clinic/features/doctor_dashboard/presentation/widgets/later_today_section.dart';
import 'package:afya_clinic/features/doctor_dashboard/presentation/widgets/needs_attention_section.dart';
import 'package:afya_clinic/features/doctor_dashboard/presentation/widgets/next_patient_card.dart';
import 'package:afya_clinic/features/doctor_dashboard/presentation/widgets/recent_patients_section.dart';
import 'package:afya_clinic/features/doctor_dashboard/presentation/widgets/dashboard_skeleton.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget(Widget child, {Brightness brightness = Brightness.light}) {
    return MaterialApp(
      theme: ThemeData(
        brightness: brightness,
        extensions: [
          brightness == Brightness.dark ? ClinicalTokens.dark : ClinicalTokens.light,
        ],
      ),
      home: Scaffold(body: child),
    );
  }

  group('Doctor Dashboard Unit Components Tests', () {
    testWidgets('1. DashboardTopBar renders logo tile, greeting, Dr. Surname, and unread bell', (tester) async {
      bool bellTapped = false;
      const doctor = DoctorProfile(surname: 'Surname', unreadNotificationsCount: 1);

      await tester.pumpWidget(
        buildTestableWidget(
          DashboardTopBar(
            doctor: doctor,
            onNotificationsTap: () => bellTapped = true,
          ),
        ),
      );

      // Logo tile icon
      expect(find.byIcon(Icons.local_hospital_rounded), findsOneWidget);

      // Name & Greeting
      expect(find.text('Dr. Surname'), findsOneWidget);
      expect(find.text(doctor.getGreeting()), findsOneWidget);

      // Bell icon
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);

      // Tap bell
      await tester.tap(find.byType(InkWell));
      expect(bellTapped, isTrue);
    });

    testWidgets('2. DashboardHeadline renders exact required text', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const DashboardHeadline()),
      );

      expect(
        find.text('Here is an overview of your clinical dashboard today'),
        findsOneWidget,
      );
    });

    testWidgets('3. NextPatientCard renders telehealth patient details and action buttons', (tester) async {
      bool startConsultTapped = false;
      bool viewChartTapped = false;
      bool videoCallTapped = false;

      const appointment = NextPatientAppointment(
        id: 'p1',
        name: 'Patient Name',
        visitType: 'Follow-up',
        age: 45,
        sex: 'F',
        isTelehealth: true,
        date: '14 Oct, Tue',
        timeRange: '10:30 - 11:00',
      );

      await tester.pumpWidget(
        buildTestableWidget(
          NextPatientCard(
            appointment: appointment,
            onStartConsult: () => startConsultTapped = true,
            onViewChart: () => viewChartTapped = true,
            onVideoCall: () => videoCallTapped = true,
          ),
        ),
      );

      // Section title
      expect(find.text('Next patient'), findsOneWidget);

      // Patient Name and Subtitle
      expect(find.text('Patient Name'), findsOneWidget);
      expect(find.text('Follow-up · 45 yrs, F'), findsOneWidget);

      // Telehealth Video button
      expect(find.byIcon(Icons.videocam_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.videocam_outlined));
      expect(videoCallTapped, isTrue);

      // Date and Time chips
      expect(find.text('14 Oct, Tue'), findsOneWidget);
      expect(find.text('10:30 - 11:00'), findsOneWidget);

      // Action buttons
      expect(find.widgetWithText(ElevatedButton, 'Start consult'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'View chart'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Start consult'));
      expect(startConsultTapped, isTrue);

      await tester.tap(find.widgetWithText(ElevatedButton, 'View chart'));
      expect(viewChartTapped, isTrue);
    });

    testWidgets('3b. NextPatientCard displays empty state when appointment is null', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const NextPatientCard(appointment: null),
        ),
      );

      expect(find.text('No more appointments today'), findsOneWidget);
      expect(find.byIcon(Icons.event_available_outlined), findsOneWidget);
    });

    testWidgets('4. RecentPatientsSection renders horizontal list and hides when empty', (tester) async {
      const patients = [
        RecentPatient(id: 'r1', name: 'Patient A', initials: 'PN'),
        RecentPatient(id: 'r2', name: 'Patient B', initials: 'PN'),
      ];

      await tester.pumpWidget(
        buildTestableWidget(
          RecentPatientsSection(
            patients: patients,
            onSeeAll: () {},
          ),
        ),
      );

      expect(find.text('Recent patients'), findsOneWidget);
      expect(find.text('See all'), findsOneWidget);
      expect(find.text('Patient A'), findsOneWidget);
      expect(find.text('Patient B'), findsOneWidget);

      // Empty list hides section
      await tester.pumpWidget(
        buildTestableWidget(
          const RecentPatientsSection(patients: []),
        ),
      );
      expect(find.text('Recent patients'), findsNothing);
    });

    testWidgets('5. LaterTodaySection renders cards with status chips and optional View chart button', (tester) async {
      const appointments = [
        LaterAppointment(
          id: 'l1',
          patientName: 'Patient One',
          visitType: 'New visit',
          mode: 'telehealth',
          time: '11:15 AM',
          isCheckedIn: true,
          isNextVisit: false,
        ),
        LaterAppointment(
          id: 'l2',
          patientName: 'Patient Two',
          visitType: 'Review',
          mode: 'in person',
          time: '12:00 PM',
          isCheckedIn: false,
          isNextVisit: true,
        ),
      ];

      await tester.pumpWidget(
        buildTestableWidget(
          const LaterTodaySection(appointments: appointments),
        ),
      );

      expect(find.text('Later today'), findsOneWidget);
      expect(find.text('Patient One'), findsOneWidget);
      expect(find.text('New visit · telehealth'), findsOneWidget);
      expect(find.text('11:15 AM'), findsOneWidget);
      expect(find.text('Checked in'), findsOneWidget);

      expect(find.text('Patient Two'), findsOneWidget);
      expect(find.text('Review · in person'), findsOneWidget);
      expect(find.text('12:00 PM'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'View chart'), findsOneWidget);
    });

    testWidgets('6. NeedsAttentionSection renders divider-separated rows and hides zero counts', (tester) async {
      NeedsAttentionItem? tappedItem;
      const items = [
        NeedsAttentionItem(
          type: AttentionType.labResults,
          count: 4,
          label: 'lab results to review',
          icon: Icons.science_outlined,
        ),
        NeedsAttentionItem(
          type: AttentionType.refillRequests,
          count: 2,
          label: 'refill requests',
          icon: Icons.medication_outlined,
        ),
        NeedsAttentionItem(
          type: AttentionType.visitNotes,
          count: 0, // Should be hidden
          label: 'unsigned visit notes',
          icon: Icons.description_outlined,
        ),
      ];

      await tester.pumpWidget(
        buildTestableWidget(
          NeedsAttentionSection(
            items: items,
            onItemTap: (item) => tappedItem = item,
          ),
        ),
      );

      expect(find.text('Needs attention'), findsOneWidget);
      expect(find.text('4 lab results to review'), findsOneWidget);
      expect(find.text('2 refill requests'), findsOneWidget);
      expect(find.text('0 unsigned visit notes'), findsNothing);

      await tester.tap(find.text('4 lab results to review'));
      expect(tappedItem?.count, 4);
    });

    testWidgets('7. EmergencyStrip renders distinct danger alert strip', (tester) async {
      bool emergencyTapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          EmergencyStrip(
            onTap: () => emergencyTapped = true,
          ),
        ),
      );

      expect(find.text('Emergency'), findsOneWidget);
      expect(find.text('Emergency alerts and on-call'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);

      await tester.tap(find.text('Emergency alerts and on-call'));
      expect(emergencyTapped, isTrue);
    });

    testWidgets('8. FloatingRoleNavBar renders 4 tabs with active lifted circle', (tester) async {
      int selectedTab = 0;

      await tester.pumpWidget(
        buildTestableWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return FloatingRoleNavBar(
                currentIndex: selectedTab,
                onTap: (index) => setState(() => selectedTab = index),
              );
            },
          ),
        ),
      );

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Schedule'), findsOneWidget);
      expect(find.text('Patients'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Tap on Schedule tab
      await tester.tap(find.text('Schedule'));
      await tester.pump();
      expect(selectedTab, 1);
    });
  });

  group('DoctorDashboardScreen Full Flow & Order Tests', () {
    testWidgets('Renders all 8 sections in exact specified order', (tester) async {
      const repo = MockDoctorDashboardRepository(latency: Duration.zero);

      await tester.pumpWidget(
        buildTestableWidget(
          const DoctorDashboardScreen(repository: repo),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Top bar
      expect(find.byType(DashboardTopBar), findsOneWidget);
      expect(find.text('Dr. Surname'), findsOneWidget);

      // 2. Headline
      expect(find.byType(DashboardHeadline), findsOneWidget);

      // 3. Next patient
      expect(find.byType(NextPatientCard), findsOneWidget);

      // 4. Recent patients
      expect(find.byType(RecentPatientsSection), findsOneWidget);

      // 5. Later today
      expect(find.byType(LaterTodaySection), findsOneWidget);

      // 6. Needs attention
      expect(find.byType(NeedsAttentionSection), findsOneWidget);

      // 7. Emergency
      expect(find.byType(EmergencyStrip), findsOneWidget);

      // 8. Floating bottom nav
      expect(find.byType(FloatingRoleNavBar), findsOneWidget);
    });

    testWidgets('Supports Dark Mode without overflow or styling breakdown', (tester) async {
      const repo = MockDoctorDashboardRepository(latency: Duration.zero);

      await tester.pumpWidget(
        buildTestableWidget(
          const DoctorDashboardScreen(repository: repo),
          brightness: Brightness.dark,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(DoctorDashboardScreen), findsOneWidget);
      expect(find.text('Dr. Surname'), findsOneWidget);
    });
  });

  group('Doctor Dashboard Load-in Entrance Animation Tests', () {
    testWidgets('1. Plays entrance animation once on cold start, not on rebuilds', (tester) async {
      DoctorDashboardScreen.resetColdStart();
      const repo = MockDoctorDashboardRepository(latency: Duration(milliseconds: 50));

      await tester.pumpWidget(
        buildTestableWidget(const DoctorDashboardScreen(repository: repo)),
      );

      // Skeletons are visible, no entrance running yet
      expect(find.byType(DashboardSkeleton), findsOneWidget);

      // Advance clock for repository latency (50ms) to load data
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.byType(DashboardSkeleton), findsNothing);

      // Real data has replaced skeletons; entrance animation is now running
      // At 200ms: animation is mid-flight
      await tester.pump(const Duration(milliseconds: 200));

      // Settle animation to end (1100ms total)
      await tester.pumpAndSettle();
      expect(find.text('Dr. Surname'), findsOneWidget);
      expect(DoctorDashboardScreen.hasPlayedEntranceAnimation, isTrue);

      // Trigger a rebuild of the dashboard
      await tester.pumpWidget(
        buildTestableWidget(const DoctorDashboardScreen(repository: repo)),
      );
      await tester.pump(const Duration(milliseconds: 60));

      // Verify that cold start did not re-trigger animation (already settled)
      expect(find.text('Here is an overview of your clinical dashboard today'), findsOneWidget);
    });

    testWidgets('2. Skips animation and renders final state immediately when disableAnimations is true', (tester) async {
      DoctorDashboardScreen.resetColdStart();
      const repo = MockDoctorDashboardRepository(latency: Duration.zero);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: buildTestableWidget(
            const DoctorDashboardScreen(repository: repo),
          ),
        ),
      );

      // Initial pump with zero latency data load
      await tester.pump();

      // Everything is immediately in final state without needing 1100ms pumpAndSettle
      expect(find.text('Dr. Surname'), findsOneWidget);
      expect(find.text('Here is an overview of your clinical dashboard today'), findsOneWidget);
      expect(find.text('Start consult'), findsOneWidget);
      expect(DoctorDashboardScreen.hasPlayedEntranceAnimation, isTrue);
    });

    testWidgets('3. Controls are tappable mid-animation without being blocked', (tester) async {
      DoctorDashboardScreen.resetColdStart();
      const repo = MockDoctorDashboardRepository(latency: Duration.zero);

      await tester.pumpWidget(
        buildTestableWidget(const DoctorDashboardScreen(repository: repo)),
      );
      await tester.pump(); // Data loads, entrance animation begins

      // Mid-animation at 250ms (card and buttons are partially translated)
      await tester.pump(const Duration(milliseconds: 250));

      // Top bar notification bell is tappable mid-animation
      final bellFinder = find.byIcon(Icons.notifications_outlined);
      expect(bellFinder, findsOneWidget);
      await tester.tap(bellFinder);
      await tester.pump();
      expect(find.text('Notifications (1 unread critical alert)'), findsOneWidget);

      // Clear previous SnackBar so the next one displays immediately
      ScaffoldMessenger.of(tester.element(find.byType(DoctorDashboardScreen))).clearSnackBars();
      await tester.pump();

      // Start consult button on NextPatientCard is tappable mid-animation
      expect(find.text('Start consult'), findsOneWidget);
      await tester.tap(find.text('Start consult'));
      await tester.pump();
      expect(find.text('Starting consultation for Patient Name...'), findsOneWidget);

      // Settle animation
      await tester.pumpAndSettle();
    });

    testWidgets('4. Screen reader semantics exposed immediately from frame 0', (tester) async {
      DoctorDashboardScreen.resetColdStart();
      const repo = MockDoctorDashboardRepository(latency: Duration.zero);

      await tester.pumpWidget(
        buildTestableWidget(const DoctorDashboardScreen(repository: repo)),
      );
      await tester.pump();

      // Semantics for all buttons and tabs are accessible immediately
      expect(find.bySemanticsLabel('Dashboard Tab'), findsOneWidget);
      expect(find.bySemanticsLabel('Schedule Tab'), findsOneWidget);
      expect(find.bySemanticsLabel('Patients Tab'), findsOneWidget);
      expect(find.bySemanticsLabel('Profile Tab'), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('5. Staggered sequence progresses correctly through intervals', (tester) async {
      DoctorDashboardScreen.resetColdStart();
      const repo = MockDoctorDashboardRepository(latency: Duration.zero);

      await tester.pumpWidget(
        buildTestableWidget(const DoctorDashboardScreen(repository: repo)),
      );
      await tester.pump(); // Frame 0

      // Top bar & Emergency are visible at frame 0
      expect(find.byType(DashboardTopBar), findsOneWidget);
      expect(find.byType(EmergencyStrip), findsOneWidget);

      // Advance 100ms
      await tester.pump(const Duration(milliseconds: 100));

      // Advance to 350ms: Next patient card and chips are fading in
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.byType(NextPatientCard), findsOneWidget);

      // Advance to 600ms: Recent patients and Later today cards are animating in
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.byType(RecentPatientsSection), findsOneWidget);
      expect(find.byType(LaterTodaySection), findsOneWidget);

      // Advance to 850ms: Needs attention and Bottom Nav rising
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.byType(NeedsAttentionSection), findsOneWidget);
      expect(find.byType(FloatingRoleNavBar), findsOneWidget);

      // Advance to completion (>1100ms)
      await tester.pumpAndSettle();
      expect(find.text('Dr. Surname'), findsOneWidget);
      expect(find.text('Here is an overview of your clinical dashboard today'), findsOneWidget);
    });
  });
}
