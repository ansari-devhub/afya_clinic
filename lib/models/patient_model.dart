enum PatientStatus { stable, critical, waiting, inConsultation }

enum Gender { male, female, other }

class PatientModel {
  final String id;
  final String mrn; // Medical Record Number
  final String name;
  final DateTime dob;
  final Gender gender;
  final String? photoUrl;
  final PatientStatus status;
  final String department;
  final String? bloodType;
  final int? heartRate;
  final int? weight;
  final String? height;
  final List<String> allergies;
  final List<String> chronicConditions;
  final DateTime? lastVisit;
  final String? queueNumber;
  final DateTime? appointmentTime;

  PatientModel({
    required this.id,
    required this.mrn,
    required this.name,
    required this.dob,
    required this.gender,
    this.photoUrl,
    required this.status,
    required this.department,
    this.bloodType,
    this.heartRate,
    this.weight,
    this.height,
    this.allergies = const [],
    this.chronicConditions = const [],
    this.lastVisit,
    this.queueNumber,
    this.appointmentTime,
  });

  int get age {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  String get genderString {
    switch (gender) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mrn': mrn,
      'name': name,
      'dob': dob.toIso8601String(),
      'gender': gender.toString().split('.').last,
      'photoUrl': photoUrl,
      'status': status.toString().split('.').last,
      'department': department,
      'bloodType': bloodType,
      'heartRate': heartRate,
      'weight': weight,
      'height': height,
      'allergies': allergies,
      'chronicConditions': chronicConditions,
      'lastVisit': lastVisit?.toIso8601String(),
      'queueNumber': queueNumber,
      'appointmentTime': appointmentTime?.toIso8601String(),
    };
  }

  factory PatientModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic val, [DateTime? fallback]) {
      if (val is String) {
        return DateTime.tryParse(val) ?? (fallback ?? DateTime.now());
      }
      if (val != null && val.runtimeType.toString().contains('Timestamp')) {
        return (val as dynamic).toDate();
      }
      return fallback ?? DateTime.now();
    }

    return PatientModel(
      id: map['id'] ?? '',
      mrn: map['mrn'] ?? '',
      name: map['name'] ?? '',
      dob: parseDate(map['dob']),
      gender: Gender.values.firstWhere(
        (e) => e.toString().split('.').last == map['gender'],
        orElse: () => Gender.other,
      ),
      photoUrl: map['photoUrl'],
      status: PatientStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => PatientStatus.waiting,
      ),
      department: map['department'] ?? '',
      bloodType: map['bloodType'],
      heartRate: map['heartRate'],
      weight: map['weight'],
      height: map['height'],
      allergies: List<String>.from(map['allergies'] ?? []),
      chronicConditions: List<String>.from(map['chronicConditions'] ?? []),
      lastVisit: map['lastVisit'] != null ? parseDate(map['lastVisit']) : null,
      queueNumber: map['queueNumber'],
      appointmentTime: map['appointmentTime'] != null ? parseDate(map['appointmentTime']) : null,
    );
  }
}
