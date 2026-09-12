import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../repositories/resource_repository.dart';
import '../models/resource_models.dart';
import '../models/resource_enums.dart';
import '../models/user_models.dart';
import '../data/police_stations.dart';
import '../config/feature_flags.dart';

// Repository Providers
final resourceRepositoryProvider = Provider<ResourceRepository>((ref) {
  return StaticResourceRepository();
});

final policeStationRepositoryProvider = Provider<PoliceStationRepository>((ref) {
  return PoliceStationRepository();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final resourceRequestRepositoryProvider = Provider<ResourceRequestRepository>((ref) {
  return ResourceRequestRepository();
});

// State Providers
final currentUserProvider = FutureProvider<User?>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.getCurrentUser();
});

final currentPoliceStationProvider = FutureProvider<PoliceStation?>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return null;
  final psRepo = ref.watch(policeStationRepositoryProvider);
  return psRepo.getPoliceStationById(user.policeStationId);
});

final currentLocationProvider = FutureProvider<LatLng?>((ref) async {
  final ps = await ref.watch(currentPoliceStationProvider.future);
  return ps?.location;
});

// Resource State
final allResourcesProvider = FutureProvider<List<ResourceItem>>((ref) async {
  if (!FeatureFlags.enableResourceSharing) return [];
  final repo = ref.watch(resourceRepositoryProvider);
  return repo.getAllResources();
});

final availableResourcesProvider = FutureProvider.family<List<ResourceItem>, AvailableResourcesParams>((ref, params) async {
  if (!FeatureFlags.enableResourceSharing) return [];
  final repo = ref.watch(resourceRepositoryProvider);
  return repo.getAvailableResources(
    category: params.category,
    policeStationId: params.policeStationId,
    maxDistanceKm: params.maxDistanceKm,
    fromLocation: params.fromLocation,
  );
});

final resourcesByCategoryProvider = FutureProvider.family<List<ResourceItem>, ResourceCategory>((ref, category) async {
  if (!FeatureFlags.enableResourceSharing) return [];
  final repo = ref.watch(resourceRepositoryProvider);
  return repo.getResourcesByCategory(category);
});

final resourcesByPoliceStationProvider = FutureProvider.family<List<ResourceItem>, String>((ref, policeStationId) async {
  if (!FeatureFlags.enableResourceSharing) return [];
  final repo = ref.watch(resourceRepositoryProvider);
  return repo.getResourcesByPoliceStation(policeStationId);
});

final resourceSearchProvider = FutureProvider.family<List<ResourceItem>, String>((ref, query) async {
  if (!FeatureFlags.enableResourceSharing) return [];
  final repo = ref.watch(resourceRepositoryProvider);
  return repo.searchResources(query);
});

final nearbyResourcesProvider = FutureProvider.family<List<ResourceItem>, NearbyResourcesParams>((ref, params) async {
  if (!FeatureFlags.enableResourceSharing) return [];
  final repo = ref.watch(resourceRepositoryProvider);
  return repo.getResourcesNearLocation(params.location, params.radiusKm, category: params.category);
});

final resourceByIdProvider = FutureProvider.family<ResourceItem?, String>((ref, id) async {
  if (!FeatureFlags.enableResourceSharing) return null;
  final repo = ref.watch(resourceRepositoryProvider);
  return repo.getResourceById(id);
});

// Police Station State
final allPoliceStationsProvider = FutureProvider<List<PoliceStation>>((ref) async {
  if (!FeatureFlags.enableResourceSharing) return [];
  final repo = ref.watch(policeStationRepositoryProvider);
  return repo.getAllPoliceStations();
});

final policeStationsByCommissionerateProvider = FutureProvider.family<List<PoliceStation>, Commissionerate>((ref, commissionerate) async {
  if (!FeatureFlags.enableResourceSharing) return [];
  final repo = ref.watch(policeStationRepositoryProvider);
  return repo.getPoliceStationsByCommissionerate(commissionerate);
});

final nearbyPoliceStationsProvider = FutureProvider.family<List<PoliceStation>, NearbyPoliceStationsParams>((ref, params) async {
  if (!FeatureFlags.enableResourceSharing) return [];
  final repo = ref.watch(policeStationRepositoryProvider);
  return repo.getNearbyPoliceStations(params.location, radiusKm: params.radiusKm);
});

// Request State
final activeRequestsProvider = FutureProvider<List<ResourceRequest>>((ref) async {
  if (!FeatureFlags.enableResourceSharing) return [];
  final repo = ref.watch(resourceRequestRepositoryProvider);
  return repo.getActiveRequests();
});

final outgoingRequestsProvider = FutureProvider.family<List<ResourceRequest>, String>((ref, policeStationId) async {
  if (!FeatureFlags.enableResourceSharing) return [];
  final repo = ref.watch(resourceRequestRepositoryProvider);
  return repo.getRequestsByPoliceStation(policeStationId, outgoing: true);
});

final incomingRequestsProvider = FutureProvider.family<List<ResourceRequest>, String>((ref, policeStationId) async {
  if (!FeatureFlags.enableResourceSharing) return [];
  final repo = ref.watch(resourceRequestRepositoryProvider);
  return repo.getIncomingRequestsForPoliceStation(policeStationId);
});

final requestByIdProvider = FutureProvider.family<ResourceRequest?, String>((ref, id) async {
  if (!FeatureFlags.enableResourceSharing) return null;
  final repo = ref.watch(resourceRequestRepositoryProvider);
  return repo.getRequestById(id);
});

// Filter State
final resourceFilterProvider = StateProvider<ResourceFilter>((ref) => const ResourceFilter());

class ResourceFilter {
  final ResourceCategory? category;
  final ResourceStatus? status;
  final ResourceCondition? condition;
  final Commissionerate? commissionerate;
  final double? maxDistanceKm;
  final String? searchQuery;

  const ResourceFilter({
    this.category,
    this.status,
    this.condition,
    this.commissionerate,
    this.maxDistanceKm,
    this.searchQuery,
  });

  ResourceFilter copyWith({
    ResourceCategory? category,
    ResourceStatus? status,
    ResourceCondition? condition,
    Commissionerate? commissionerate,
    double? maxDistanceKm,
    String? searchQuery,
  }) {
    return ResourceFilter(
      category: category ?? this.category,
      status: status ?? this.status,
      condition: condition ?? this.condition,
      commissionerate: commissionerate ?? this.commissionerate,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class AvailableResourcesParams {
  final ResourceCategory? category;
  final String? policeStationId;
  final double? maxDistanceKm;
  final LatLng? fromLocation;

  const AvailableResourcesParams({
    this.category,
    this.policeStationId,
    this.maxDistanceKm,
    this.fromLocation,
  });
}

class NearbyResourcesParams {
  final LatLng location;
  final double radiusKm;
  final ResourceCategory? category;

  const NearbyResourcesParams({
    required this.location,
    required this.radiusKm,
    this.category,
  });
}

class NearbyPoliceStationsParams {
  final LatLng location;
  final double radiusKm;

  const NearbyPoliceStationsParams({
    required this.location,
    required this.radiusKm,
  });
}