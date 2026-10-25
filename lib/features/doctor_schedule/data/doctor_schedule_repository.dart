import 'package:flutter/material.dart';
import '../../../../core/widgets/clinical_status_chip.dart';
import 'models/doctor_schedule_data.dart';

/// Contract for doctor schedule repository.
abstract class DoctorScheduleRepository {
  Future<List<TimelineRowItem>> fetchTimeline({
    required DateTime date,
    ScheduleFilter filter = ScheduleFilter.all,
  });

  Future<DayScheduleSummary> fetchDaySummary(DateTime date);

  Future<Set<int>> fetchAppointmentDaysForWeek(DateTime startOfWeek);

  Future<Set<DateTime>> fetchAppointmentDaysForMonth(DateTime month);

  Future<void> blockTime({
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required String reason,
    required String repeat,
  });
}

/// Mock implementation providing realistic dummy data strictly aligned with the mock layout.
class MockDoctorScheduleRepository implements DoctorScheduleRepository {
  final Duration latency;

  // Stored state for dynamically added blocks
  final List<ScheduleBlock> _dynamicBlocks = [];

  MockDoctorScheduleRepository({
    this.latency = Duration.zero,
  });

  DateTime _stripTime(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  @override
  Future<List<TimelineRowItem>> fetchTimeline({
    required DateTime date,
    ScheduleFilter filter = ScheduleFilter.all,
  }) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }

    final now = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;

    // Base appointments for the selected day
    final y = date.year;
    final m = date.month;
    final d = date.day;

    final appointments = <ScheduleAppointment>[
      ScheduleAppointment(
        id: 'apt-1',
        patientName: 'James Wilson',
        age: 52,
        sex: 'Male',
        visitType: 'General checkup',
        isTelehealth: false,
        startTime: DateTime(y, m, d, 9, 0),
        endTime: DateTime(y, m, d, 9, 30),
        timeFormatted: '9:00 AM',
        status: ClinicalAppointmentStatus.completed,
      ),
      ScheduleAppointment(
        id: 'apt-2',
        patientName: 'Sarah M. Jenkins',
        age: 45,
        sex: 'Female',
        visitType: 'Cardiology follow-up',
        isTelehealth: false,
        startTime: DateTime(y, m, d, 10, 30),
        endTime: DateTime(y, m, d, 11, 0),
        timeFormatted: '10:30 AM',
        status: ClinicalAppointmentStatus.checkedIn,
      ),
      ScheduleAppointment(
        id: 'apt-3',
        patientName: 'David Kim',
        age: 38,
        sex: 'Male',
        visitType: 'Cardiology review',
        isTelehealth: true,
        startTime: DateTime(y, m, d, 11, 15),
        endTime: DateTime(y, m, d, 11, 45),
        timeFormatted: '11:15 AM',
        status: ClinicalAppointmentStatus.upcoming,
      ),
      ScheduleAppointment(
        id: 'apt-4',
        patientName: 'Emma Watson',
        age: 29,
        sex: 'Female',
        visitType: 'Routine ECG',
        isTelehealth: false,
        startTime: DateTime(y, m, d, 14, 0),
        endTime: DateTime(y, m, d, 14, 30),
        timeFormatted: '2:00 PM',
        status: ClinicalAppointmentStatus.upcoming,
      ),
      ScheduleAppointment(
        id: 'apt-5',
        patientName: 'Michael Chen',
        age: 61,
        sex: 'Male',
        visitType: 'Hypertension check',
        isTelehealth: false,
        startTime: DateTime(y, m, d, 15, 0),
        endTime: DateTime(y, m, d, 15, 30),
        timeFormatted: '3:00 PM',
        status: ClinicalAppointmentStatus.checkedIn,
      ),
      ScheduleAppointment(
        id: 'apt-6',
        patientName: 'Anita Patel',
        age: 34,
        sex: 'Female',
        visitType: 'Lab review',
        isTelehealth: false,
        startTime: DateTime(y, m, d, 15, 45),
        endTime: DateTime(y, m, d, 16, 15),
        timeFormatted: '3:45 PM',
        status: ClinicalAppointmentStatus.upcoming,
      ),
      ScheduleAppointment(
        id: 'apt-7',
        patientName: 'Grace Hopper',
        age: 42,
        sex: 'Female',
        visitType: 'Prescription review',
        isTelehealth: true,
        startTime: DateTime(y, m, d, 16, 30),
        endTime: DateTime(y, m, d, 17, 0),
        timeFormatted: '4:30 PM',
        status: ClinicalAppointmentStatus.upcoming,
      ),
      ScheduleAppointment(
        id: 'apt-8',
        patientName: 'Robert Taylor',
        age: 50,
        sex: 'Male',
        visitType: 'Post-op checkup',
        isTelehealth: false,
        startTime: DateTime(y, m, d, 17, 15),
        endTime: DateTime(y, m, d, 17, 45),
        timeFormatted: '5:15 PM',
        status: ClinicalAppointmentStatus.upcoming,
      ),
    ];

