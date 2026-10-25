import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:afya_clinic/core/theme/clinical_tokens.dart';
import 'package:afya_clinic/core/theme/theme_controller.dart';
import 'package:afya_clinic/core/widgets/floating_role_nav_bar.dart';
import 'package:afya_clinic/core/widgets/settings/clinical_settings_group.dart';
import 'package:afya_clinic/core/widgets/settings/clinical_settings_row.dart';
import 'package:afya_clinic/core/widgets/settings/clinical_switch.dart';
import 'package:afya_clinic/features/doctor_profile/data/doctor_profile_repository.dart';
import 'package:afya_clinic/features/doctor_profile/data/models/doctor_profile_data.dart';
import 'package:afya_clinic/features/doctor_profile/presentation/doctor_profile_screen.dart';
import 'package:afya_clinic/features/doctor_profile/presentation/widgets/logout_button.dart';
import 'package:afya_clinic/features/doctor_profile/presentation/widgets/profile_hero_card.dart';
import 'package:afya_clinic/features/doctor_profile/presentation/widgets/profile_stats_strip.dart';
import 'package:afya_clinic/features/doctor_profile/presentation/widgets/profile_title_bar.dart';

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

  const testDetails = DoctorProfileDetails(
    name: 'Dr. Sarah Jenkins',
    specialty: 'Cardiology',
    facility: 'Afya Premier Medical Centre',
    isVerified: true,
    registrationNumber: 'MED-93821-KMPDC',
    photoUrl: null,
  );

  const testStats = DoctorStats(
    experienceYears: 12,
    totalPatients: 1240,
    totalConsults: 3860,
  );

  const testAvailability = AvailabilitySettings(
    acceptingAppointments: true,
    onCallToday: false,
    workingHours: 'Mon - Fri: 08:00 - 17:00',
    upcomingBookingsCount: 3,
  );

  const testSecurity = SecuritySettings(
    biometricUnlock: false,
    activeSessionsCount: 2,
  );

  final mockData = DoctorProfileData(
    details: testDetails,
    stats: testStats,
    availability: testAvailability,
    security: testSecurity,
    language: 'English',
    appVersion: '1.0.0',
  );

  group('Doctor Profile Component Tests', () {
    testWidgets('1. ProfileTitleBar renders title and toggles pencil / check icon', (tester) async {
      bool editToggled = false;

      await tester.pumpWidget(
        buildTestableWidget(
          ProfileTitleBar(
            isEditing: false,
            onToggleEdit: () => editToggled = true,
          ),
        ),
      );

      // Title
      expect(find.text('Profile'), findsOneWidget);
      // Pencil icon when not editing
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsNothing);

      // Tap pencil button
      await tester.tap(find.byIcon(Icons.edit_outlined));
      expect(editToggled, isTrue);

      // Pump with isEditing: true
      await tester.pumpWidget(
        buildTestableWidget(
          ProfileTitleBar(
            isEditing: true,
            onToggleEdit: () {},
          ),
        ),
      );
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsNothing);
    });

    testWidgets('2. ProfileHeroCard renders details, verified badge, masked reg number, and camera button in edit mode', (tester) async {
      bool cameraTapped = false;
      final nameCtrl = TextEditingController(text: mockData.details.name);
      final specCtrl = TextEditingController(text: mockData.details.specialty);
      final facCtrl = TextEditingController(text: mockData.details.facility);

      await tester.pumpWidget(
        buildTestableWidget(
          ProfileHeroCard(
            details: mockData.details,
            isEditing: false,
            nameController: nameCtrl,
            specialtyController: specCtrl,
            facilityController: facCtrl,
            onChangePhoto: () => cameraTapped = true,
          ),
        ),
      );

      // Doctor name
      expect(find.text('Dr. Sarah Jenkins'), findsOneWidget);
      // Specialty & facility (separate lines in full-bleed hero spec)
      expect(find.text('Cardiology'), findsOneWidget);
      expect(find.text('Afya Premier Medical Centre'), findsOneWidget);

      // Verified badge chip with icon
      expect(find.text('Verified'), findsOneWidget);
      expect(find.byIcon(Icons.verified_rounded), findsOneWidget);

      // Masked Registration Number chip: must NEVER show full reg number
      expect(find.text('Reg. No. ***PDC'), findsOneWidget);
      expect(find.text('MED-93821-KMPDC'), findsNothing);

      // Camera button is hidden in view mode
      expect(find.byIcon(Icons.camera_alt_outlined), findsNothing);

      // Re-pump with isEditing: true
      await tester.pumpWidget(
        buildTestableWidget(
          ProfileHeroCard(
            details: mockData.details,
            isEditing: true,
            nameController: nameCtrl,
            specialtyController: specCtrl,
            facilityController: facCtrl,
            onChangePhoto: () => cameraTapped = true,
          ),
        ),
      );

      // Camera button is now visible in edit mode
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.camera_alt_outlined));
      expect(cameraTapped, isTrue);
    });

    testWidgets('3. ProfileHeroCard enters inline edit mode and renders text fields', (tester) async {
      final nameCtrl = TextEditingController(text: mockData.details.name);
      final specCtrl = TextEditingController(text: mockData.details.specialty);
      final facCtrl = TextEditingController(text: mockData.details.facility);

      await tester.pumpWidget(
        buildTestableWidget(
          ProfileHeroCard(
            details: mockData.details,
            isEditing: true,
            nameController: nameCtrl,
            specialtyController: specCtrl,
            facilityController: facCtrl,
            onChangePhoto: () {},
          ),
        ),
      );

      // In edit mode, 3 text fields should be rendered
      expect(find.byType(TextField), findsNWidgets(3));
      expect(find.text('Dr. Sarah Jenkins'), findsOneWidget);
    });

    testWidgets('4. ProfileStatsStrip renders 3 equal columns with formatted thousands after count-up animation', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          ProfileStatsStrip(stats: mockData.stats),
        ),
      );

      // Initially at frame 0, count-up starts at 0
      expect(find.text('0 yrs'), findsOneWidget);
      expect(find.text('0'), findsNWidgets(2));

      // Advance clock and settle animation (1440ms)
      await tester.pumpAndSettle();

      // Final formatted values
      expect(find.text('12 yrs'), findsOneWidget);
      expect(find.text('1,240'), findsOneWidget);
      expect(find.text('3,860'), findsOneWidget);

      // Labels
      expect(find.text('Experience'), findsOneWidget);
      expect(find.text('Patients'), findsOneWidget);
      expect(find.text('Consults'), findsOneWidget);

      // Icons
      expect(find.byIcon(Icons.history_edu_outlined), findsOneWidget);
      expect(find.byIcon(Icons.people_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsOneWidget);
    });

    testWidgets('4b. ProfileStatsStrip respects reduced motion (disableAnimations) by skipping to final values', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: buildTestableWidget(
            ProfileStatsStrip(stats: mockData.stats),
          ),
        ),
      );

      // Immediately renders final values without requiring pumpAndSettle
      await tester.pump();
      expect(find.text('12 yrs'), findsOneWidget);
      expect(find.text('1,240'), findsOneWidget);
      expect(find.text('3,860'), findsOneWidget);
    });

    testWidgets('4c. ProfileStatsStrip exposes accessible semantics with final values', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          ProfileStatsStrip(stats: mockData.stats),
        ),
      );

      // Semantics labels expose the final values even while animating
      expect(find.bySemanticsLabel('Experience: 12 yrs'), findsOneWidget);
      expect(find.bySemanticsLabel('Patients: 1,240'), findsOneWidget);
      expect(find.bySemanticsLabel('Consults: 3,860'), findsOneWidget);
    });

    testWidgets('4d. ProfileStatsStrip re-animates only when stats values change', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          ProfileStatsStrip(stats: mockData.stats),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1,240'), findsOneWidget);

      // Re-pump with identical stats: should stay settled without restarting from 0
      await tester.pumpWidget(
        buildTestableWidget(
          ProfileStatsStrip(stats: mockData.stats),
        ),
      );
      await tester.pump();
      expect(find.text('1,240'), findsOneWidget);

      // Re-pump with updated stats: re-animates toward new value
      const updatedStats = DoctorStats(
        experienceYears: 12,
        totalPatients: 1500,
        totalConsults: 4000,
      );
      await tester.pumpWidget(
        buildTestableWidget(
          const ProfileStatsStrip(stats: updatedStats),
        ),
      );
      // Immediately after change, restarted
      expect(find.text('1,500'), findsNothing);

      // Settle new animation
      await tester.pumpAndSettle();
      expect(find.text('1,500'), findsOneWidget);
      expect(find.text('4,000'), findsOneWidget);
    });

    testWidgets('5. ClinicalSettingsRow & ClinicalSettingsGroup render cleanly with dividers', (tester) async {
      bool rowTapped = false;
      bool switchVal = false;

      await tester.pumpWidget(
        buildTestableWidget(
          ClinicalSettingsGroup(
            rows: [
              ClinicalSettingsRow.chevron(
                icon: Icons.notifications_none_rounded,
                label: 'Notifications',
                onTap: () => rowTapped = true,
              ),
              ClinicalSettingsRow.value(
                icon: Icons.language_rounded,
                label: 'Language',
                valueText: 'English',
                onTap: () {},
              ),
              ClinicalSettingsRow.customSwitch(
                icon: Icons.dark_mode_outlined,
                label: 'Dark mode',
                value: switchVal,
                onChanged: (v) => switchVal = v,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Dark mode'), findsOneWidget);

      // Custom switch
      expect(find.byType(ClinicalSwitch), findsOneWidget);

      // Tap first row
      await tester.tap(find.text('Notifications'));
      expect(rowTapped, isTrue);
    });

    testWidgets('6. LogoutButton renders danger styling and shows confirmation dialog', (tester) async {
      bool logoutConfirmed = false;

      await tester.pumpWidget(
        buildTestableWidget(
          LogoutButton(
            appVersion: '1.0.0',
            onLogout: () async {
              logoutConfirmed = true;
            },
          ),
        ),
      );

      // Button label & app version
      expect(find.text('Log out'), findsOneWidget);
      expect(find.text('App version 1.0.0'), findsOneWidget);

      // Tap Log out button
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();

      // Confirmation dialog should be visible (button + dialog title + confirm action)
      expect(find.text('Log out'), findsNWidgets(3));
      expect(find.text('Are you sure you want to log out of your clinical session?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Confirm log out
      await tester.tap(find.widgetWithText(ElevatedButton, 'Log out'));
      await tester.pumpAndSettle();
      expect(logoutConfirmed, isTrue);
    });
  });

  group('DoctorProfileScreen Orchestration Tests', () {
    testWidgets('7. DoctorProfileScreen renders all sections in fixed spec order', (tester) async {
      final repository = MockDoctorProfileRepository(initialData: mockData);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            extensions: const [ClinicalTokens.light],
          ),
          home: DoctorProfileScreen(repository: repository),
        ),
      );

      // Wait for repository data load
      await tester.pumpAndSettle();

      // 1. Title bar
      expect(find.byType(ProfileTitleBar), findsOneWidget);

      // 2. Hero card
      expect(find.byType(ProfileHeroCard), findsOneWidget);

      // 3. Stats strip
      expect(find.byType(ProfileStatsStrip), findsOneWidget);

      // 4. Availability group
      expect(find.text('Availability'), findsOneWidget);
      expect(find.text('Accepting appointments'), findsOneWidget);
      expect(find.text('On-call today'), findsOneWidget);
      expect(find.text('Working hours'), findsOneWidget);

      // 5. Professional group
      expect(find.text('Professional'), findsOneWidget);
      expect(find.text('Personal information'), findsOneWidget);
      expect(find.text('Qualifications and license'), findsOneWidget);
      expect(find.text('Bio and specialties'), findsOneWidget);
      expect(find.text('Facility and department'), findsOneWidget);

      // 6. Preferences group
      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Dark mode'), findsOneWidget);

      // 7. Security and privacy group
      expect(find.text('Security and privacy'), findsOneWidget);
      expect(find.text('Change password'), findsOneWidget);
      expect(find.text('Biometric unlock'), findsOneWidget);
      expect(find.text('Active sessions'), findsOneWidget);
      expect(find.text('Privacy and audit log'), findsOneWidget);

      // 8. Support group
      expect(find.text('Support'), findsOneWidget);
      expect(find.text('Help and support'), findsOneWidget);
      expect(find.text('Terms and about'), findsOneWidget);

      // 9. Log out button & 10. App version
      expect(find.byType(LogoutButton), findsOneWidget);
      expect(find.text('App version 1.0.0'), findsOneWidget);

      // 11. Floating Role Nav Bar with Profile active (index 3)
      final navBarFinder = find.byType(FloatingRoleNavBar);
      expect(navBarFinder, findsOneWidget);
      final navBar = tester.widget<FloatingRoleNavBar>(navBarFinder);
      expect(navBar.currentIndex, equals(3));
    });

    testWidgets('8. Turning off Accepting appointments with bookings triggers confirm dialog', (tester) async {
      final repository = MockDoctorProfileRepository(initialData: mockData);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            extensions: const [ClinicalTokens.light],
          ),
          home: DoctorProfileScreen(repository: repository),
        ),
      );
      await tester.pumpAndSettle();

      // Find Accepting appointments row and tap it
      final acceptingRow = find.widgetWithText(ClinicalSettingsRow, 'Accepting appointments');
      expect(acceptingRow, findsOneWidget);

      await tester.tap(acceptingRow);
      await tester.pumpAndSettle();

      // Dialog should be shown because upcomingBookingsCount = 3
      expect(find.text('Pause Appointments?'), findsOneWidget);
      expect(
        find.text('You currently have 3 upcoming appointments scheduled. Are you sure you want to stop accepting new bookings?'),
        findsOneWidget,
      );

      // Cancel button dismisses dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Pause Appointments?'), findsNothing);
    });

    testWidgets('9. Dark mode switch triggers theme toggle', (tester) async {
      final repository = MockDoctorProfileRepository(initialData: mockData);
      ClinicalThemeController.instance.setDarkMode(false);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            extensions: const [ClinicalTokens.light],
          ),
          home: DoctorProfileScreen(repository: repository),
        ),
      );
      await tester.pumpAndSettle();

      // Find dark mode row
      final darkModeFinder = find.widgetWithText(ClinicalSettingsRow, 'Dark mode');
      expect(darkModeFinder, findsOneWidget);

      await tester.ensureVisible(darkModeFinder);
      await tester.pumpAndSettle();

      // Tap dark mode row to toggle switch
      await tester.tap(darkModeFinder);
      await tester.pumpAndSettle();

      expect(ClinicalThemeController.instance.isDarkMode, isTrue);

      // Reset back to light
      ClinicalThemeController.instance.setDarkMode(false);
    });

    testWidgets('10. Pull to refresh reloads profile data', (tester) async {
      final repository = MockDoctorProfileRepository(initialData: mockData);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            extensions: const [ClinicalTokens.light],
          ),
          home: DoctorProfileScreen(repository: repository),
        ),
      );
      await tester.pumpAndSettle();

      // Trigger pull to refresh
      await tester.fling(find.byType(SingleChildScrollView), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      expect(find.text('Dr. Sarah Jenkins'), findsOneWidget);
    });
  });
}
