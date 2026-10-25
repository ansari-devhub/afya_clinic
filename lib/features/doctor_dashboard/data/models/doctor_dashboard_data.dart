import 'package:flutter/material.dart';

/// Model representing the doctor's profile on the dashboard.
class DoctorProfile {
  final String surname;
  final int unreadNotificationsCount;

  const DoctorProfile({
    required this.surname,
    this.unreadNotificationsCount = 1,
  });

  String get displayName => 'Dr. $surname';

  /// Time-of-day aware greeting: morning (0-11:59), afternoon (12-16:59), evening (17-23:59).
  String getGreeting([DateTime? currentTime]) {
    final now = currentTime ?? DateTime.now();
    final hour = now.hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }
}

/// Model for the next patient card appointment.
class NextPatientAppointment {
  final String id;
  final String name;
  final String? photoUrl;
  final String visitType;
  final int age;
  final String sex;
  final bool isTelehealth;
  final String date;
  final String timeRange;

  const NextPatientAppointment({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.visitType,
    required this.age,
    required this.sex,
    required this.isTelehealth,
    required this.date,
    required this.timeRange,
  });

  String get subtitle => '$visitType · $age yrs, $sex';

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'P';
  }
}

/// Model for recent patients horizontally scrolling list.
class RecentPatient {
  final String id;
  final String name;
  final String? photoUrl;
  final String initials;

  const RecentPatient({
    required this.id,
    required this.name,
    this.photoUrl,
    this.initials = 'PN',
  });
}

/// Model for later today appointment cards.
class LaterAppointment {
  final String id;
  final String patientName;
  final String? photoUrl;
  final String visitType;
  final String mode; // "telehealth" or "in person"
  final String time; // e.g. "11:15 AM"
  final bool isCheckedIn;
  final bool isNextVisit; // shows "View chart" pill button if next

  const LaterAppointment({
    required this.id,
    required this.patientName,
    this.photoUrl,
    required this.visitType,
    required this.mode,
    required this.time,
    this.isCheckedIn = false,
    this.isNextVisit = false,
  });

  String get subtitle => '$visitType · $mode';
}

/// Item in the Needs Attention section.
enum AttentionType {
  labResults,
  refillRequests,
  visitNotes,
  unreadMessages,
}

class NeedsAttentionItem {
  final AttentionType type;
  final int count;
  final String label;
  final IconData icon;

  const NeedsAttentionItem({
    required this.type,
    required this.count,
    required this.label,
    required this.icon,
  });

  String get title => '$count $label';
}

/// Emergency alert data.
class EmergencyAlert {
  final String title;
  final bool hasActiveAlert;

  const EmergencyAlert({
    this.title = 'Emergency alerts and on-call',
    this.hasActiveAlert = true,
  });
}

/// Aggregated doctor dashboard data.
class DoctorDashboardData {
  final DoctorProfile doctor;
  final NextPatientAppointment? nextPatient;
  final List<RecentPatient> recentPatients;
  final List<LaterAppointment> laterToday;
  final List<NeedsAttentionItem> needsAttention;
  final EmergencyAlert emergency;

  const DoctorDashboardData({
    required this.doctor,
    this.nextPatient,
    required this.recentPatients,
    required this.laterToday,
    required this.needsAttention,
    required this.emergency,
  });
}
