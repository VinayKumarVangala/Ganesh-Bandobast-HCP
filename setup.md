# Ganesh Bandobust - Resource Sharing Feature
## Setup & Installation Guide

---

## Prerequisites

### Required Software
| Tool | Version | Install Command |
|------|---------|-----------------|
| **Flutter SDK** | 3.13+ (stable) | `flutter doctor -v` to verify |
| **Dart SDK** | 3.13.1+ | Included with Flutter |
| **Android Studio** | Ladybug+ | For Android emulator & SDK |
| **Xcode** | 15+ | macOS only, for iOS simulator |
| **Git** | 2.40+ | `git --version` |
| **VS Code / Android Studio** | Latest | IDE with Flutter/Dart plugins |

### Verify Flutter Installation
```bash
flutter doctor -v
```
Should show:
- ✅ Flutter (Channel stable, 3.13.x)
- ✅ Dart (3.13.x)
- ✅ Android toolchain
- ✅ Xcode (macOS)
- ✅ Chrome (for web)
- ✅ Connected device/emulator

---

## Quick Start

### 1. Clone Repository
```bash
cd D:\PROJECTS\Ganesh HCP\Ganesh HCP\Ganesh-Bandobast-HCP
# or your preferred workspace
```

### 2. Navigate to Mobile App
```bash
cd mobile
```

### 3. Get Dependencies
```bash
flutter pub get
```
**Expected:** Resolves 40+ packages including go_router, riverpod, latlong2, drift, etc.

### 4. Run Code Generation (Optional - for freezed/json_serializable)
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 5. Run the App

#### Android
```bash
# List devices
flutter devices

# Run on connected device/emulator
flutter run -d <device_id>

# Or run on specific emulator
flutter emulators --launch <emulator_id>
flutter run
```

#### iOS (macOS only)
```bash
flutter run -d ios
```

#### Web
```bash
flutter run -d chrome
```

#### Windows
```bash
flutter run -d windows
```

---

## Demo Login

The app uses a **demo login** (preserved from original):

| Field | Value |
|-------|-------|
| **Username** | `field1` |
| **Password** | `field123` |

**After Login:** Lands on Dashboard with:
- Officer: "Field Officer Demo"
- Role: "FIELD OFFICER"
- Police Station: "Abids Police Station"
- Sector: "03"

---

## Accessing Resource Sharing Feature

### For SHO and Above Roles

Since demo login is FIELD_OFFICER, you need to simulate higher roles:

**Option 1: Modify Demo User (Quick Test)**
Edit `lib/data/static_users.dart` line 10:
```dart
// Change role from fieldOfficer to sho
role: UserRole.sho,  // or acp, dcp, controlRoom, admin
```
Then hot restart (`R` in terminal).

**Option 2: Use Test Credentials (After Real Auth)**
Once `FeatureFlags.enableRealAuth = true` and backend configured:
- Login with phone OTP
- Role assigned from backend user record

**Option 3: Direct Route Navigation (Dev)**
In any screen, use:
```dart
context.push('/resources');  // Resource Directory
context.push('/resources/request/new');  // Raise Request
context.push('/resources/my-requests');  // My Requests
context.push('/resources/command-dashboard');  // ACP+ only
```

### Feature Flag Check

All resource features are behind `FeatureFlags.enableResourceSharing = true` (already enabled).

To disable: Edit `lib/config/feature_flags.dart`:
```dart
static const bool enableResourceSharing = false;
```

---

## Manual Test Script

### Test 1: Resource Directory
1. Login → Dashboard
2. Open drawer (☰) → Tap **"Resources"**
3. Verify: List view with 25 resources
4. Tap **Tab "Map"** → See placeholder map
5. Tap **Filter (🔍)** → Select Category "Crane" → Apply
6. Verify: Only 4 cranes shown
7. Search "CRN" → Verify 4 results
8. Tap any resource → **Resource Detail** screen

### Test 2: Raise Request
1. From Directory → FAB **"Raise Request"**
2. Fill form:
   - Category: **Crane** 📋
   - Quantity: **1** 1️⃣
   - Priority: **Urgent** 🟠 (20 min SLA)
   - Required From: **+1 hour** 🕐
   - Required Until: **+4 hours** 🕓
   - Site Address: **"Hussain Sagar Lake"** 📍
   - GPS: **"Use Current GPS"** 📡
   - Application: **GH2026-0001** 🔗 (auto-fills Mandal)
   - Contact: Pre-filled
   - Reason: **"Immersion crane needed for 20ft idol"**
3. Tap **"Submit Request"**
4. Verify: Success snackbar → Navigates to **Request Matching**

