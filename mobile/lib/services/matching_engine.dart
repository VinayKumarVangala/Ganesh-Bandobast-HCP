import 'package:latlong2/latlong.dart';
import '../models/resource_models.dart';
import '../models/resource_enums.dart';
import '../data/police_stations.dart';
import '../data/static_resources.dart';
import '../config/feature_flags.dart';
import '../../utils/distance.dart';

class MatchResult {
  final PoliceStation policeStation;
  final ResourceItem resource;
  final double distanceKm;
  final int estimatedDurationMinutes;
  final double matchScore;

  const MatchResult({
    required this.policeStation,
    required this.resource,
    required this.distanceKm,
    required this.estimatedDurationMinutes,
    required this.matchScore,
  });
}

class MatchingEngine {
  static const double defaultSearchRadiusKm = 15.0;
  static const double kmPerMinute = 0.5; // ~30 km/h average in city traffic

  static List<MatchResult> findMatches({
    required LatLng requestLocation,
    required ResourceCategory resourceCategory,
    required int quantityRequested,
    required RequestPriority priority,
    double searchRadiusKm = defaultSearchRadiusKm,
    String? excludePoliceStationId,
  }) {
    if (!FeatureFlags.enableResourceSharing) return [];

    final candidateResources = getAvailableResources(
      category: resourceCategory,
      maxDistanceKm: searchRadiusKm,
      fromLocation: requestLocation,
    ).where((r) {
      if (excludePoliceStationId != null && r.currentHoldingPoliceStationId == excludePoliceStationId) {
        return false;
      }
      return r.quantityAvailable >= quantityRequested;
    }).toList();

    final matches = <MatchResult>[];

    for (final resource in candidateResources) {
      final policeStation = getPoliceStationById(resource.currentHoldingPoliceStationId);
      if (policeStation == null) continue;

      final distanceKm = calculateDistance(
        requestLocation.latitude,
        requestLocation.longitude,
        (resource.currentLocation ?? policeStation.location).latitude,
        (resource.currentLocation ?? policeStation.location).longitude,
      );
      final estimatedDurationMinutes = (distanceKm / kmPerMinute).ceil();

      // Calculate match score (lower is better)
      // Priority: distance (asc), condition (desc), priority handling
      double conditionScore = 0;
      switch (resource.condition) {
        case ResourceCondition.good:
          conditionScore = 0;
          break;
        case ResourceCondition.fair:
          conditionScore = 10;
          break;
        case ResourceCondition.needsRepair:
          conditionScore = 50;
          break;
      }

      double priorityBoost = 0;
      switch (priority) {
        case RequestPriority.emergency:
          priorityBoost = -100; // Emergency gets top priority
          break;
        case RequestPriority.urgent:
          priorityBoost = -50;
          break;
        case RequestPriority.normal:
          priorityBoost = 0;
          break;
      }

      final matchScore = distanceKm * 10 + conditionScore + priorityBoost;

      matches.add(MatchResult(
        policeStation: policeStation,
        resource: resource,
        distanceKm: distanceKm,
        estimatedDurationMinutes: estimatedDurationMinutes,
        matchScore: matchScore,
      ));
    }

    // Sort by match score (ascending - lower is better)
    matches.sort((a, b) => a.matchScore.compareTo(b.matchScore));

    return matches;
  }

  static List<MatchResult> rankByDistance(List<MatchResult> matches) {
    final sorted = List<MatchResult>.from(matches);
    sorted.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return sorted;
  }

  static List<MatchResult> rankByETA(List<MatchResult> matches) {
    final sorted = List<MatchResult>.from(matches);
    sorted.sort((a, b) => a.estimatedDurationMinutes.compareTo(b.estimatedDurationMinutes));
    return sorted;
  }

  static List<MatchResult> rankByCondition(List<MatchResult> matches) {
    final sorted = List<MatchResult>.from(matches);
    sorted.sort((a, b) {
      final condA = a.resource.condition.index;
      final condB = b.resource.condition.index;
      return condA.compareTo(condB); // good (0) < fair (1) < needsRepair (2)
    });
    return sorted;
  }

  static List<MatchResult> rankByAvailability(List<MatchResult> matches, int quantityNeeded) {
    final sorted = List<MatchResult>.from(matches);
    sorted.sort((a, b) {
      // Prefer stations with more available quantity
      final availA = a.resource.quantityAvailable;
      final availB = b.resource.quantityAvailable;
      return availB.compareTo(availA); // Descending
    });
    return sorted;
  }

  static MatchResult? getBestMatch(List<MatchResult> matches) {
    if (matches.isEmpty) return null;
    return matches.first;
  }

  static bool hasMatchWithinRadius(List<MatchResult> matches, double radiusKm) {
    return matches.any((m) => m.distanceKm <= radiusKm);
  }
}

class SlaEvaluator {
  static const Map<RequestPriority, int> slaMinutes = {
    RequestPriority.normal: 60,
    RequestPriority.urgent: 20,
    RequestPriority.emergency: 0,
  };

  static DateTime calculateSlaDueAt(DateTime requestedAt, RequestPriority priority) {
    final minutes = slaMinutes[priority] ?? 60;
    return requestedAt.add(Duration(minutes: minutes));
  }

  static bool isSlaBreached(DateTime slaDueAt) {
    return DateTime.now().isAfter(slaDueAt);
  }

  static Duration? timeUntilSla(DateTime slaDueAt) {
    final now = DateTime.now();
    if (now.isAfter(slaDueAt)) return Duration.zero;
    return slaDueAt.difference(now);
  }

  static SlaStatus evaluateSlaStatus(DateTime slaDueAt) {
    final now = DateTime.now();
    if (now.isAfter(slaDueAt)) {
      return SlaStatus.breached;
    }

    final remaining = slaDueAt.difference(now);
    if (remaining.inMinutes <= 10) {
      return SlaStatus.critical;
    } else if (remaining.inMinutes <= 30) {
      return SlaStatus.warning;
    }

    return SlaStatus.onTrack;
  }
}

enum SlaStatus {
  onTrack,
  warning,
  critical,
  breached,
}

class EscalationEngine {
  static const List<UserRole> escalationChain = [
    UserRole.fieldOfficer,
    UserRole.sho,
    UserRole.circleInspector,
    UserRole.acp,
    UserRole.dcp,
    UserRole.controlRoom,
  ];

  static UserRole? getNextEscalationLevel(UserRole currentLevel) {
    final currentIndex = escalationChain.indexOf(currentLevel);
    if (currentIndex >= 0 && currentIndex < escalationChain.length - 1) {
      return escalationChain[currentIndex + 1];
    }
    return null;
  }

  static bool shouldEscalate({
    required DateTime slaDueAt,
    required RequestStatus currentStatus,
    required int currentEscalationLevel,
  }) {
    if (currentStatus.isTerminal) return false;
    if (SlaEvaluator.isSlaBreached(slaDueAt)) return true;
    return false;
  }

  static List<UserRole> getEscalationRecipients(UserRole currentLevel, RequestPriority priority) {
    final recipients = <UserRole>[];
    final nextLevel = getNextEscalationLevel(currentLevel);

    if (nextLevel != null) {
      recipients.add(nextLevel);
    }

    // Emergency notifies current level + next level simultaneously
    if (priority == RequestPriority.emergency && currentLevel != UserRole.fieldOfficer) {
      recipients.add(currentLevel);
    }

    return recipients.toSet().toList();
  }
}