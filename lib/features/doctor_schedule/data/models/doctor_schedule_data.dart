import 'package:flutter/material.dart';
import '../../../../core/widgets/clinical_status_chip.dart';

/// Single-select filter chips matching spec: All, In person, Telehealth, Completed.
enum ScheduleFilter {
  all,
  inPerson,
  telehealth,
  completed,
}

extension ScheduleFilterX on ScheduleFilter {
  String get label {
    switch (this) {
      case ScheduleFilter.all:
        return 'All';
      case ScheduleFilter.inPerson:
        return 'In person';
      case ScheduleFilter.telehealth:
        return 'Telehealth';
      case ScheduleFilter.completed:
        return 'Completed';
    }
  }
}

/// View mode segmented control: Day or Week.
enum ScheduleViewMode {
  day,
  week,
}

/// Model representing a doctor's scheduled appointment.
class ScheduleAppointment {
  final String id;
  final String patientName;
  final String? patientPhotoUrl;
  final int age;
  final String sex;
  final String visitType;
  final bool isTelehealth;
  final DateTime startTime;
  final DateTime endTime;
  final String timeFormatted;
  final ClinicalAppointmentStatus status;

  const ScheduleAppointment({
    required this.id,
    required this.patientName,
    this.patientPhotoUrl,
    required this.age,
    required this.sex,
    required this.visitType,
    required this.isTelehealth,
    required this.startTime,
    required this.endTime,
    required this.timeFormatted,
    required this.status,
  });

  String get modeString => isTelehealth ? 'Telehealth' : 'In person';

  String get subtitle => '$visitType · $modeString';

  String get compactSubtitle => '$visitType · $age yrs, $sex';

  String get initials {
    final parts = patientName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return patientName.isNotEmpty ? patientName.substring(0, 1).toUpperCase() : 'P';
  }

  ScheduleAppointment copyWith({
    String? id,
    String? patientName,
    String? patientPhotoUrl,
    int? age,
    String? sex,
    String? visitType,
    bool? isTelehealth,
    DateTime? startTime,
    DateTime? endTime,
    String? timeFormatted,
    ClinicalAppointmentStatus? status,
  }) {
    return ScheduleAppointment(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      patientPhotoUrl: patientPhotoUrl ?? this.patientPhotoUrl,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      visitType: visitType ?? this.visitType,
      isTelehealth: isTelehealth ?? this.isTelehealth,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      timeFormatted: timeFormatted ?? this.timeFormatted,
      status: status ?? this.status,
    );
  }
}

/// Model representing a blocked time slot or break.
class ScheduleBlock {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String timeRangeFormatted;
  final String reason;
  final String repeat;
  final IconData icon;

  const ScheduleBlock({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.timeRangeFormatted,
    required this.reason,
    this.repeat = 'None',
    this.icon = Icons.free_breakfast_outlined,
  });
}

/// Model representing an open bookable slot.
class OpenSlot {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final String timeRangeFormatted;

  const OpenSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.timeRangeFormatted,
  });
}

/// Timeline row types matching the spec:
/// a) regular appointment card
/// b) completed appointment (dimmed 60% opacity)
/// c) next patient (filled primary card from dashboard)
/// e) blocked break (dashed border)
/// f) open slot (dashed border)
enum TimelineRowType {
  appointment,
  completed,
  next,
  blocked,
  openSlot,
}

/// Unified timeline row item.
class TimelineRowItem {
  final String id;
  final String timeLabel;
  final DateTime time;
  final TimelineRowType type;
  final ScheduleAppointment? appointment;
  final ScheduleBlock? block;
  final OpenSlot? openSlot;

  const TimelineRowItem({
    required this.id,
    required this.timeLabel,
    required this.time,
    required this.type,
    this.appointment,
    this.block,
    this.openSlot,
  });

  bool get isAppointment =>
      type == TimelineRowType.appointment ||
      type == TimelineRowType.completed ||
      type == TimelineRowType.next;
}

/// Day summary model for the summary row.
class DayScheduleSummary {
  final DateTime date;
  final int totalAppointments;
  final int telehealthAppointments;

  const DayScheduleSummary({
    required this.date,
    required this.totalAppointments,
    required this.telehealthAppointments,
  });

  bool isToday([DateTime? now]) {
    final current = now ?? DateTime.now();
    return date.year == current.year &&
        date.month == current.month &&
        date.day == current.day;
  }

  String getFormattedTitle([DateTime? now]) {
    if (isToday(now)) {
      return 'Today · $totalAppointments appointments';
    }
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final w = weekdays[date.weekday - 1];
    final m = months[date.month - 1];
    return '$w, $m ${date.day} · $totalAppointments appointments';
  }

  String get formattedTelehealth => '$telehealthAppointments telehealth';
}
