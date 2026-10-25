import 'dart:async';
import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import '../services/patient_service.dart';

/// Provider that manages patient data and operations
class PatientProvider extends ChangeNotifier {
  final PatientService patientService;
  List<PatientModel> _patients = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<PatientModel>>? _subscription;

  PatientProvider({required this.patientService});

  List<PatientModel> get patients => _patients;
  bool get isLoading => _isLoading;
  String? get error => _error;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  /// Fetch patients with optional status filter
  Future<void> fetchPatients({PatientStatus? statusFilter}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _subscription?.cancel();
      _subscription = patientService.getPatientsStream(statusFilter: statusFilter).listen(
        (patients) {
          _patients = patients;
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
          _error = e.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new patient
  Future<void> addPatient(PatientModel patient) async {
    try {
      await patientService.addPatient(patient);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Update an existing patient
  Future<void> updatePatient(PatientModel patient) async {
    try {
      await patientService.updatePatient(patient);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Update patient status
  Future<void> updatePatientStatus(String patientId, PatientStatus status) async {
    try {
      await patientService.updatePatientStatus(patientId, status);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Search patients by name
  Future<List<PatientModel>> searchPatients(String query) async {
    try {
      return await patientService.searchPatients(query);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }
}
