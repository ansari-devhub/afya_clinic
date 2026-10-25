import 'package:flutter/material.dart';
import 'models/doctor_dashboard_data.dart';

/// Abstract repository contract for Doctor Dashboard data.
abstract class DoctorDashboardRepository {
  Future<DoctorDashboardData> fetchDashboardData();
}

/// Mock implementation providing dummy data matching the specification and wireframe.
class MockDoctorDashboardRepository implements DoctorDashboardRepository {
  final Duration latency;

  const MockDoctorDashboardRepository({
    this.latency = const Duration(milliseconds: 600),
  });

  @override
  Future<DoctorDashboardData> fetchDashboardData() async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }

    return DoctorDashboardData(
      doctor: const DoctorProfile(
        surname: 'Surname',
        unreadNotificationsCount: 1,
      ),
      nextPatient: const NextPatientAppointment(
        id: 'p-next-01',
        name: 'Patient Name',
        visitType: 'Follow-up',
        age: 45,
        sex: 'F',
        isTelehealth: true,
        date: '14 Oct, Tue',
        timeRange: '10:30 - 11:00',
      ),
      recentPatients: const [
        RecentPatient(id: 'r1', name: 'Patient A', initials: 'PN'),
        RecentPatient(id: 'r2', name: 'Patient B', initials: 'PN'),
        RecentPatient(id: 'r3', name: 'Patient C', initials: 'PN'),
        RecentPatient(id: 'r4', name: 'Patient D', initials: 'PN'),
        RecentPatient(id: 'r5', name: 'Patient E', initials: 'PN'),
      ],
      laterToday: const [
        LaterAppointment(
          id: 'l1',
          patientName: 'Patient Name',
          visitType: 'New visit',
          mode: 'telehealth',
          time: '11:15 AM',
          isCheckedIn: true,
          isNextVisit: false,
        ),
        LaterAppointment(
          id: 'l2',
          patientName: 'Patient Name',
          visitType: 'Review',
          mode: 'in person',
          time: '12:00 PM',
          isCheckedIn: false,
          isNextVisit: true,
        ),
        LaterAppointment(
          id: 'l3',
          patientName: 'Patient Name',
          visitType: 'Consultation',
          mode: 'in person',
          time: '02:30 PM',
          isCheckedIn: false,
          isNextVisit: false,
        ),
      ],
      needsAttention: const [
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
          count: 3,
          label: 'unsigned visit notes',
          icon: Icons.description_outlined,
        ),
        NeedsAttentionItem(
          type: AttentionType.unreadMessages,
          count: 5,
          label: 'unread messages',
          icon: Icons.chat_bubble_outline_rounded,
        ),
      ],
      emergency: const EmergencyAlert(
        title: 'Emergency alerts and on-call',
        hasActiveAlert: true,
      ),
    );
  }
}
