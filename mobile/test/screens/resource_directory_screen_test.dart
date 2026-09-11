import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:mockito/mockito.dart';
import '../../lib/screens/resources/resource_directory_screen.dart';
import '../../lib/providers/resource_providers.dart';
import '../../lib/repositories/resource_repository.dart';
import '../../lib/models/resource_models.dart';
import '../../lib/models/resource_enums.dart';
import '../../lib/config/feature_flags.dart';

class MockResourceRepository extends Mock implements ResourceRepository {}

void main() {
  group('ResourceDirectoryScreen', () {
    late MockResourceRepository mockRepo;

    setUp(() {
      mockRepo = MockResourceRepository();
      // Enable feature flag for tests
      FeatureFlags.enableResourceSharing = true;
    });

    tearDown(() {
      FeatureFlags.enableResourceSharing = false;
    });

    Widget createTestWidget(Widget child) {
      return ProviderScope(
        overrides: [
          resourceRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp(
          home: child,
        ),
      );
    }

    testWidgets('shows loading indicator when data is loading', (WidgetTester tester) async {
      when(mockRepo.getAllResources()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return <ResourceItem>[];
      });

      await tester.pumpWidget(createTestWidget(const ResourceDirectoryScreen()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when no resources', (WidgetTester tester) async {
      when(mockRepo.getAllResources()).thenAnswer((_) async => <ResourceItem>[]);

      await tester.pumpWidget(createTestWidget(const ResourceDirectoryScreen()));
      await tester.pumpAndSettle();

      expect(find.text('No resources found matching criteria'), findsOneWidget);
    });

    testWidgets('shows resource list when data available', (WidgetTester tester) async {
      final resources = [
        ResourceItem(
          id: 'RES-001',
          assetCode: 'CRN-HYD-001',
          name: 'Test Crane',
          category: ResourceCategory.crane,
          owningPoliceStationId: 'HYD-PS-001',
          currentHoldingPoliceStationId: 'HYD-PS-001',
          quantityTotal: 2,
          quantityAvailable: 2,
          quantityDeployed: 0,
          status: ResourceStatus.available,
          condition: ResourceCondition.good,
          requiresOperator: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockRepo.getAllResources()).thenAnswer((_) async => resources);

      await tester.pumpWidget(createTestWidget(const ResourceDirectoryScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Test Crane'), findsOneWidget);
      expect(find.text('CRN-HYD-001'), findsOneWidget);
    });

    testWidgets('search filters results', (WidgetTester tester) async {
      final resources = [
        ResourceItem(
          id: 'RES-001',
          assetCode: 'CRN-HYD-001',
          name: 'Test Crane',
          category: ResourceCategory.crane,
          owningPoliceStationId: 'HYD-PS-001',
          currentHoldingPoliceStationId: 'HYD-PS-001',
          quantityTotal: 2,
          quantityAvailable: 2,
          quantityDeployed: 0,
          status: ResourceStatus.available,
          condition: ResourceCondition.good,
          requiresOperator: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ResourceItem(
          id: 'RES-002',
          assetCode: 'GAS-HYD-001',
          name: 'Gas Cutter',
          category: ResourceCategory.gasCutter,
          owningPoliceStationId: 'HYD-PS-001',
          currentHoldingPoliceStationId: 'HYD-PS-001',
          quantityTotal: 3,
          quantityAvailable: 3,
          quantityDeployed: 0,
          status: ResourceStatus.available,
          condition: ResourceCondition.good,
          requiresOperator: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockRepo.getAllResources()).thenAnswer((_) async => resources);
      when(mockRepo.searchResources('crane')).thenAnswer((_) async => [resources.first]);

      await tester.pumpWidget(createTestWidget(const ResourceDirectoryScreen()));
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'crane');
      await tester.pumpAndSettle();

      expect(find.text('Test Crane'), findsOneWidget);
      expect(find.text('Gas Cutter'), findsNothing);
    });
  });
}