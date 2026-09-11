import 'package:latlong2/latlong.dart';
import '../models/resource_models.dart';
import '../models/resource_enums.dart';
import '../models/user_models.dart';
import '../data/static_resources.dart';
import '../data/police_stations.dart';
import '../config/feature_flags.dart';

abstract class ResourceRepository {
  Future<List<ResourceItem>> getAllResources();
  Future<List<ResourceItem>> getResourcesByCategory(ResourceCategory category);
  Future<List<ResourceItem>> getResourcesByPoliceStation(String policeStationId);
  Future<List<ResourceItem>> getAvailableResources({
    ResourceCategory? category,
    String? policeStationId,
    double? maxDistanceKm,
    LatLng? fromLocation,
  });
  Future<ResourceItem?> getResourceById(String id);
  Future<List<ResourceItem>> searchResources(String query);
  Future<List<ResourceItem>> getResourcesNearLocation(LatLng location, double radiusKm, {ResourceCategory? category});
  Future<ResourceItem> createResource(ResourceItem resource);
  Future<ResourceItem> updateResource(ResourceItem resource);
  Future<void> deleteResource(String id);
}

class StaticResourceRepository implements ResourceRepository {
  @override
  Future<List<ResourceItem>> getAllResources() async {
    if (!FeatureFlags.enableResourceSharing) return [];
    await Future.delayed(const Duration(milliseconds: 100));
    return getAllResources();
  }

  @override
  Future<List<ResourceItem>> getResourcesByCategory(ResourceCategory category) async {
    if (!FeatureFlags.enableResourceSharing) return [];
    await Future.delayed(const Duration(milliseconds: 50));
    return getResourcesByCategory(category);
  }

  @override
  Future<List<ResourceItem>> getResourcesByPoliceStation(String policeStationId) async {
    if (!FeatureFlags.enableResourceSharing) return [];
    await Future.delayed(const Duration(milliseconds: 50));
    return getResourcesByPoliceStation(policeStationId);
  }

  @override
  Future<List<ResourceItem>> getAvailableResources({
    ResourceCategory? category,
    String? policeStationId,
    double? maxDistanceKm,
    LatLng? fromLocation,
  }) async {
    if (!FeatureFlags.enableResourceSharing) return [];
    await Future.delayed(const Duration(milliseconds: 100));
    return getAvailableResources(
      category: category,
      policeStationId: policeStationId,
      maxDistanceKm: maxDistanceKm,
      fromLocation: fromLocation,
    );
  }

  @override
  Future<ResourceItem?> getResourceById(String id) async {
    if (!FeatureFlags.enableResourceSharing) return null;
    await Future.delayed(const Duration(milliseconds: 50));
    return getResourceById(id);
  }