### Test 3: Request Matching
1. See ranked cards:
   - **Rank 1**: Abids PS (0.5 km, 1 min ETA) - 25T Crane ✅
   - **Rank 2**: Banjarahills PS (4.2 km, 8 min ETA) - 40T Crane ✅
   - Others by distance...
2. Tap **"Send Lend Request"** on Rank 1
3. Confirm dialog → **"Send Request"**
4. Verify: Snackbar "Lend request sent to Abids Police Station!"
5. Navigates to **Request Detail**

### Test 4: Request Workflow (SHO Actions)
**Switch to SHO role** (see Option 1 above), then:

1. Open **My Station Requests** → **Incoming** tab
2. See request with status **"Open"**
3. Tap request → **Request Detail**
5. Tap **"Approve"** → Confirm
6. Verify: Status → **"Assigned"**
7. Timeline shows: Created → Approved → Assigned

### Test 5: Field Officer Actions
**Switch back to FIELD_OFFICER** (demo user):

1. Open **My Station Requests** → **Outgoing** tab
2. Tap request → **Request Detail**
3. Actions visible:
   - **"Mark En Route"** (status: Assigned)
4. Tap → Status → **"En Route"**
5. Tap **"Mark On Site"** → Status → **"On Site"**
6. Tap **"Mark Released"** → Status → **"Released"**
7. Tap **"Mark Returned"**
   - Dialog: Condition **Good**, Fuel **50L**, Damage **"None"**
   - Confirm → Status → **"Returned"**

### Test 6: Close Request (SHO)
**Switch to SHO role:**

1. **My Station Requests** → **Incoming**
2. Tap returned request → **Request Detail**
3. Tap **"Close Request"**
4. Remarks: **"Crane returned undamaged"**
5. Confirm → Status → **"Closed"** (terminal)

### Test 7: Command Dashboard (ACP+)
**Switch to ACP role:**

1. Drawer → **"Command Dashboard"**
2. Verify sections:
   - **KPI Cards**: Open, Assigned, En Route, On Site
   - **Demand vs Supply Heatmap**: Sector bars
   - **SLA Breaches**: List (empty initially)
   - **Top 5 Scarce Categories**: Ratio badges
   - **Per-PS Utilization**: Top 10 stations
   - **Escalation Queue**: Empty initially

### Test 8: Live Dispatch Map
1. From any **Request Detail** (En Route/On Site status)
2. Tap **🗺️ Map icon** in AppBar
3. Verify:
   - Source PS pin (blue)
   - Destination pin (red)
   - Resource pin (green) with progress bar
   - ETA, remaining distance
   - "Notify on Arrival" button

---

## Troubleshooting

### Common Issues

#### `flutter pub get` fails
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

#### Android build fails (Gradle)
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

#### iOS build fails (CocoaPods)
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

#### "Feature not available" messages
Check `lib/config/feature_flags.dart`:
```dart
static const bool enableResourceSharing = true;  // Must be true
static const bool useStaticData = true;  // Must be true for static mode
```

#### Map not loading (MapmyIndia)
- Current implementation uses **static placeholder**
- Real MapmyIndia requires API key in `android/app/src/main/AndroidManifest.xml` and `ios/Runner/Info.plist`
- Set `enableMapmyIndia = true` when ready

#### Riverpod "Provider not found"
Ensure `ProviderScope` wraps app in `main.dart`:
```dart
runApp(const ProviderScope(child: GaneshBandobustApp()));
```

#### go_router "Route not found"
- Check route path in `app_router.dart`
- Use `context.push('/exact/path')` not `Navigator.push()`

---

## Project Structure for Testing

```
mobile/
├── lib/
│   ├── main.dart                    # App entry + ProviderScope
│   ├── config/
│   │   ├── feature_flags.dart       # Toggle features here
│   │   └── app_router.dart          # All routes defined
│   ├── data/                        # Static data (32 PS, 25 resources, 20 users)
│   ├── models/                      # All data models + enums
│   ├── providers/                   # Riverpod providers
│   ├── repositories/                # Data access (static impl)
│   ├── services/                    # Matching, SLA, Escalation engines
│   └── screens/
│       ├── dashboard/               # Updated dashboard
│       ├── login/                   # Original login
│       └── resources/               # 8 new resource screens
├── test/
│   ├── services/                    # Unit tests
│   └── screens/                     # Widget tests
├── pubspec.yaml                     # Dependencies
└── analysis_options.yaml            # Lint rules
```

---

## CI/CD Pipeline

### GitHub Actions (`.github/workflows/build-android-apk.yml`)

Current workflow:
```yaml
- Checkout
- Setup Java 17
- Setup Flutter (stable)
- flutter pub get
- flutter analyze
- flutter test
- flutter build apk --debug
- Upload APK artifact
```

