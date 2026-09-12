import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_router.dart';
import 'config/feature_flags.dart';

void main() {
  runApp(const ProviderScope(child: GaneshBandobustApp()));
}

class GaneshBandobustApp extends StatelessWidget {
  const GaneshBandobustApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Ganesh Bandobust',
      routerConfig: appRouter,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF17365D),
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF17365D),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}

// Feature flag toggle widget for debugging
class FeatureFlagBanner extends ConsumerWidget {
  const FeatureFlagBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!FeatureFlags.enableResourceSharing) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      color: Colors.amber[100],
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 16, color: Colors.amber[800]),
          const SizedBox(width: 8),
          Text(
            'Resource Sharing Feature: ENABLED (Static Data Mode)',
            style: TextStyle(fontSize: 12, color: Colors.amber[800], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}