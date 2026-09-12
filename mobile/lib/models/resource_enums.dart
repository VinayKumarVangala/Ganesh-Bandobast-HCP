import 'package:flutter/material.dart';

enum ResourceCategory {
  crane('CRANE', 'Crane', Icons.construction),
  gasCutter('GAS_CUTTER', 'Gas Cutter', Icons.water_drop),
  cutter('CUTTER', 'Cutter', Icons.content_cut),
  jcb('JCB', 'JCB', Icons.construction),
  waterTanker('WATER_TANKER', 'Water Tanker', Icons.water_drop),
  fireTender('FIRE_TENDER', 'Fire Tender', Icons.local_fire_department),
  ambulance('AMBULANCE', 'Ambulance', Icons.local_hospital),
  diver('DIVER', 'Diver', Icons.pool),
  boat('BOAT', 'Boat', Icons.directions_boat),
  barricade('BARRICADE', 'Barricade', Icons.barrier),
  floodlight('FLOODLIGHT', 'Floodlight', Icons.highlight),
  generator('GENERATOR', 'Generator', Icons.electrical_services),
  towTruck('TOW_TRUCK', 'Tow Truck', Icons.local_shipping),
  operator('OPERATOR', 'Certified Operator', Icons.person),
  other('OTHER', 'Other', Icons.category);

  final String code;
  final String displayName;
  final IconData icon;

  const ResourceCategory(this.code, this.displayName, this.icon);

  static ResourceCategory fromCode(String code) {
    return ResourceCategory.values.firstWhere(
      (e) => e.code == code,
      orElse: () => ResourceCategory.other,
    );
  }
}

enum ResourceStatus {
  available('AVAILABLE', 'Available', Colors.green),
  deployed('DEPLOYED', 'Deployed', Colors.orange),
  enRoute('EN_ROUTE', 'En Route', Colors.blue),
  underMaintenance('UNDER_MAINTENANCE', 'Under Maintenance', Colors.grey),
  outOfService('OUT_OF_SERVICE', 'Out of Service', Colors.red);

  final String code;
  final String displayName;
  final Color color;

  const ResourceStatus(this.code, this.displayName, this.color);

  static ResourceStatus fromCode(String code) {
    return ResourceStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => ResourceStatus.outOfService,
    );
  }
}

enum ResourceCondition {
  good('GOOD', 'Good', Colors.green),
  fair('FAIR', 'Fair', Colors.orange),
  needsRepair('NEEDS_REPAIR', 'Needs Repair', Colors.red);

  final String code;
  final String displayName;
  final Color color;

  const ResourceCondition(this.code, this.displayName, this.color);

  static ResourceCondition fromCode(String code) {
    return ResourceCondition.values.firstWhere(
      (e) => e.code == code,
      orElse: () => ResourceCondition.needsRepair,
    );
  }
}

enum RequestPriority {
  normal('NORMAL', 'Normal', Colors.blue),
  urgent('URGENT', 'Urgent', Colors.orange),
  emergency('EMERGENCY', 'Emergency', Colors.red);

  final String code;
  final String displayName;
  final Color color;

  const RequestPriority(this.code, this.displayName, this.color);

  static RequestPriority fromCode(String code) {
    return RequestPriority.values.firstWhere(
      (e) => e.code == code,
      orElse: () => RequestPriority.normal,
    );
  }

  int get slaMinutes {
    switch (this) {
      case RequestPriority.normal:
        return 60;
      case RequestPriority.urgent:
        return 20;
      case RequestPriority.emergency:
        return 0;
    }
  }
}

enum RequestStatus {
  draft('DRAFT', 'Draft', Colors.grey),
  open('OPEN', 'Open', Colors.blue),
  matching('MATCHING', 'Matching', Colors.purple),
  assigned('ASSIGNED', 'Assigned', Colors.indigo),
  enRoute('EN_ROUTE', 'En Route', Colors.blue),
  onSite('ON_SITE', 'On Site', Colors.teal),
  inUse('IN_USE', 'In Use', Colors.orange),
  released('RELEASED', 'Released', Colors.lightGreen),
  returned('RETURNED', 'Returned', Colors.green),
  closed('CLOSED', 'Closed', Colors.green),
  rejected('REJECTED', 'Rejected', Colors.red),
  cancelled('CANCELLED', 'Cancelled', Colors.red),
  escalated('ESCALATED', 'Escalated', Colors.deepOrange);

  final String code;
  final String displayName;
  final Color color;

  const RequestStatus(this.code, this.displayName, this.color);

  static RequestStatus fromCode(String code) {
    return RequestStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => RequestStatus.draft,
    );
  }

  bool get isActive {
    return ![RequestStatus.closed, RequestStatus.rejected, RequestStatus.cancelled].contains(this);
  }

  bool get isTerminal {
    return [RequestStatus.closed, RequestStatus.rejected, RequestStatus.cancelled].contains(this);
  }
}

enum TransferStatus {
  pending('PENDING', 'Pending'),
  dispatched('DISPATCHED', 'Dispatched'),
  arrived('ARRIVED', 'Arrived'),
  returned('RETURNED', 'Returned'),
  completed('COMPLETED', 'Completed');

  final String code;
  final String displayName;

  const TransferStatus(this.code, this.displayName);

  static TransferStatus fromCode(String code) {
    return TransferStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => TransferStatus.pending,
    );
  }
}

enum UserRole {
  fieldOfficer('FIELD_OFFICER', 'Field Officer'),
  sho('SHO', 'SHO'),
  circleInspector('CIRCLE_INSPECTOR', 'Circle Inspector'),
  acp('ACP', 'ACP'),
  dcp('DCP', 'DCP'),
  controlRoom('CONTROL_ROOM', 'Control Room'),
  admin('ADMIN', 'Admin');

  final String code;
  final String displayName;

  const UserRole(this.code, this.displayName);

  static UserRole fromCode(String code) {
    return UserRole.values.firstWhere(
      (e) => e.code == code,
      orElse: () => UserRole.fieldOfficer,
    );
  }

  bool get canApproveRequests {
    return [UserRole.sho, UserRole.circleInspector, UserRole.acp, UserRole.dcp, UserRole.controlRoom, UserRole.admin].contains(this);
  }

  bool get canEscalate {
    return [UserRole.circleInspector, UserRole.acp, UserRole.dcp, UserRole.controlRoom, UserRole.admin].contains(this);
  }

  bool get canViewCommandDashboard {
    return [UserRole.acp, UserRole.dcp, UserRole.controlRoom, UserRole.admin].contains(this);
  }
}