    // Blocks
    final blocks = <ScheduleBlock>[
      ScheduleBlock(
        id: 'blk-lunch',
        title: 'Lunch break',
        startTime: DateTime(y, m, d, 12, 0),
        endTime: DateTime(y, m, d, 13, 0),
        timeRangeFormatted: '12:00 PM - 1:00 PM',
        reason: 'Staff Lunch',
        repeat: 'Daily',
        icon: Icons.free_breakfast_outlined,
      ),
      ..._dynamicBlocks.where((b) =>
          b.startTime.year == y &&
          b.startTime.month == m &&
          b.startTime.day == d),
    ];

    // Open slots
    final openSlots = <OpenSlot>[
      OpenSlot(
        id: 'slot-1',
        startTime: DateTime(y, m, d, 13, 0),
        endTime: DateTime(y, m, d, 14, 0),
        timeRangeFormatted: '1:00 PM - 2:00 PM',
      ),
    ];

    // Build timeline items
    final items = <TimelineRowItem>[];

    // Find the first non-completed appointment today to mark as next patient
    String? nextPatientId;
    if (isToday) {
      for (final apt in appointments) {
        if (apt.status != ClinicalAppointmentStatus.completed) {
          nextPatientId = apt.id;
          break;
        }
      }
    }

    // Add appointments
    for (final apt in appointments) {
      // Filter logic
      if (filter == ScheduleFilter.inPerson && apt.isTelehealth) continue;
      if (filter == ScheduleFilter.telehealth && !apt.isTelehealth) continue;
      if (filter == ScheduleFilter.completed &&
          apt.status != ClinicalAppointmentStatus.completed) {
        continue;
      }

      TimelineRowType rowType;
      if (apt.status == ClinicalAppointmentStatus.completed) {
        rowType = TimelineRowType.completed;
      } else if (apt.id == nextPatientId) {
        rowType = TimelineRowType.next;
      } else {
        rowType = TimelineRowType.appointment;
      }

      items.add(TimelineRowItem(
        id: apt.id,
        timeLabel: apt.timeFormatted,
        time: apt.startTime,
        type: rowType,
        appointment: apt,
      ));
    }

    // Add blocks (show in All or inPerson filter)
    if (filter == ScheduleFilter.all || filter == ScheduleFilter.inPerson) {
      for (final blk in blocks) {
        final hour = blk.startTime.hour;
        final minute = blk.startTime.minute.toString().padLeft(2, '0');
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

        items.add(TimelineRowItem(
          id: blk.id,
          timeLabel: '$displayHour:$minute $period',
          time: blk.startTime,
          type: TimelineRowType.blocked,
          block: blk,
        ));
      }

      for (final slot in openSlots) {
        final hour = slot.startTime.hour;
        final minute = slot.startTime.minute.toString().padLeft(2, '0');
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

        items.add(TimelineRowItem(
          id: slot.id,
          timeLabel: '$displayHour:$minute $period',
          time: slot.startTime,
          type: TimelineRowType.openSlot,
          openSlot: slot,
        ));
      }
    }

    // Sort by time
    items.sort((a, b) => a.time.compareTo(b.time));
    return items;
  }

  @override
  Future<DayScheduleSummary> fetchDaySummary(DateTime date) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }

    return DayScheduleSummary(
      date: date,
      totalAppointments: 8,
      telehealthAppointments: 2,
    );
  }

  @override
  Future<Set<int>> fetchAppointmentDaysForWeek(DateTime startOfWeek) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }

    // Mon to Sat have appointments, Sunday is off
    final days = <int>{};
    for (int i = 0; i < 7; i++) {
      final d = startOfWeek.add(Duration(days: i));
      if (d.weekday != DateTime.sunday) {
        days.add(d.day);
      }
    }
    return days;
  }

  @override
  Future<Set<DateTime>> fetchAppointmentDaysForMonth(DateTime month) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }

    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final appointmentDates = <DateTime>{};

    for (int day = 1; day <= daysInMonth; day++) {
      final dt = DateTime(month.year, month.month, day);
      if (dt.weekday != DateTime.sunday) {
        appointmentDates.add(_stripTime(dt));
      }
    }
    return appointmentDates;
  }

  @override
  Future<void> blockTime({
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required String reason,
    required String repeat,
  }) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }

    final startDt = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );
    final endDt = DateTime(
      date.year,
      date.month,
      date.day,
      endTime.hour,
      endTime.minute,
    );

    final startPeriod = startTime.hour >= 12 ? 'PM' : 'AM';
    final startDisplayHour = startTime.hour > 12
        ? startTime.hour - 12
        : (startTime.hour == 0 ? 12 : startTime.hour);
    final startMin = startTime.minute.toString().padLeft(2, '0');

    final endPeriod = endTime.hour >= 12 ? 'PM' : 'AM';
    final endDisplayHour = endTime.hour > 12
        ? endTime.hour - 12
        : (endTime.hour == 0 ? 12 : endTime.hour);
    final endMin = endTime.minute.toString().padLeft(2, '0');

    final rangeStr = '$startDisplayHour:$startMin $startPeriod - $endDisplayHour:$endMin $endPeriod';

    _dynamicBlocks.add(
      ScheduleBlock(
        id: 'blk-${DateTime.now().millisecondsSinceEpoch}',
        title: reason,
        startTime: startDt,
        endTime: endDt,
        timeRangeFormatted: rangeStr,
        reason: reason,
        repeat: repeat,
        icon: Icons.event_busy_outlined,
      ),
    );
  }
}
