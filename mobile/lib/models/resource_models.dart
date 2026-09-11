import 'package:latlong2/latlong.dart';
import 'resource_enums.dart';

class ResourceItem {
  final String id;
  final String assetCode;
  final String name;
  final ResourceCategory category;
  final String owningPoliceStationId;
  final String currentHoldingPoliceStationId;
  final int quantityTotal;
  final int quantityAvailable;
  final int quantityDeployed;
  final ResourceStatus status;
  final ResourceCondition condition;
  final bool requiresOperator;
  final String? capacitySpec;
  final String? fuelType;
  final LatLng? currentLocation;
  final DateTime? lastKnownLocationAt;
  final String? custodianName;
  final String? custodianPhone;
  final double? chargeableRatePerHour;
  final DateTime? lastServicedAt;
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ResourceItem({
    required this.id,
    required this.assetCode,
    required this.name,
    required this.category,
    required this.owningPoliceStationId,
    required this.currentHoldingPoliceStationId,
    required this.quantityTotal,
    required this.quantityAvailable,
    required this.quantityDeployed,
    required this.status,
    required this.condition,
    required this.requiresOperator,
    this.capacitySpec,
    this.fuelType,
    this.currentLocation,
    this.lastKnownLocationAt,
    this.custodianName,
    this.custodianPhone,
    this.chargeableRatePerHour,
    this.lastServicedAt,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isAvailable => status == ResourceStatus.available && quantityAvailable > 0;

  bool get isDeployed => status == ResourceStatus.deployed || quantityDeployed > 0;

  String get displayName => '$name ($assetCode)';

  ResourceItem copyWith({
    String? id,
    String? assetCode,
    String? name,
    ResourceCategory? category,
    String? owningPoliceStationId,
    String? currentHoldingPoliceStationId,
    int? quantityTotal,
    int? quantityAvailable,
    int? quantityDeployed,
    ResourceStatus? status,
    ResourceCondition? condition,
    bool? requiresOperator,
    String? capacitySpec,
    String? fuelType,
    LatLng? currentLocation,
    DateTime? lastKnownLocationAt,
    String? custodianName,
    String? custodianPhone,
    double? chargeableRatePerHour,
    DateTime? lastServicedAt,
    String? remarks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ResourceItem(
      id: id ?? this.id,
      assetCode: assetCode ?? this.assetCode,
      name: name ?? this.name,
      category: category ?? this.category,
      owningPoliceStationId: owningPoliceStationId ?? this.owningPoliceStationId,
      currentHoldingPoliceStationId: currentHoldingPoliceStationId ?? this.currentHoldingPoliceStationId,
      quantityTotal: quantityTotal ?? this.quantityTotal,
      quantityAvailable: quantityAvailable ?? this.quantityAvailable,
      quantityDeployed: quantityDeployed ?? this.quantityDeployed,
      status: status ?? this.status,
      condition: condition ?? this.condition,
      requiresOperator: requiresOperator ?? this.requiresOperator,
      capacitySpec: capacitySpec ?? this.capacitySpec,
      fuelType: fuelType ?? this.fuelType,
      currentLocation: currentLocation ?? this.currentLocation,
      lastKnownLocationAt: lastKnownLocationAt ?? this.lastKnownLocationAt,
      custodianName: custodianName ?? this.custodianName,
      custodianPhone: custodianPhone ?? this.custodianPhone,
      chargeableRatePerHour: chargeableRatePerHour ?? this.chargeableRatePerHour,
      lastServicedAt: lastServicedAt ?? this.lastServicedAt,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ResourceRequest {
  final String id;
  final String requestNumber;
  final String raisedByUserId;
  final String raisingPoliceStationId;
  final String? applicationId;
  final String mandalName;
  final ResourceCategory resourceCategory;
  final int quantityRequested;
  final RequestPriority priority;
  final DateTime requiredAt;
  final DateTime requiredUntil;
  final LatLng siteLocation;
  final String siteAddress;
  final String contactName;
  final String contactPhone;
  final String reason;
  final RequestStatus status;
  final String? assignedResourceId;
  final String? assignedFromPoliceStationId;
  final String? approvedByUserId;
  final DateTime? approvedAt;
  final int escalationLevel;
  final DateTime? slaDueAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ResourceRequest({
    required this.id,
    required this.requestNumber,
    required this.raisedByUserId,
    required this.raisingPoliceStationId,
    this.applicationId,
    required this.mandalName,
    required this.resourceCategory,
    required this.quantityRequested,
    required this.priority,
    required this.requiredAt,
    required this.requiredUntil,
    required this.siteLocation,
    required this.siteAddress,
    required this.contactName,
    required this.contactPhone,
    required this.reason,
    required this.status,
    this.assignedResourceId,
    this.assignedFromPoliceStationId,
    this.approvedByUserId,
    this.approvedAt,
    this.escalationLevel = 0,
    this.slaDueAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive => status.isActive;

  bool get isEmergency => priority == RequestPriority.emergency;

  Duration? get timeUntilSla {
    if (slaDueAt == null) return null;
    final now = DateTime.now();
    if (now.isAfter(slaDueAt!)) return Duration.zero;
    return slaDueAt!.difference(now);
  }

  bool get isSlaBreached {
    if (slaDueAt == null) return false;
    return DateTime.now().isAfter(slaDueAt!);
  }

  ResourceRequest copyWith({
    String? id,
    String? requestNumber,
    String? raisedByUserId,
    String? raisingPoliceStationId,
    String? applicationId,
    String? mandalName,
    ResourceCategory? resourceCategory,
    int? quantityRequested,
    RequestPriority? priority,
    DateTime? requiredAt,
    DateTime? requiredUntil,
    LatLng? siteLocation,
    String? siteAddress,
    String? contactName,
    String? contactPhone,
    String? reason,
    RequestStatus? status,
    String? assignedResourceId,
    String? assignedFromPoliceStationId,
    String? approvedByUserId,
    DateTime? approvedAt,
    int? escalationLevel,
    DateTime? slaDueAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ResourceRequest(
      id: id ?? this.id,
      requestNumber: requestNumber ?? this.requestNumber,
      raisedByUserId: raisedByUserId ?? this.raisedByUserId,
      raisingPoliceStationId: raisingPoliceStationId ?? this.raisingPoliceStationId,
      applicationId: applicationId ?? this.applicationId,
      mandalName: mandalName ?? this.mandalName,
      resourceCategory: resourceCategory ?? this.resourceCategory,
      quantityRequested: quantityRequested ?? this.quantityRequested,
      priority: priority ?? this.priority,
      requiredAt: requiredAt ?? this.requiredAt,
      requiredUntil: requiredUntil ?? this.requiredUntil,
      siteLocation: siteLocation ?? this.siteLocation,
      siteAddress: siteAddress ?? this.siteAddress,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      assignedResourceId: assignedResourceId ?? this.assignedResourceId,
      assignedFromPoliceStationId: assignedFromPoliceStationId ?? this.assignedFromPoliceStationId,
      approvedByUserId: approvedByUserId ?? this.approvedByUserId,
      approvedAt: approvedAt ?? this.approvedAt,
      escalationLevel: escalationLevel ?? this.escalationLevel,
      slaDueAt: slaDueAt ?? this.slaDueAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ResourceTransfer {
  final String id;
  final String resourceId;
  final String fromPoliceStationId;
  final String toPoliceStationId;
  final String requestId;
  final DateTime? dispatchedAt;
  final DateTime? arrivedAt;
  final DateTime? returnedAt;
  final ResourceCondition conditionOnDispatch;
  final ResourceCondition? conditionOnReturn;
  final double? fuelOut;
  final double? fuelIn;
  final String? damageNotes;
  final String? operatorAssignedUserId;
  final TransferStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ResourceTransfer({
    required this.id,
    required this.resourceId,
    required this.fromPoliceStationId,
    required this.toPoliceStationId,
    required this.requestId,
    this.dispatchedAt,
    this.arrivedAt,
    this.returnedAt,
    required this.conditionOnDispatch,
    this.conditionOnReturn,
    this.fuelOut,
    this.fuelIn,
    this.damageNotes,
    this.operatorAssignedUserId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive => status != TransferStatus.completed && status != TransferStatus.returned;

  ResourceTransfer copyWith({
    String? id,
    String? resourceId,
    String? fromPoliceStationId,
    String? toPoliceStationId,
    String? requestId,
    DateTime? dispatchedAt,
    DateTime? arrivedAt,
    DateTime? returnedAt,
    ResourceCondition? conditionOnDispatch,
    ResourceCondition? conditionOnReturn,
    double? fuelOut,
    double? fuelIn,
    String? damageNotes,
    String? operatorAssignedUserId,
    TransferStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ResourceTransfer(
      id: id ?? this.id,
      resourceId: resourceId ?? this.resourceId,
      fromPoliceStationId: fromPoliceStationId ?? this.fromPoliceStationId,
      toPoliceStationId: toPoliceStationId ?? this.toPoliceStationId,
      requestId: requestId ?? this.requestId,
      dispatchedAt: dispatchedAt ?? this.dispatchedAt,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      returnedAt: returnedAt ?? this.returnedAt,
      conditionOnDispatch: conditionOnDispatch ?? this.conditionOnDispatch,
      conditionOnReturn: conditionOnReturn ?? this.conditionOnReturn,
      fuelOut: fuelOut ?? this.fuelOut,
      fuelIn: fuelIn ?? this.fuelIn,
      damageNotes: damageNotes ?? this.damageNotes,
      operatorAssignedUserId: operatorAssignedUserId ?? this.operatorAssignedUserId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ResourceStatusEvent {
  final String id;
  final String? requestId;
  final String? resourceId;
  final RequestStatus? fromStatus;
  final RequestStatus toStatus;
  final String actorUserId;
  final String? remarks;
  final LatLng? location;
  final DateTime occurredAt;

  const ResourceStatusEvent({
    required this.id,
    this.requestId,
    this.resourceId,
    this.fromStatus,
    required this.toStatus,
    required this.actorUserId,
    this.remarks,
    this.location,
    required this.occurredAt,
  });
}