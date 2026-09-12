import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/login/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/applications/my_idols_screen.dart';
import '../screens/applications/application_details_screen.dart';
import '../screens/pre_installation/pre_installation_screen.dart';
import '../screens/pre_installation/location_verification_screen.dart';
import '../screens/pre_installation/mandap_verification_screen.dart';
import '../screens/pre_installation/idol_verification_screen.dart';
import '../screens/measurement/ar_measurement_screen.dart';
import '../screens/resources/resource_directory_screen.dart';
import '../screens/resources/resource_detail_screen.dart';
import '../screens/resources/raise_resource_request_screen.dart';
import '../screens/resources/request_matching_screen.dart';
import '../screens/resources/my_station_requests_screen.dart';
import '../screens/resources/request_detail_screen.dart';
import '../screens/resources/live_dispatch_map_screen.dart';
import '../screens/resources/resource_command_dashboard_screen.dart';
import '../config/feature_flags.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>?;
        return DashboardScreen(
          officerName: extra?['officerName'] ?? 'Officer',
          role: extra?['role'] ?? 'FIELD OFFICER',
          policeStation: extra?['policeStation'] ?? 'PS',
          sector: extra?['sector'] ?? '01',
        );
      },
    ),
    GoRoute(
      path: '/my-idols',
      name: 'my-idols',
      builder: (context, state) => const MyIdolsScreen(),
    ),
    GoRoute(
      path: '/application/:id',
      name: 'application-details',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final extra = state.extra as Map<String, String>?;
        return ApplicationDetailsScreen(
          applicationId: id,
          organizer: extra?['organizer'] ?? '',
          location: extra?['location'] ?? '',
        );
      },
    ),
    GoRoute(
      path: '/pre-installation',
      name: 'pre-installation',
      builder: (context, state) => const PreInstallationScreen(),
    ),
    GoRoute(
      path: '/location-verification/:id',
      name: 'location-verification',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return LocationVerificationScreen(applicationId: id);
      },
    ),
    GoRoute(
      path: '/mandap-verification/:id',
      name: 'mandap-verification',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return MandapVerificationScreen(applicationId: id);
      },
    ),
    GoRoute(
      path: '/idol-verification/:id',
      name: 'idol-verification',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return IdolVerificationScreen(applicationId: id);
      },
    ),
    GoRoute(
      path: '/ar-measurement/:id',
      name: 'ar-measurement',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final extra = state.extra as Map<String, String>?;
        return ArMeasurementScreen(
          applicationId: id,
          measurementType: extra?['measurementType'] ?? 'distance',
        );
      },
    ),

    // Resource Sharing Routes (Phase C & D)
    if (FeatureFlags.enableResourceSharing) ...[
      GoRoute(
        path: '/resources',
        name: 'resource-directory',
        builder: (context, state) => const ResourceDirectoryScreen(),
      ),
      GoRoute(
        path: '/resources/:resourceId',
        name: 'resource-detail',
        builder: (context, state) {
          final resourceId = state.pathParameters['resourceId']!;
          return ResourceDetailScreen(resourceId: resourceId);
        },
      ),
      GoRoute(
        path: '/resources/request/new',
        name: 'raise-resource-request',
        builder: (context, state) => const RaiseResourceRequestScreen(),
      ),
      GoRoute(
        path: '/resources/request/:requestId/matching',
        name: 'request-matching',
        builder: (context, state) {
          final requestId = state.pathParameters['requestId']!;
          return RequestMatchingScreen(requestId: requestId);
        },
      ),
      GoRoute(
        path: '/resources/my-requests',
        name: 'my-station-requests',
        builder: (context, state) => const MyStationRequestsScreen(),
      ),
      GoRoute(
        path: '/resources/request/:requestId',
        name: 'request-detail',
        builder: (context, state) {
          final requestId = state.pathParameters['requestId']!;
          return RequestDetailScreen(requestId: requestId);
        },
      ),
      GoRoute(
        path: '/resources/request/:requestId/dispatch',
        name: 'live-dispatch',
        builder: (context, state) {
          final requestId = state.pathParameters['requestId']!;
          return LiveDispatchMapScreen(requestId: requestId);
        },
      ),
      GoRoute(
        path: '/resources/command-dashboard',
        name: 'resource-command-dashboard',
        builder: (context, state) => const ResourceCommandDashboardScreen(),
      ),
    ],
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Route not found: ${state.uri}'),
    ),
  ),
);