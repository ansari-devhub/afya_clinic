import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/patient_model.dart';

class PatientService {
  final FirebaseFirestore firestore;

  PatientService({required this.firestore});

  Stream<List<PatientModel>> getPatientsStream({PatientStatus? statusFilter}) {
    Query query = firestore.collection('patients');

    if (statusFilter != null) {
      query = query.where('status', isEqualTo: statusFilter.toString().split('.').last);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return PatientModel.fromMap({...doc.data() as Map<String, dynamic>, 'id': doc.id});
      }).toList();
    });
  }

  Future<PatientModel?> getPatient(String patientId) async {
    try {
      final doc = await firestore.collection('patients').doc(patientId).get();
      if (doc.exists) {
        return PatientModel.fromMap({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      debugPrint('Error getting patient: $e');
      return null;
    }
  }

  Future<void> addPatient(PatientModel patient) async {
    await firestore.collection('patients').doc(patient.id).set(patient.toMap());
  }

  Future<void> updatePatient(PatientModel patient) async {
    await firestore.collection('patients').doc(patient.id).update(patient.toMap());
  }

  Future<void> updatePatientStatus(String patientId, PatientStatus status) async {
    await firestore.collection('patients').doc(patientId).update({
      'status': status.toString().split('.').last,
    });
  }

  Future<List<PatientModel>> searchPatients(String query) async {
    try {
      final snapshot = await firestore
          .collection('patients')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query')
          .get();

      return snapshot.docs.map((doc) {
        return PatientModel.fromMap({...doc.data(), 'id': doc.id});
      }).toList();
    } catch (e) {
      debugPrint('Error searching patients: $e');
      return [];
    }
  }
}
