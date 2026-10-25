import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  final FirebaseFirestore firestore;

  AppointmentService({required this.firestore});

  Stream<List<AppointmentModel>> getAppointmentsStream({
    String? doctorId,
    String? patientId,
    DateTime? date,
  }) {
    Query query = firestore.collection('appointments');

    if (doctorId != null) {
      query = query.where('doctorId', isEqualTo: doctorId);
    }

    if (patientId != null) {
      query = query.where('patientId', isEqualTo: patientId);
    }

    if (date != null) {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      query = query
          .where('startTime', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('startTime', isLessThanOrEqualTo: endOfDay.toIso8601String());
    }

    return query.orderBy('startTime').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return AppointmentModel.fromMap({...doc.data() as Map<String, dynamic>, 'id': doc.id});
      }).toList();
    });
  }

  Future<void> addAppointment(AppointmentModel appointment) async {
    await firestore.collection('appointments').doc(appointment.id).set(appointment.toMap());
  }

  Future<void> updateAppointment(AppointmentModel appointment) async {
    await firestore.collection('appointments').doc(appointment.id).update(appointment.toMap());
  }

  Future<void> updateAppointmentStatus(String appointmentId, AppointmentStatus status) async {
    await firestore.collection('appointments').doc(appointmentId).update({
      'status': status.toString().split('.').last,
    });
  }

  Future<void> deleteAppointment(String appointmentId) async {
    await firestore.collection('appointments').doc(appointmentId).delete();
  }
}