  @override
  Future<List<ResourceItem>> searchResources(String query) async {
    if (!FeatureFlags.enableResourceSharing) return [];
    await Future.delayed(const Duration(milliseconds: 100));
    final lowerQuery = query.toLowerCase();
    return staticResources.where((r) =>
      r.name.toLowerCase().contains(lowerQuery) ||
      r.assetCode.toLowerCase().contains(lowerQuery) ||
      r.category.displayName.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  @override
  Future<List<ResourceItem>> getResourcesNearLocation(LatLng location, double radiusKm, {ResourceCategory? category}) async {
    if (!FeatureFlags.enableResourceSharing) return [];
    await Future.delayed(const Duration(milliseconds: 100));
    return getResourcesNearLocation(location, radiusKm, category: category);
  }

  @override
  Future<ResourceItem> createResource(ResourceItem resource) async {
    throw UnimplementedError('Static repository does not support create');
  }

  @override
  Future<ResourceItem> updateResource(ResourceItem resource) async {
    throw UnimplementedError('Static repository does not support update');
  }

  @override
  Future<void> deleteResource(String id) async {
    throw UnimplementedError('Static repository does not support delete');
  }
}

class PoliceStationRepository {
  Future<List<PoliceStation>> getAllPoliceStations() async {
    if (!FeatureFlags.enableResourceSharing) return [];
    await Future.delayed(const Duration(milliseconds: 50));
    return getAllPoliceStations();
  }

  Future<List<PoliceStation>> getPoliceStationsByCommissionerate(Commissionerate commissionerate) async {
    if (!FeatureFlags.enableResourceSharing) return [];
    await Future.delayed(const Duration(milliseconds: 50));
    return getPoliceStationsByCommissionerate(commissionerate);
  }

  Future<PoliceStation?> getPoliceStationById(String id) async {
    if (!FeatureFlags.enableResourceSharing) return null;
    await Future.delayed(const Duration(milliseconds: 50));
    return getPoliceStationById(id);
  }

  Future<List<PoliceStation>> getPoliceStationsWithinRadius(LatLng center, double radiusKm) async {
    if (!FeatureFlags.enableResourceSharing) return [];
    await Future.delayed(const Duration(milliseconds: 100));
    return getPoliceStationsWithinRadius(center, radiusKm);
  }

  Future<List<PoliceStation>> getNearbyPoliceStations(LatLng location, {double radiusKm = 15}) async {
    if (!FeatureFlags.enableResourceSharing) return [];
    await Future.delayed(const Duration(milliseconds: 100));
    return getPoliceStationsWithinRadius(location, radiusKm);
  }
}

class AuthRepository {
  static const String _demoUsername = 'field1';
  static const String _demoPassword = 'field123';

  Future<User?> login(String username, String password) async {
    if (!FeatureFlags.enableRealAuth) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (username == _demoUsername && password == _demoPassword) {
        return User(
          id: 'USER-DEMO-001',
          name: 'Field Officer Demo',
          role: UserRole.fieldOfficer,
          policeStationId: 'HYD-PS-001',
          commissionerate: 'Hyderabad',
          sector: '03',
          phone: '94906-XXXXX',
          createdAt: DateTime.now().subtract(const Duration(days: 365)),
          updatedAt: DateTime.now(),
        );
      }
      return null;
    }

    // Real auth implementation would go here
    throw UnimplementedError('Real auth not implemented yet');
  }

  Future<User?> getCurrentUser() async {
    if (!FeatureFlags.enableRealAuth) {
      return User(
        id: 'USER-DEMO-001',
        name: 'Field Officer Demo',
        role: UserRole.fieldOfficer,
        policeStationId: 'HYD-PS-001',
        commissionerate: 'Hyderabad',
        sector: '03',
        phone: '94906-XXXXX',
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now(),
      );
    }
    return null;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

class ResourceRequestRepository {
  final List<ResourceRequest> _requests = [];
  final List<ResourceTransfer> _transfers = [];
  final List<ResourceStatusEvent> _events = [];

  Future<List<ResourceRequest>> getRequestsByPoliceStation(String policeStationId, {bool outgoing = true}) async {
    if (!FeatureFlags.enableResourceSharing) return [];
    await Future.delayed(const Duration(milliseconds: 100));
    return _requests.where((r) => outgoing
        ? r.raisingPoliceStationId == policeStationId
        : r.assignedFromPoliceStationId == policeStationId).toList();
  }

  Future<List<ResourceRequest>> getActiveRequests() async {
    if (!FeatureFlags.enableResourceSharing) return [];
    await Future.delayed(const Duration(milliseconds: 100));
    return _requests.where((r) => r.isActive).toList();
  }

  Future<List<ResourceRequest>> getAllRequests() async {
    if (!FeatureFlags.enableResourceSharing) return [];
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_requests);
  }

  Future<ResourceRequest?> getRequestById(String id) async {
    if (!FeatureFlags.enableResourceSharing) return null;
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _requests.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<ResourceRequest> createRequest(ResourceRequest request) async {
    if (!FeatureFlags.enableResourceSharing) {
      throw Exception('Resource sharing feature is disabled');
    }
    await Future.delayed(const Duration(milliseconds: 200));
    _requests.add(request);
    _addEvent(ResourceStatusEvent(
      id: 'EVT-${DateTime.now().millisecondsSinceEpoch}',
      requestId: request.id,
      fromStatus: null,
      toStatus: request.status,
      actorUserId: request.raisedByUserId,
      remarks: 'Request created',
      occurredAt: DateTime.now(),
    ));
    return request;
  }

  Future<ResourceRequest> updateRequest(ResourceRequest request) async {
    if (!FeatureFlags.enableResourceSharing) {
      throw Exception('Resource sharing feature is disabled');
    }
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _requests.indexWhere((r) => r.id == request.id);
    if (index >= 0) {
      _requests[index] = request;
    }
    return request;
  }

  Future<ResourceTransfer> createTransfer(ResourceTransfer transfer) async {
    if (!FeatureFlags.enableResourceSharing) {
      throw Exception('Resource sharing feature is disabled');
    }
    await Future.delayed(const Duration(milliseconds: 200));
    _transfers.add(transfer);
    return transfer;
  }

  Future<ResourceTransfer> updateTransfer(ResourceTransfer transfer) async {
    if (!FeatureFlags.enableResourceSharing) {
      throw Exception('Resource sharing feature is disabled');
    }
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _transfers.indexWhere((t) => t.id == transfer.id);
    if (index >= 0) {
      _transfers[index] = transfer;
    }
    return transfer;
  }

  Future<List<ResourceTransfer>> getTransfersByRequest(String requestId) async {
    if (!FeatureFlags.enableResourceSharing) return [];
    await Future.delayed(const Duration(milliseconds: 100));
    return _transfers.where((t) => t.requestId == requestId).toList();
  }

  Future<List<ResourceStatusEvent>> getEventsByRequest(String requestId) async {
    if (!FeatureFlags.enableResourceSharing) return [];
    await Future.delayed(const Duration(milliseconds: 100));
    return _events.where((e) => e.requestId == requestId).toList();
  }

  void _addEvent(ResourceStatusEvent event) {
    _events.add(event);
  }

  Future<List<ResourceRequest>> getIncomingRequestsForPoliceStation(String policeStationId) async {
    if (!FeatureFlags.enableResourceSharing) return [];
    await Future.delayed(const Duration(milliseconds: 100));
    return _requests.where((r) => r.assignedFromPoliceStationId == policeStationId).toList();
  }
}