### Run Locally Before Push
```bash
flutter analyze          # Must pass with 0 warnings
flutter test             # All tests must pass
flutter build apk --debug # Build succeeds
```

### Adding New Dependencies
1. Add to `pubspec.yaml`
2. Run `flutter pub get`
3. Commit `pubspec.lock`
4. CI will cache dependencies

---

## Backend Integration (When Ready)

### Supabase Setup
1. Create project at [supabase.com](https://supabase.com)
2. Run SQL schema from [ResourceDocs.md](#backend-readiness)
3. Enable **Realtime** on tables
4. Configure **Auth** → Phone provider
5. Get: `SUPABASE_URL`, `SUPABASE_ANON_KEY`

### Update Feature Flags
```dart
// lib/config/feature_flags.dart
static const bool useStaticData = false;
static const bool enableRealtimeSync = true;
static const bool enablePushNotifications = true;
static const bool enableOfflineQueue = true;
static const bool enableAuditLog = true;
static const bool enableRealAuth = true;
```

### Add Supabase Config
Create `lib/config/supabase_config.dart`:
```dart
const String supabaseUrl = 'YOUR_URL';
const String supabaseAnonKey = 'YOUR_KEY';
```

### Initialize in main.dart
```dart
await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
```

### Implement Supabase Repository
Create `lib/repositories/supabase_resource_repository.dart` implementing `ResourceRepository`.

### Override Provider
```dart
// In main.dart or provider setup
ProviderScope(
  overrides: [
    resourceRepositoryProvider.overrideWithValue(SupabaseResourceRepository()),
  ],
  child: ...
)
```

---

## Development Workflow

### Hot Reload / Restart
- **Hot Reload** (`r`): UI changes, state preserved
- **Hot Restart** (`R`): Full restart, resets state
- **Full Restart** (`flutter run`): Code gen, native changes

### Adding New Resource Category
1. Add to `ResourceCategory` enum in `resource_enums.dart`
2. Add icon, displayName
3. Add static resources in `static_resources.dart`
4. Run `flutter test` to verify matching engine

### Adding New Police Station
1. Add to `hyderabadPoliceStations` list in `police_stations.dart`
2. Include: id, name, commissionerate, sector, lat/lng, contacts
3. Run `flutter test` to verify matching

### Modifying SLA Times
```dart
// In matching_engine.dart
static const Map<RequestPriority, int> slaMinutes = {
  RequestPriority.normal: 60,
  RequestPriority.urgent: 20,
  RequestPriority.emergency: 0,
};
```

---

## Performance Notes

### Current (Static Data)
- All data in-memory → <50ms queries
- No network latency
- Suitable for demo/testing

### Production (Supabase)
- Add indexes on `current_location` (GIST), `status`, `raising_ps_id`
- Use `select()` with specific columns
- Enable Realtime only on active request tables
- Cache police stations locally (rarely change)

### Memory
- 25 resources × ~2KB = ~50KB
- 32 police stations × ~1KB = ~32KB
- 20 users × ~1KB = ~20KB
- **Total static data: <150KB** - negligible

---

## Security Checklist (Pre-Production)

- [ ] Remove demo credentials from `AuthRepository`
- [ ] Enable `enableRealAuth = true`
- [ ] Configure Supabase RLS policies
- [ ] Store API keys in `--dart-define` or native config
- [ ] Enable `enableAuditLog = true`
- [ ] Implement device ID tracking
- [ ] Add certificate pinning for API calls
- [ ] Encrypt local Drift database (sqlcipher)
- [ ] Review all `url_launcher` tel: links
- [ ] Audit all `permission_handler` usages

---

## Support

### Logs
```bash
# View logs
flutter logs

# Verbose
flutter run -v
```

### Debugging
- **DevTools**: `flutter run --enable-vm-service` → `flutter devtools`
- **Print statements**: Use `debugPrint()` (stripped in release)
- **Riverpod**: Enable `ProviderScope(observers: [Logger()])`

### Common Commands
```bash
# Clean everything
flutter clean && flutter pub get

# Analyze
flutter analyze

# Test specific file
flutter test test/services/matching_engine_test.dart

# Build release APK
flutter build apk --release

# Build iOS (macOS)
flutter build ios --release
```

---

## Version Info

| Component | Version |
|-----------|---------|
| Flutter | 3.13+ |
| Dart | 3.13.1 |
| App | 1.0.0+1 |
| Package | ganesh_bandobust_mobile |

---

*Last Updated: September 2026*  
*For: Ganesh Bandobust - Inter-Police-Station Resource Sharing Feature*