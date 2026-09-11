import 'package:latlong2/latlong.dart';
import 'resource_enums.dart';

class User {
  final String id;
  final String name;
  final UserRole role;
  final String policeStationId;
  final String commissionerate;
  final String sector;
  final String phone;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.role,
    required this.policeStationId,
    required this.commissionerate,
    required this.sector,
    required this.phone,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get canApproveRequests => role.canApproveRequests;

  bool get canEscalate => role.canEscalate;

  bool get canViewCommandDashboard => role.canViewCommandDashboard;

  User copyWith({
    String? id,
    String? name,
    UserRole? role,
    String? policeStationId,
    String? commissionerate,
    String? sector,
    String? phone,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      policeStationId: policeStationId ?? this.policeStationId,
      commissionerate: commissionerate ?? this.commissionerate,
      sector: sector ?? this.sector,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PoliceStationModel {
  final String id;
  final String name;
  final String commissionerate;
  final String sector;
  final LatLng location;
  final String contactNumber;
  final String dutyOfficerName;
  final String dutyOfficerPhone;
  final String? shoUserId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PoliceStationModel({
    required this.id,
    required this.name,
    required this.commissionerate,
    required this.sector,
    required this.location,
    required this.contactNumber,
    required this.dutyOfficerName,
    required this.dutyOfficerPhone,
    this.shoUserId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  double distanceTo(LatLng other) {
    return LatLng.distance(location, other);
  }

  String get displayName => '$name ($commissionerate, Sector $sector)';

  PoliceStationModel copyWith({
    String? id,
    String? name,
    String? commissionerate,
    String? sector,
    LatLng? location,
    String? contactNumber,
    String? dutyOfficerName,
    String? dutyOfficerPhone,
    String? shoUserId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PoliceStationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      commissionerate: commissionerate ?? this.commissionerate,
      sector: sector ?? this.sector,
      location: location ?? this.location,
      contactNumber: contactNumber ?? this.contactNumber,
      dutyOfficerName: dutyOfficerName ?? this.dutyOfficerName,
      dutyOfficerPhone: dutyOfficerPhone ?? this.dutyOfficerPhone,
      shoUserId: shoUserId ?? this.shoUserId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}