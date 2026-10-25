import '../../../config/app_assets.dart';
import 'models/doctor_profile_data.dart';

/// Abstract contract for Doctor Profile repository.
abstract class DoctorProfileRepository {
  Future<DoctorProfileData> fetchProfileData();
  Future<void> updateProfileDetails(DoctorProfileDetails details);
  Future<void> updateAvailability(AvailabilitySettings availability);
  Future<void> updateSecurity(SecuritySettings security);
  Future<void> logout();
}

/// Mock implementation providing default dummy data matching the specification and wireframe.
class MockDoctorProfileRepository implements DoctorProfileRepository {
  final Duration latency;

  DoctorProfileData _currentData = const DoctorProfileData(
    details: DoctorProfileDetails(
      name: 'Dr. Name Surname',
      specialty: 'Cardiology',
      facility: 'Facility Name',
      isVerified: true,
      registrationNumber: 'MED-748932',
      // Dev placeholder: mock doctor portrait from Unsplash (National Cancer Institute)
      photoUrl: AppAssets.mockDoctor,
    ),
    stats: DoctorStats(
      experienceYears: 12,
      totalPatients: 1240,
      totalConsults: 3860,
    ),
    availability: AvailabilitySettings(
      acceptingAppointments: true,
      onCallToday: false,
      workingHours: 'Mon - Fri: 08:00 - 17:00',
      upcomingBookingsCount: 3,
    ),
    security: SecuritySettings(
      biometricUnlock: false,
      activeSessionsCount: 2,
    ),
    language: 'English',
    appVersion: '1.0.0',
  );

  MockDoctorProfileRepository({
    DoctorProfileData? initialData,
    this.latency = Duration.zero,
  }) {
    if (initialData != null) {
      _currentData = initialData;
    }
  }

  @override
  Future<DoctorProfileData> fetchProfileData() async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
    return _currentData;
  }

  @override
  Future<void> updateProfileDetails(DoctorProfileDetails details) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
    _currentData = _currentData.copyWith(details: details);
  }

  @override
  Future<void> updateAvailability(AvailabilitySettings availability) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
    _currentData = _currentData.copyWith(availability: availability);
  }

  @override
  Future<void> updateSecurity(SecuritySettings security) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
    _currentData = _currentData.copyWith(security: security);
  }

  @override
  Future<void> logout() async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
  }
}
