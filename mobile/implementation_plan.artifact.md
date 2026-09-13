# Implementation Plan - Fix Errors and Lints

This plan addresses the errors, warnings, and infos reported in the Flutter project, ranging from missing dependencies to linter violations and test file issues.

## Proposed Changes

### 1. Dependency Management
- **[MODIFY] [pubspec.yaml](file:///D:/PROJECTS/Ganesh HCP/Ganesh HCP/Ganesh-Bandobast-HCP/mobile/pubspec.yaml)**
  - Uncomment `ar_flutter_plugin_plus: ^1.1.3`.

### 2. AR Measurement Screen Fixes
- **[MODIFY] [ar_measurement_screen.dart](file:///D:/PROJECTS/Ganesh HCP/Ganesh HCP/Ganesh-Bandobast-HCP/mobile/lib/screens/measurement/ar_measurement_screen.dart)**
  - (No code changes needed once dependency is restored, but will verify imports).

### 3. Test File Fixes
- **[MODIFY] [resource_directory_screen_test.dart](file:///D:/PROJECTS/Ganesh HCP/Ganesh HCP/Ganesh-Bandobast-HCP/mobile/test/screens/resource_directory_screen_test.dart)**
  - Add `import 'package:flutter/material.dart';`.
  - Convert relative imports to `package:` imports.
  - Remove assignment to `FeatureFlags.enableResourceSharing` (since it's `const`).
- **[MODIFY] [matching_engine_test.dart](file:///D:/PROJECTS/Ganesh HCP/Ganesh HCP/Ganesh-Bandobast-HCP/mobile/test/services/matching_engine_test.dart)**
  - Convert relative imports to `package:` imports.
  - Remove unused imports.

### 4. Linter & Deprecation Fixes
- **[MODIFY] [dashboard_screen.dart](file:///D:/PROJECTS/Ganesh HCP/Ganesh HCP/Ganesh-Bandobast-HCP/mobile/lib/screens/dashboard/dashboard_screen.dart)**
  - Remove unused imports.
  - Replace `__` with `_` in error callbacks.
- **[MODIFY] [live_dispatch_map_screen.dart](file:///D:/PROJECTS/Ganesh HCP/Ganesh HCP/Ganesh-Bandobast-HCP/mobile/lib/screens/resources/live_dispatch_map_screen.dart)**
  - Remove unused imports and variables (`_toPs`, `latRange`, `lngRange`, `paint`).
  - Fix string interpolation (remove unnecessary braces).
- **[MODIFY] [raise_resource_request_screen.dart](file:///D:/PROJECTS/Ganesh HCP/Ganesh HCP/Ganesh-Bandobast-HCP/mobile/lib/screens/resources/raise_resource_request_screen.dart)**
  - Replace `value` with `initialValue` in FormFields.
  - Add `if (!mounted) return;` check before using `context` after async gaps.
  - Remove unused imports.
- **[MODIFY] [request_detail_screen.dart](file:///D:/PROJECTS/Ganesh HCP/Ganesh HCP/Ganesh-Bandobast-HCP/mobile/lib/screens/resources/request_detail_screen.dart)**
  - Rename `_InfoRow`, `_TimelineEvent`, `_ActionButton` to lowerCamelCase.
  - Replace `value` with `initialValue`.
- **[MODIFY] [resource_directory_screen.dart](file:///D:/PROJECTS/Ganesh HCP/Ganesh HCP/Ganesh-Bandobast-HCP/mobile/lib/screens/resources/resource_directory_screen.dart)**
  - Replace `withOpacity(0.2)` with `withValues(alpha: 0.2)`.
  - Remove unused imports.
- **[MODIFY] [resource_command_dashboard_screen.dart](file:///D:/PROJECTS/Ganesh HCP/Ganesh HCP/Ganesh-Bandobast-HCP/mobile/lib/screens/resources/resource_command_dashboard_screen.dart)**
  - Remove unused variables (`breachedCount`, `totalResources`, etc.).
  - Replace `__` with `_`.

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure all lints and errors are resolved.
- Run `flutter test` to ensure tests pass after fixing imports and constants.

### Manual Verification
- Verify that `ARView` and related classes are correctly recognized in `ar_measurement_screen.dart` after running `pub get`.
