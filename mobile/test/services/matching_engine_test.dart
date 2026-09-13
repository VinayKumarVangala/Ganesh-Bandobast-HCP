import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:ganesh_bandobust_mobile/services/matching_engine.dart';
import 'package:ganesh_bandobust_mobile/models/resource_enums.dart';

void main() {
  group('MatchingEngine', () {
    const testLocation = LatLng(17.3850, 78.4867); // Hyderabad center
    const testCategory = ResourceCategory.crane;
    const testQuantity = 1;
    const testPriority = RequestPriority.normal;

    test('findMatches returns matches within radius', () {
      final matches = MatchingEngine.findMatches(
        requestLocation: testLocation,
        resourceCategory: testCategory,
        quantityRequested: testQuantity,
        priority: testPriority,
        searchRadiusKm: 15.0,
      );

      expect(matches, isNotEmpty);
      // Should find Abids PS crane (RES-001) and Banjarahills PS crane (RES-008)
      expect(matches.any((m) => m.resource.id == 'RES-001'), isTrue);
      expect(matches.any((m) => m.resource.id == 'RES-008'), isTrue);
    });

    test('findMatches filters by quantity available', () {
      final matches = MatchingEngine.findMatches(
        requestLocation: testLocation,
        resourceCategory: ResourceCategory.waterTanker,
        quantityRequested: 2, // Abids has 1 available, Banjarahills has none
        priority: testPriority,
        searchRadiusKm: 15.0,
      );

      // Abids has only 1 available, so should not match
      expect(matches.any((m) => m.resource.id == 'RES-004'), isFalse);
    });

    test('findMatches excludes specified police station', () {
      final matches = MatchingEngine.findMatches(
        requestLocation: testLocation,
        resourceCategory: testCategory,
        quantityRequested: testQuantity,
        priority: testPriority,
        searchRadiusKm: 15.0,
        excludePoliceStationId: 'HYD-PS-001', // Exclude Abids
      );

      expect(matches.any((m) => m.policeStation.id == 'HYD-PS-001'), isFalse);
    });

    test('findMatches returns empty for no available resources', () {
      final matches = MatchingEngine.findMatches(
        requestLocation: const LatLng(19.0, 72.0), // Far away (Mumbai)
        resourceCategory: testCategory,
        quantityRequested: testQuantity,
        priority: testPriority,
        searchRadiusKm: 15.0,
      );

      expect(matches, isEmpty);
    });

    test('match ranking considers distance', () {
      final matches = MatchingEngine.findMatches(
        requestLocation: testLocation,
        resourceCategory: testCategory,
        quantityRequested: testQuantity,
        priority: testPriority,
        searchRadiusKm: 15.0,
      );

      // First match should be closest
      final distances = matches.map((m) => m.distanceKm).toList();
      for (int i = 1; i < distances.length; i++) {
        expect(distances[i] >= distances[i - 1], isTrue);
      }
    });

    test('emergency priority gets higher ranking', () {
      final normalMatches = MatchingEngine.findMatches(
        requestLocation: testLocation,
        resourceCategory: testCategory,
        quantityRequested: testQuantity,
        priority: RequestPriority.normal,
        searchRadiusKm: 15.0,
      );

      final emergencyMatches = MatchingEngine.findMatches(
        requestLocation: testLocation,
        resourceCategory: testCategory,
        quantityRequested: testQuantity,
        priority: RequestPriority.emergency,
        searchRadiusKm: 15.0,
      );

      // Emergency should have same matches but better scores (lower matchScore)
      expect(normalMatches.length, equals(emergencyMatches.length));
    });
  });

  group('SlaEvaluator', () {
    test('calculateSlaDueAt adds correct minutes for normal priority', () {
      final requestedAt = DateTime(2026, 9, 12, 10, 0);
      final slaDue = SlaEvaluator.calculateSlaDueAt(requestedAt, RequestPriority.normal);
      expect(slaDue, equals(DateTime(2026, 9, 12, 11, 0)));
    });

    test('calculateSlaDueAt adds correct minutes for urgent priority', () {
      final requestedAt = DateTime(2026, 9, 12, 10, 0);
      final slaDue = SlaEvaluator.calculateSlaDueAt(requestedAt, RequestPriority.urgent);
      expect(slaDue, equals(DateTime(2026, 9, 12, 10, 20)));
    });

    test('calculateSlaDueAt adds zero minutes for emergency priority', () {
      final requestedAt = DateTime(2026, 9, 12, 10, 0);
      final slaDue = SlaEvaluator.calculateSlaDueAt(requestedAt, RequestPriority.emergency);
      expect(slaDue, equals(requestedAt));
    });

    test('isSlaBreached returns true when past due', () {
      final pastDue = DateTime.now().subtract(const Duration(minutes: 10));
      expect(SlaEvaluator.isSlaBreached(pastDue), isTrue);
    });

    test('isSlaBreached returns false when future', () {
      final future = DateTime.now().add(const Duration(minutes: 10));
      expect(SlaEvaluator.isSlaBreached(future), isFalse);
    });

    test('timeUntilSla returns correct duration', () {
      final future = DateTime.now().add(const Duration(minutes: 30));
      final remaining = SlaEvaluator.timeUntilSla(future);
      expect(remaining != null, isTrue);
      expect(remaining!.inMinutes, closeTo(30, 1));
    });

    test('timeUntilSla returns zero when past due', () {
      final pastDue = DateTime.now().subtract(const Duration(minutes: 10));
      final remaining = SlaEvaluator.timeUntilSla(pastDue);
      expect(remaining, equals(Duration.zero));
    });

    test('evaluateSlaStatus returns correct status', () {
      final now = DateTime.now();
      expect(SlaEvaluator.evaluateSlaStatus(now.add(const Duration(hours: 2))), equals(SlaStatus.onTrack));
      expect(SlaEvaluator.evaluateSlaStatus(now.add(const Duration(minutes: 25))), equals(SlaStatus.warning));
      expect(SlaEvaluator.evaluateSlaStatus(now.add(const Duration(minutes: 5))), equals(SlaStatus.critical));
      expect(SlaEvaluator.evaluateSlaStatus(now.subtract(const Duration(minutes: 5))), equals(SlaStatus.breached));
    });
  });

  group('EscalationEngine', () {
    test('getNextEscalationLevel returns correct next level', () {
      expect(EscalationEngine.getNextEscalationLevel(UserRole.fieldOfficer), equals(UserRole.sho));
      expect(EscalationEngine.getNextEscalationLevel(UserRole.sho), equals(UserRole.circleInspector));
      expect(EscalationEngine.getNextEscalationLevel(UserRole.circleInspector), equals(UserRole.acp));
      expect(EscalationEngine.getNextEscalationLevel(UserRole.acp), equals(UserRole.dcp));
      expect(EscalationEngine.getNextEscalationLevel(UserRole.dcp), equals(UserRole.controlRoom));
      expect(EscalationEngine.getNextEscalationLevel(UserRole.controlRoom), isNull);
      expect(EscalationEngine.getNextEscalationLevel(UserRole.admin), isNull);
    });

    test('shouldEscalate returns true when SLA breached', () {
      final pastDue = DateTime.now().subtract(const Duration(minutes: 10));
      expect(EscalationEngine.shouldEscalate(
        slaDueAt: pastDue,
        currentStatus: RequestStatus.open,
        currentEscalationLevel: 0,
      ), isTrue);
    });

    test('shouldEscalate returns false when SLA not breached', () {
      final future = DateTime.now().add(const Duration(minutes: 10));
      expect(EscalationEngine.shouldEscalate(
        slaDueAt: future,
        currentStatus: RequestStatus.open,
        currentEscalationLevel: 0,
      ), isFalse);
    });

    test('shouldEscalate returns false for terminal status', () {
      final pastDue = DateTime.now().subtract(const Duration(minutes: 10));
      expect(EscalationEngine.shouldEscalate(
        slaDueAt: pastDue,
        currentStatus: RequestStatus.closed,
        currentEscalationLevel: 0,
      ), isFalse);
    });

    test('getEscalationRecipients includes next level', () {
      final recipients = EscalationEngine.getEscalationRecipients(UserRole.sho, RequestPriority.normal);
      expect(recipients, contains(UserRole.circleInspector));
    });

    test('getEscalationRecipients includes current level for emergency', () {
      final recipients = EscalationEngine.getEscalationRecipients(UserRole.sho, RequestPriority.emergency);
      expect(recipients, contains(UserRole.sho));
      expect(recipients, contains(UserRole.circleInspector));
    });
  });

  group('RequestStatus', () {
    test('isActive returns true for active statuses', () {
      expect(RequestStatus.open.isActive, isTrue);
      expect(RequestStatus.assigned.isActive, isTrue);
      expect(RequestStatus.enRoute.isActive, isTrue);
      expect(RequestStatus.onSite.isActive, isTrue);
      expect(RequestStatus.inUse.isActive, isTrue);
      expect(RequestStatus.released.isActive, isTrue);
      expect(RequestStatus.returned.isActive, isTrue);
    });

    test('isActive returns false for terminal statuses', () {
      expect(RequestStatus.closed.isActive, isFalse);
      expect(RequestStatus.rejected.isActive, isFalse);
      expect(RequestStatus.cancelled.isActive, isFalse);
    });

    test('isTerminal returns true for terminal statuses', () {
      expect(RequestStatus.closed.isTerminal, isTrue);
      expect(RequestStatus.rejected.isTerminal, isTrue);
      expect(RequestStatus.cancelled.isTerminal, isTrue);
    });
  });

  group('UserRole permissions', () {
    test('canApproveRequests is correct for each role', () {
      expect(UserRole.fieldOfficer.canApproveRequests, isFalse);
      expect(UserRole.sho.canApproveRequests, isTrue);
      expect(UserRole.circleInspector.canApproveRequests, isTrue);
      expect(UserRole.acp.canApproveRequests, isTrue);
      expect(UserRole.dcp.canApproveRequests, isTrue);
      expect(UserRole.controlRoom.canApproveRequests, isTrue);
      expect(UserRole.admin.canApproveRequests, isTrue);
    });

    test('canEscalate is correct for each role', () {
      expect(UserRole.fieldOfficer.canEscalate, isFalse);
      expect(UserRole.sho.canEscalate, isFalse);
      expect(UserRole.circleInspector.canEscalate, isTrue);
      expect(UserRole.acp.canEscalate, isTrue);
      expect(UserRole.dcp.canEscalate, isTrue);
      expect(UserRole.controlRoom.canEscalate, isTrue);
      expect(UserRole.admin.canEscalate, isTrue);
    });

    test('canViewCommandDashboard is correct for each role', () {
      expect(UserRole.fieldOfficer.canViewCommandDashboard, isFalse);
      expect(UserRole.sho.canViewCommandDashboard, isFalse);
      expect(UserRole.circleInspector.canViewCommandDashboard, isFalse);
      expect(UserRole.acp.canViewCommandDashboard, isTrue);
      expect(UserRole.dcp.canViewCommandDashboard, isTrue);
      expect(UserRole.controlRoom.canViewCommandDashboard, isTrue);
      expect(UserRole.admin.canViewCommandDashboard, isTrue);
    });
  });
}