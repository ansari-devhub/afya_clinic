import 'dart:async';
import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../services/appointment_service.dart';

/// Provider that manages appointment data and operations
class AppointmentProvider extends ChangeNotifier {
  final AppointmentService appointmentService;
  List<AppointmentModel> _appointments = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<AppointmentModel>>? _subscription;

  AppointmentProvider({required this.appointmentService});

  List<AppointmentModel> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  /// Fetch appointments with optional filters
  Future<void> fetchAppointments({
    String? doctorId,
    String? patientId,
    DateTime? date,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _subscription?.cancel();
      _subscription = appointmentService
          .getAppointmentsStream(
        doctorId: doctorId,
        patientId: patientId,
        date: date,
      )
          .listen(
        (appointments) {
          _appointments = appointments;
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

  /// Add a new appointment
  Future<void> addAppointment(AppointmentModel appointment) async {
    try {
      await appointmentService.addAppointment(appointment);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Update an existing appointment
  Future<void> updateAppointment(AppointmentModel appointment) async {
    try {
      await appointmentService.updateAppointment(appointment);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Update appointment status
  Future<void> updateAppointmentStatus(String appointmentId, AppointmentStatus status) async {
    try {
      await appointmentService.updateAppointmentStatus(appointmentId, status);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Delete an appointment
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await appointmentService.deleteAppointment(appointmentId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
