# Ganesh Bandobust - Project Overview

## Project Summary

**Ganesh Bandobust** is a comprehensive mobile application for managing the Ganesh Festival Bandobust (security/management) operations. It is a Flutter-based cross-platform mobile app designed for field officers to conduct pre-installation verifications, manage idol applications, and perform AR-based measurements during the festival.

---

## Technology Stack

| Component | Technology |
|-----------|------------|
| **Framework** | Flutter 3.13+ (Dart SDK ^3.13.1) |
| **Platforms** | Android, iOS, Web, Windows, macOS, Linux |
| **Architecture** | Clean separation with screens organized by feature |
| **State Management** | StatefulWidget / setState (local state) |
| **Navigation** | Navigator 1.0 (MaterialPageRoute) |

### Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `geolocator` | ^14.0.2 | GPS location capture and permissions |
| `ar_flutter_plugin_plus` | ^1.1.3 | AR measurement using device camera |
| `vector_math` | ^2.2.0 | 3D vector mathematics for AR |
| `path_provider` | ^2.1.5 | Local file storage for evidence images |
| `image` | ^4.5.4 | Image processing (burning metadata into evidence photos) |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |

---

## Project Structure

```
mobile/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── models/
│   │   └── ar_measurement_result.dart     # AR measurement data model
│   └── screens/
│       ├── login/
│       │   └── login_screen.dart          # Authentication screen
│       ├── dashboard/
│       │   └── dashboard_screen.dart      # Main dashboard with festival stages
│       ├── applications/
│       │   ├── my_idols_screen.dart       # List of assigned idol applications
│       │   └── application_details_screen.dart # Application details
│       ├── pre_installation/
│       │   ├── pre_installation_screen.dart      # Main pre-installation menu
│       │   ├── location_verification_screen.dart # Location-based verification
│       │   ├── mandap_verification_screen.dart   # Mandap structure verification
│       │   └── idol_verification_screen.dart     # Idol verification
│       └── measurement/
│           └── ar_measurement_screen.dart  # AR-based height/width/length measurement
├── android/                               # Android-specific config
├── ios/                                   # iOS-specific config
├── web/                                   # Web build config
├── windows/                               # Windows build config
├── macos/                                 # macOS build config
├── linux/                                 # Linux build config
├── pubspec.yaml                           # Dependencies & metadata
└── analysis_options.yaml                  # Linting rules
```

---

## Application Flow

### 1. Authentication (LoginScreen)
- **Demo Credentials**: `field1` / `field123`
- Role-based: Field Officer with police station and sector assignment
- Navigates to Dashboard on successful login

### 2. Dashboard (DashboardScreen)
- Displays officer info (name, role, police station, sector)
- **My Work**: Access to "My Idols / Applications" (12 assigned)
- **Festival Stages** (5 stages with status tracking):
  1. **Pre-Installation** - ACTIVE (current phase)
  2. Installation - Not Started
  3. During Festivity - Not Started
  4. Immersion - Not Started
  5. Post-Immersion - Not Started

### 3. My Idols / Applications (MyIdolsScreen)
- List view of assigned Ganesh idol applications
- Each entry shows: Application ID, Organizer, Location, Status
- Tap to view Application Details

### 4. Application Details (ApplicationDetailsScreen)
- Shows full application info
- Entry point to **Pre-Installation Verification**

### 5. Pre-Installation Verification (PreInstallationScreen)
8 verification modules for each application:
| # | Module | Status |
|---|--------|--------|
| 1 | Location-Based Verification | Ready ✓ |
| 2 | Mandap-Based Verification | Ready ✓ |
| 3 | Idol-Based Verification | Ready ✓ |
| 4 | Route-Based Verification | Pending |
| 5 | Security-Based Verification | Pending |
| 6 | Organizer-Based Verification | Pending |
| 7 | Inter-Departmental Coordination / NOCs | Pending |
| 8 | Permission / SHO Review | Pending |

**Implemented Modules (1-3)**:
- **Location Verification**: GPS capture, location change tracking, sector assignment, commissionerate/PS reassignment, sensitivity assessment (Normal/Sensitive/Hyper Sensitive/Critical)
- **Mandap Verification**: Structure verification workflow
- **Idol Verification**: Idol-specific verification workflow

### 6. AR Measurement (ArMeasurementScreen)
Real-time 3D measurement using ARCore/ARKit:
- **Measurement Types**: Height, Width, Length
- **Process**: Tap start point → Tap end point → Auto GPS capture → Capture evidence image → Confirm
- **Evidence**: Screenshot with burned-in metadata (measurement, GPS, timestamp, application ID, method)
- **Storage**: Saved to app documents directory as JPEG

---

## Key Features

### Location-Based Verification
- GPS capture with high accuracy
- Permission handling (denied/forever denied)
- Location change workflow (same PS vs different PS)
- Sector selection (01-05)
- Commissionerate selection (Hyderabad, Cyberabad, Rachakonda)
- Police Station reassignment
- Sensitivity classification with mandatory remarks for NO responses

### AR Measurement System
- Plane detection (horizontal + vertical)
- 3D hit-testing for precise point placement
- True 3D Euclidean distance calculation
- Automatic GPS capture after measurement
- Evidence image with metadata overlay
- Reset/Retake capability
- Validation: requires measurement + GPS + evidence before confirmation

### Data Model (ArMeasurementResult)
```dart
ArMeasurementResult {
  double valueFeet;
  double valueMeters;
  double startX, startY, startZ;
  double endX, endY, endZ;
  double? latitude, longitude, gpsAccuracy;
  DateTime measuredAt;
  String measurementType;     // HEIGHT, WIDTH, LENGTH
  String measurementMethod;   // AR_3D_HIT_TEST
  String evidenceImagePath;
}
```

---

## CI/CD Pipeline

**GitHub Actions** (`.github/workflows/build-android-apk.yml`):
- Triggered manually (`workflow_dispatch`)
- Runs on Ubuntu latest
- Java 17 (Temurin)
- Flutter stable channel
- Steps: Checkout → Setup Java → Setup Flutter → Get deps → Analyze → Test → Build debug APK → Upload artifact

---

## Build & Run

```bash
cd mobile
flutter pub get
flutter run                    # Run on connected device/emulator
flutter build apk --debug      # Build debug APK
flutter build apk --release    # Build release APK
flutter build ios              # Build for iOS (requires macOS)
flutter build web              # Build for web
```

---

## Configuration

- **Theme**: Material 3 with custom color scheme (seed: `#17365D` - dark navy)
- **Scaffold Background**: `#F1F5F9` (light slate)
- **App Bar**: Dark navy with white text
- **Package Name**: `ganesh_bandobust_mobile`
- **Version**: 1.0.0+1
- **Min SDK**: Flutter 3.13.1+

---

## Screenshots / UI Highlights

- **Login**: Police-themed header with official branding
- **Dashboard**: Card-based layout with festival stage progress tracker
- **Verification Forms**: Card-based progressive disclosure (YES/NO branching)
- **AR View**: Full-screen camera with center reticle, bottom control panel
- **Evidence Preview**: Inline image preview with confirmation badge

---

## Future Development (Pending Modules)

1. Route-Based Verification
2. Security-Based Verification
3. Organizer-Based Verification
4. Inter-Departmental Coordination / NOCs
5. Permission / SHO Review
6. Installation, During Festivity, Immersion, Post-Immersion stages

---

## License

Private package (`publish_to: 'none'`) - Internal use for Ganesh Festival Bandobust Management.