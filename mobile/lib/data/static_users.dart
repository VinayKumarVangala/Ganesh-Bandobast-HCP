import '../models/user_models.dart';
import '../models/resource_enums.dart';
import '../data/police_stations.dart';

final List<User> staticUsers = [
  // Hyderabad Commissionerate
  User(
    id: 'USER-HYD-001',
    name: 'Inspector R. Srinivas',
    role: UserRole.sho,
    policeStationId: 'HYD-PS-001',
    commissionerate: 'Hyderabad',
    sector: 'Central',
    phone: '94906-XXXXX',
    createdAt: DateTime.now().subtract(const Duration(days: 730)),
    updatedAt: DateTime.now(),
  ),
  User(
    id: 'USER-HYD-002',
    name: 'SI K. Venkatesh',
    role: UserRole.fieldOfficer,
    policeStationId: 'HYD-PS-002',
    commissionerate: 'Hyderabad',
    sector: 'Central',
    phone: '94906-XXXXX',
    createdAt: DateTime.now().subtract(const Duration(days: 500)),
    updatedAt: DateTime.now(),
  ),
  User(
    id: 'USER-HYD-003',
    name: 'Inspector P. Ramesh',
    role: UserRole.sho,
    policeStationId: 'HYD-PS-003',
    commissionerate: 'Hyderabad',
    sector: 'West',
    phone: '94906-XXXXX',
    createdAt: DateTime.now().subtract(const Duration(days: 800)),
    updatedAt: DateTime.now(),
  ),
  User(
    id: 'USER-HYD-004',
    name: 'SI S. Kumar',
    role: UserRole.fieldOfficer,
    policeStationId: 'HYD-PS-004',
    commissionerate: 'Hyderabad',
    sector: 'North',
    phone: '94906-XXXXX',
    createdAt: DateTime.now().subtract(const Duration(days: 400)),
    updatedAt: DateTime.now(),
  ),
  User(
    id: 'USER-HYD-005',
    name: 'Inspector M. Reddy',
    role: UserRole.sho,
    policeStationId: 'HYD-PS-005',
    commissionerate: 'Hyderabad',
    sector: 'South',
    phone: '94906-XXXXX',
    createdAt: DateTime.now().subtract(const Duration(days: 600)),
    updatedAt: DateTime.now(),
  ),
  User(
    id: 'USER-HYD-006',
    name: 'CI V. Rao',
    role: UserRole.circleInspector,
    policeStationId: 'HYD-PS-001',
    commissionerate: 'Hyderabad',
    sector: 'Central',
    phone: '94906-XXXXX',
    createdAt: DateTime.now().subtract(const Duration(days: 1000)),
    updatedAt: DateTime.now(),
  ),
  User(
    id: 'USER-HYD-007',
    name: 'ACP A. Singh',
    role: UserRole.acp,
    policeStationId: 'HYD-PS-001',
    commissionerate: 'Hyderabad',
    sector: 'Central',
    phone: '94906-XXXXX',
    createdAt: DateTime.now().subtract(const Duration(days: 1500)),
    updatedAt: DateTime.now(),
  ),

  // Cyberabad Commissionerate
  User(
    id: 'USER-CYB-001',
    name: 'Inspector A. Reddy',
    role: UserRole.sho,
    policeStationId: 'CYB-PS-001',
    commissionerate: 'Cyberabad',
    sector: 'Madhapur',
    phone: '94906-XXXXX',
    createdAt: DateTime.now().subtract(const Duration(days: 600)),
    updatedAt: DateTime.now(),
  ),
  User(
    id: 'USER-CYB-002',
    name: 'Inspector K. Sharma',
    role: UserRole.sho,
    policeStationId: 'CYB-PS-002',
    commissionerate: 'Cyberabad',
    sector: 'Madhapur',
    phone: '94906-XXXXX',
    createdAt: DateTime.now().subtract(const Duration(days: 550)),
    updatedAt: DateTime.now(),
  ),
  User(
    id: 'USER-CYB-003',
    name: 'Inspector V. Patel',
    role: UserRole.sho,
    policeStationId: 'CYB-PS-003',
    commissionerate: 'Cyberabad',
    sector: 'Kukatpally',
    phone: '94906-XXXXX',
    createdAt: DateTime.now().subtract(const Duration(days: 700)),
    updatedAt: DateTime.now(),
  ),
  User(
    id: 'USER-CYB-004',
    name: 'CI R. Singh',
    role: UserRole.circleInspector,
    policeStationId: 'CYB-PS-001',
    commissionerate: 'Cyberabad',
    sector: 'Madhapur',
    phone: '94906-XXXXX',
    createdAt: DateTime.now().subtract(const Duration(days: 1200)),
    updatedAt: DateTime.now(),
  ),
  User(
    id: 'USER-CYB-005',
    name: 'ACP S. Gupta',
    role: UserRole.acp,
    policeStationId: 'CYB-PS-001',
    commissionerate: 'Cyberabad',
    sector: 'Madhapur',
    phone: '94906-XXXXX',
    createdAt: DateTime.now().subtract(const Duration(days: 1800)),
    updatedAt: DateTime.now(),
  ),

  // Rachakonda Commissionerate
  User(
    id: 'USER-RCH-001',
    name: 'Inspector K. Reddy',
    role: UserRole.sho,
    policeStationId: 'RCH-PS-001',
    commissionerate: 'Rachakonda',
    sector: 'Boduppal',
    phone: '94906-XXXXX',
    createdAt: DateTime.now().subtract(const Duration(days: 500)),
    updatedAt: DateTime.now(),
  ),
  User(
    id: 'USER-RCH-002',
    name: 'Inspector R. Kumar',
    role: UserRole.sho,
    policeStationId: 'RCH-PS-002',
    commissionerate: 'Rachakonda',
    sector: 'Chaitanyapuri',
    phone: '94906-XXXXX',
    createdAt: DateTime.now().subtract(const Duration(days: 450)),
    updatedAt: DateTime.now(),
  ),
  User(
    id: 'USER-RCH-003',
    name: 'Inspector V. Sharma',
    role: UserRole.sho,
    policeStationId: 'RCH-PS-003',
    commissionerate: 'Rachakonda',
    sector: 'Hayathnagar',
    phone: '94906-XXXXX',
    createdAt: DateTime.now().subtract(const Duration(days: 650)),
    updatedAt: DateTime.now(),
  ),
  User(
    id: 'USER-RCH-004',
    name: 'CI P. Singh',
    role: UserRole.circleInspector,
    policeStationId: 'RCH-PS-001',
    commissionerate: 'Rachakonda',
    sector: 'Boduppal',
    phone: '94906-XXXXX',
    createdAt: DateTime.now().subtract(const Duration(days: 1100)),
    updatedAt: DateTime.now(),
  ),
  User(
    id: 'USER-RCH-005',
    name: 'ACP S. Patel',
    role: UserRole.acp,
    policeStationId: 'RCH-PS-001',
    commissionerate: 'Rachakonda',
    sector: 'Boduppal',
    phone: '94906-XXXXX',
    createdAt: DateTime.now().subtract(const Duration(days: 1600)),
    updatedAt: DateTime.now(),
  ),

  // Control Room / Admin
  User(
    id: 'USER-CTL-001',
    name: 'DCP M. Gupta',
    role: UserRole.dcp,
    policeStationId: 'HYD-PS-001',
    commissionerate: 'Hyderabad',
    sector: 'Central',
    phone: '94906-XXXXX',
    createdAt: DateTime.now().subtract(const Duration(days: 2000)),
    updatedAt: DateTime.now(),
  ),
  User(
    id: 'USER-CTL-002',
    name: 'Control Room Officer',
    role: UserRole.controlRoom,
    policeStationId: 'HYD-PS-001',
    commissionerate: 'Hyderabad',
    sector: 'Central',
    phone: '94906-XXXXX',
    createdAt: DateTime.now().subtract(const Duration(days: 300)),
    updatedAt: DateTime.now(),
  ),
  User(
    id: 'USER-ADM-001',
    name: 'System Administrator',
    role: UserRole.admin,
    policeStationId: 'HYD-PS-001',
    commissionerate: 'Hyderabad',
    sector: 'Central',
    phone: '94906-XXXXX',
    createdAt: DateTime.now().subtract(const Duration(days: 2500)),
    updatedAt: DateTime.now(),
  ),
];

User? getUserById(String id) {
  try {
    return staticUsers.firstWhere((u) => u.id == id);
  } catch (_) {
    return null;
  }
}

List<User> getUsersByPoliceStation(String policeStationId) {
  return staticUsers.where((u) => u.policeStationId == policeStationId).toList();
}

List<User> getUsersByRole(UserRole role) {
  return staticUsers.where((u) => u.role == role).toList();
}

List<User> getUsersByCommissionerate(String commissionerate) {
  return staticUsers.where((u) => u.commissionerate == commissionerate).toList();
}

User? getShoForPoliceStation(String policeStationId) {
  try {
    return staticUsers.firstWhere((u) => u.policeStationId == policeStationId && u.role == UserRole.sho);
  } catch (_) {
    return null;
  }
}

User? getCircleInspectorForCommissionerate(String commissionerate) {
  try {
    return staticUsers.firstWhere((u) => u.commissionerate == commissionerate && u.role == UserRole.circleInspector);
  } catch (_) {
    return null;
  }
}

User? getAcpForCommissionerate(String commissionerate) {
  try {
    return staticUsers.firstWhere((u) => u.commissionerate == commissionerate && u.role == UserRole.acp);
  } catch (_) {
    return null;
  }
}