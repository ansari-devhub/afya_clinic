# Afya Clinic 🏥

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28?logo=firebase)](https://firebase.google.com)
[![Tests](https://img.shields.io/badge/Tests-71%20Passed-2EA44F?logo=checkmarx)](test/)
[![Analysis](https://img.shields.io/badge/Analysis-Clean%20(0%20Issues)-2EA44F)](analysis_options.yaml)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**Afya Clinic** is a role-based clinical operating system and mobile application tailored for modern healthcare facilities in Kenya and East Africa. Built with **Flutter** and **Firebase**, it combines a soft neomorphic medical UI with reactive clinical workflows for doctors, patients, and administrative staff.

---

## 📑 Table of Contents
- [Key Features](#-key-features)
  - [Doctor Workflow](#-doctor-workflow)
  - [Patient Experience](#-patient-experience)
  - [Admin Management](#-admin-management)
  - [Authentication & Security](#-authentication--security)
- [Design System & UI Architecture](#-design-system--ui-architecture)
- [Project Architecture](#-project-architecture)
- [Getting Started](#-getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Firebase Setup](#firebase-setup)
- [Running Tests & Quality Assurance](#-running-tests--quality-assurance)
- [Asset & Icon Generation](#-asset--icon-generation)
- [Tech Stack](#-tech-stack)

---

## ✨ Key Features

### 👨‍⚕️ Doctor Workflow
- **Doctor Dashboard**:
  - Load-in entrance animation sequence (cold-start only; respects reduced motion settings).
  - High-priority **Next Patient Card** with quick actions (*Start consult*, *View chart*).
  - Triage **Emergency Strip** and **Needs Attention** alert cards.
  - **Later Today** appointment timeline and **Recent Patients** history strip.
- **Doctor Schedule (Tab 2)**:
  - Single vertical timeline with real-time **Now Line** tracking the current minute.
  - Filter appointments by status: *All*, *In-Person*, *Telehealth*, and *Completed*.
  - Day and Week view toggles with an interactive week date strip and appointment load dots.
  - Interactive **Block Time Bottom Sheet** for lunch breaks, meetings, or on-call coverage.
  - Pull-to-refresh data reloading with optimistic caching.
- **Doctor Profile (Tab 4)**:
  - Full-bleed edge-to-edge header with subtle ECG waveform aesthetics and verified medical credentials.
  - Animated count-up counters for clinical statistics (*Years of experience*, *Patients treated*, *Consultations completed*).
  - Inline doctor profile editing with immediate state reflection.
  - **Accepting Appointments** toggle with active bookings confirmation safeguards.
  - Light/Dark mode switcher and role-generic settings rows.

### 🧑‍💼 Patient Experience
- Guided **Onboarding Carousel** featuring smooth progress bars, auto-advance, and tap-and-hold gestures.
- **Patient Dashboard** displaying vital summaries, scheduled appointments, and prescription details.
- Comprehensive health profile tracking personal medical history, allergies, and chronic conditions.

### 🛡️ Admin Management
- Hospital operations overview, facility analytics, and staff management metrics.

### 🔐 Authentication & Security
- **Dual Identifier Login**: Sign in with Email or Kenyan Mobile Number.
- **Kenyan Phone Normalization**: Automatically converts local phone formats (`07...`, `01...`, `7...`) into standard international E.164 (`+254XXXXXXXXX`).
- **Biometric Authentication**: Fingerprint and Face Unlock support via `local_auth`.
- **Neomorphic Sign-Up**: Complete onboarding with live password strength indicator (length, numbers, uppercase, special characters) and Terms of Service modal.
- **Privacy & Logging**: Zero PII console leaks; all sensitive authentication tokens and credentials are encrypted or redacted.

---

## 🎨 Design System & UI Architecture

Afya Clinic features a **Soft Neomorphic (Frosted)** clinical design language:
- **Surface Elevation**: Subtle dual shadows (ambient top-left highlight and bottom-right depth shadow) derived mathematically from the active surface color for automatic dark/light theme adaptation.
- **Theme Tokens**: Centralized in [`ClinicalTokens`](lib/core/theme/clinical_tokens.dart), with full dynamic theme switching via [`ThemeController`](lib/core/theme/theme_controller.dart).
- **Branding**: Custom vector **Plus Buddy** character logo with dynamic facial expressions and animated eye drops on splash launch.

---

## 📂 Project Architecture

Afya Clinic follows a modular, feature-first structure:

```
lib/
├── config/
│   ├── app_assets.dart                  # Asset paths and mock data resources
│   └── app_theme.dart                   # Light & dark ThemeData configurations
├── core/
│   ├── constants/                       # Motion curves and timing tokens
│   ├── navigation/                      # Coordinated custom page transitions
│   ├── theme/                           # ClinicalTokens and ThemeController
│   ├── utils/                           # Shared utilities (e.g. PhoneUtils)
│   └── widgets/                         # Reusable UI widgets & Neomorphic primitives
├── features/
│   ├── auth/                            # Login, SignUp, and password validators
│   ├── doctor_dashboard/                # Dashboard screens, cards, and animations
│   ├── doctor_profile/                  # Hero header, stats strip, and settings
│   ├── doctor_schedule/                 # Schedule timeline, week view, and time blocking
│   ├── onboarding/                      # 5-step animated carousel & progress bars
│   └── splash/                          # Animated Plus Buddy logo & routing
├── models/                              # Data models (UserModel, PatientModel, AppointmentModel)
├── providers/                           # State management providers (Auth, Patient, Appointment)
├── services/                            # Firebase & Firestore backend integrations
├── main.dart                            # Application entry point
└── firebase_options.dart                # FlutterFire generated configuration
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.16.0 or later recommended)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio / Xcode / VS Code
- Configured Firebase project

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/ansari-devhub/afya_clinic.git
   cd afya_clinic
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

### Firebase Setup

Afya Clinic integrates with Firebase for Authentication and Firestore. To connect your own project:

1. Install and activate FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Configure your platforms:
   ```bash
   flutterfire configure
   ```

3. Enable the following in the [Firebase Console](https://console.firebase.google.com/):
   - **Authentication**: Enable Email/Password provider.
   - **Cloud Firestore**: Create database and deploy standard clinical security rules.

---

## 🧪 Running Tests & Quality Assurance

Afya Clinic maintains test coverage across all orchestration flows and atomic components:

```bash
# Run all tests (71 unit and widget tests)
flutter test

# Run static analysis (0 warnings / 0 lints)
flutter analyze
```

### Key Test Suites:
- `test/doctor_dashboard_test.dart`: Validates top bar, emergency strip, next-patient cards, and entrance animations.
- `test/doctor_schedule_test.dart`: Validates day/week views, timeline filters, and time-block bottom sheets.
- `test/doctor_profile_test.dart`: Validates stats count-up, hero editing, and appointment toggles.
- `test/auth_test.dart`: Tests password strength indicators, Kenyan phone normalization, and login workflows.
- `test/onboarding_test.dart`: Tests gesture holding, auto-advance, and slide transitions.
- `test/splash_logo_test.dart`: Tests Plus Buddy custom path rendering, eye drop animations, and reduced motion settings.

---

## 🛠 Asset & Icon Generation

High-resolution adaptive app icons (Android, iOS, Web, Desktop) can be generated using the built-in script:

```bash
dart run tool/generate_launcher_icons.dart
dart run flutter_launcher_icons
```

---

## 📦 Tech Stack

- **Framework**: [Flutter](https://flutter.dev)
- **Language**: [Dart](https://dart.dev)
- **Backend & Cloud**: [Firebase Auth](https://pub.dev/packages/firebase_auth), [Cloud Firestore](https://pub.dev/packages/cloud_firestore)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Biometrics**: [local_auth](https://pub.dev/packages/local_auth)
- **Vector Graphics**: [flutter_svg](https://pub.dev/packages/flutter_svg)
- **Calendar & Time**: [intl](https://pub.dev/packages/intl), [table_calendar](https://pub.dev/packages/table_calendar)

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
