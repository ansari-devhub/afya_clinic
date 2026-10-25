enum AppointmentStatus { confirmed, pending, completed, cancelled, checkedIn }

class AppointmentModel {
  final String id;
  final String patientId;
  final String patientName;
  final String? patientPhotoUrl;
  final String doctorId;
  final String doctorName;
  final String? doctorPhotoUrl;
  final DateTime startTime;
  final DateTime endTime;
  final String type;
  final String? room;
  final AppointmentStatus status;
  final String? notes;
  final DateTime createdAt;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    this.patientPhotoUrl,
    required this.doctorId,
    required this.doctorName,
    this.doctorPhotoUrl,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.room,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'patientPhotoUrl': patientPhotoUrl,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorPhotoUrl': doctorPhotoUrl,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'type': type,
      'room': room,
      'status': status.toString().split('.').last,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      patientPhotoUrl: map['patientPhotoUrl'],
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      doctorPhotoUrl: map['doctorPhotoUrl'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      type: map['type'] ?? '',
      room: map['room'],
      status: AppointmentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => AppointmentStatus.pending,
      ),
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
