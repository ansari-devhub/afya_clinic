class ConsultationModel {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final DateTime consultationDate;
  final List<String> presentingSymptoms;
  final String subjective;
  final String objective;
  final String assessment;
  final String plan;
  final VitalsModel vitals;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? completedAt;

  ConsultationModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.consultationDate,
    this.presentingSymptoms = const [],
    this.subjective = '',
    this.objective = '',
    this.assessment = '',
    this.plan = '',
    required this.vitals,
    this.isActive = true,
    required this.createdAt,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'consultationDate': consultationDate.toIso8601String(),
      'presentingSymptoms': presentingSymptoms,
      'subjective': subjective,
      'objective': objective,
      'assessment': assessment,
      'plan': plan,
      'vitals': vitals.toMap(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory ConsultationModel.fromMap(Map<String, dynamic> map) {
    return ConsultationModel(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      consultationDate: DateTime.parse(map['consultationDate']),
      presentingSymptoms: List<String>.from(map['presentingSymptoms'] ?? []),
      subjective: map['subjective'] ?? '',
      objective: map['objective'] ?? '',
      assessment: map['assessment'] ?? '',
      plan: map['plan'] ?? '',
      vitals: VitalsModel.fromMap(map['vitals'] ?? {}),
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.parse(map['createdAt']),
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
    );
  }
}

class VitalsModel {
  final String bloodPressure;
  final int heartRate;
  final double temperature;
  final int spO2;

  VitalsModel({
    this.bloodPressure = '',
    this.heartRate = 0,
    this.temperature = 0.0,
    this.spO2 = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'bloodPressure': bloodPressure,
      'heartRate': heartRate,
      'temperature': temperature,
      'spO2': spO2,
    };
  }

  factory VitalsModel.fromMap(Map<String, dynamic> map) {
    return VitalsModel(
      bloodPressure: map['bloodPressure'] ?? '',
      heartRate: map['heartRate'] ?? 0,
      temperature: (map['temperature'] ?? 0.0).toDouble(),
      spO2: map['spO2'] ?? 0,
    );
  }
}
