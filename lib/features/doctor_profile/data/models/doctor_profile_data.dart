/// Data models for the Doctor Profile screen.
class DoctorProfileDetails {
  final String name;
  final String specialty;
  final String facility;
  final String? photoUrl;
  final bool isVerified;
  final String registrationNumber;

  const DoctorProfileDetails({
    required this.name,
    required this.specialty,
    required this.facility,
    this.photoUrl,
    this.isVerified = true,
    required this.registrationNumber,
  });

  /// Never show the full registration number; masked to last 2-3 characters.
  String get maskedRegistrationNumber {
    if (registrationNumber.isEmpty) return 'Reg. No. ******';
    final lastChars = registrationNumber.length >= 3
        ? registrationNumber.substring(registrationNumber.length - 3)
        : registrationNumber;
    return 'Reg. No. ***$lastChars';
  }

  String get specialtyAndFacility => '$specialty · $facility';

  DoctorProfileDetails copyWith({
    String? name,
    String? specialty,
    String? facility,
    String? photoUrl,
    bool? isVerified,
    String? registrationNumber,
  }) {
    return DoctorProfileDetails(
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      facility: facility ?? this.facility,
      photoUrl: photoUrl ?? this.photoUrl,
      isVerified: isVerified ?? this.isVerified,
      registrationNumber: registrationNumber ?? this.registrationNumber,
    );
  }
}

/// Stats strip model: Experience, Patients, Consults.
class DoctorStats {
  final int experienceYears;
  final int totalPatients;
  final int totalConsults;

  const DoctorStats({
    required this.experienceYears,
    required this.totalPatients,
    required this.totalConsults,
  });

  String get experienceFormatted => '$experienceYears yrs';

  /// Format integer with commas for thousands.
  static String formatThousands(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  String get patientsFormatted => formatThousands(totalPatients);
  String get consultsFormatted => formatThousands(totalConsults);
}

/// Availability settings.
class AvailabilitySettings {
  final bool acceptingAppointments;
  final bool onCallToday;
  final String workingHours;
  final int upcomingBookingsCount;

  const AvailabilitySettings({
    this.acceptingAppointments = true,
    this.onCallToday = false,
    this.workingHours = 'Mon - Fri: 08:00 - 17:00',
    this.upcomingBookingsCount = 3,
  });

  AvailabilitySettings copyWith({
    bool? acceptingAppointments,
    bool? onCallToday,
    String? workingHours,
    int? upcomingBookingsCount,
  }) {
    return AvailabilitySettings(
      acceptingAppointments: acceptingAppointments ?? this.acceptingAppointments,
      onCallToday: onCallToday ?? this.onCallToday,
      workingHours: workingHours ?? this.workingHours,
      upcomingBookingsCount: upcomingBookingsCount ?? this.upcomingBookingsCount,
    );
  }
}

/// Security settings.
class SecuritySettings {
  final bool biometricUnlock;
  final int activeSessionsCount;

  const SecuritySettings({
    this.biometricUnlock = false,
    this.activeSessionsCount = 2,
  });

  SecuritySettings copyWith({
    bool? biometricUnlock,
    int? activeSessionsCount,
  }) {
    return SecuritySettings(
      biometricUnlock: biometricUnlock ?? this.biometricUnlock,
      activeSessionsCount: activeSessionsCount ?? this.activeSessionsCount,
    );
  }
}

/// Aggregated Doctor Profile data.
class DoctorProfileData {
  final DoctorProfileDetails details;
  final DoctorStats stats;
  final AvailabilitySettings availability;
  final SecuritySettings security;
  final String language;
  final String appVersion;

  const DoctorProfileData({
    required this.details,
    required this.stats,
    required this.availability,
    required this.security,
    this.language = 'English',
    this.appVersion = '1.0.0',
  });

  DoctorProfileData copyWith({
    DoctorProfileDetails? details,
    DoctorStats? stats,
    AvailabilitySettings? availability,
    SecuritySettings? security,
    String? language,
    String? appVersion,
  }) {
    return DoctorProfileData(
      details: details ?? this.details,
      stats: stats ?? this.stats,
      availability: availability ?? this.availability,
      security: security ?? this.security,
      language: language ?? this.language,
      appVersion: appVersion ?? this.appVersion,
    );
  }
}
