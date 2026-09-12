import 'package:latlong2/latlong.dart';
import '../../utils/distance.dart';

enum Commissionerate {
  hyderabad('Hyderabad'),
  cyberabad('Cyberabad'),
  rachakonda('Rachakonda');

  final String displayName;
  const Commissionerate(this.displayName);
}

class PoliceStation {
  final String id;
  final String name;
  final Commissionerate commissionerate;
  final String sector;
  final LatLng location;
  final String contactNumber;
  final String dutyOfficerName;
  final String dutyOfficerPhone;
  final bool isActive;

  const PoliceStation({
    required this.id,
    required this.name,
    required this.commissionerate,
    required this.sector,
    required this.location,
    required this.contactNumber,
    required this.dutyOfficerName,
    required this.dutyOfficerPhone,
    this.isActive = true,
  });

  double distanceTo(LatLng other) {
    return calculateDistance(location.latitude, location.longitude, other.latitude, other.longitude);
  }

  String get displayName => '$name (${commissionerate.displayName}, Sector $sector)';
}

const List<PoliceStation> hyderabadPoliceStations = [
  // Hyderabad Commissionerate
  PoliceStation(
    id: 'HYD-PS-001',
    name: 'Abids Police Station',
    commissionerate: Commissionerate.hyderabad,
    sector: 'Central',
    location: LatLng(17.3916, 78.4747),
    contactNumber: '040-2320-1234',
    dutyOfficerName: 'Inspector R. Srinivas',
    dutyOfficerPhone: '94906-XXXXX',
  ),
  PoliceStation(
    id: 'HYD-PS-002',
    name: 'Afzalgunj Police Station',
    commissionerate: Commissionerate.hyderabad,
    sector: 'Central',
    location: LatLng(17.3800, 78.4800),
    contactNumber: '040-2320-1235',
    dutyOfficerName: 'Inspector K. Venkatesh',
    dutyOfficerPhone: '94906-XXXXX',
  ),
  PoliceStation(
    id: 'HYD-PS-003',
    name: 'Banjarahills Police Station',
    commissionerate: Commissionerate.hyderabad,
    sector: 'West',
    location: LatLng(17.4178, 78.4419),
    contactNumber: '040-2320-1236',
    dutyOfficerName: 'Inspector P. Ramesh',
    dutyOfficerPhone: '94906-XXXXX',
  ),
  PoliceStation(
    id: 'HYD-PS-004',
    name: 'Begumpet Police Station',
    commissionerate: Commissionerate.hyderabad,
    sector: 'North',
    location: LatLng(17.4455, 78.4655),
    contactNumber: '040-2320-1237',
    dutyOfficerName: 'Inspector S. Kumar',
    dutyOfficerPhone: '94906-XXXXX',
  ),
  PoliceStation(
    id: 'HYD-PS-005',
    name: 'Charminar Police Station',
    commissionerate: Commissionerate.hyderabad,
    sector: 'South',
    location: LatLng(17.3616, 78.4747),
    contactNumber: '040-2320-1238',
    dutyOfficerName: 'Inspector M. Reddy',
    dutyOfficerPhone: '94906-XXXXX',
  ),
  PoliceStation(
    id: 'HYD-PS-006',
    name: 'Chikkadpally Police Station',
    commissionerate: Commissionerate.hyderabad,
    sector: 'Central',
    location: LatLng(17.4050, 78.4850),
    contactNumber: '040-2320-1239',
    dutyOfficerName: 'Inspector V. Rao',
    dutyOfficerPhone: '94906-XXXXX',
  ),
  PoliceStation(
    id: 'HYD-PS-007',
    name: 'Gandhinagar Police Station',
    commissionerate: Commissionerate.hyderabad,
    sector: 'Central',
    location: LatLng(17.3950, 78.4950),
    contactNumber: '040-2320-1240',
    dutyOfficerName: 'Inspector A. Singh',
    dutyOfficerPhone: '94906-XXXXX',
  ),
  PoliceStation(
    id: 'HYD-PS-008',
    name: 'Golconda Police Station',
    commissionerate: Commissionerate.hyderabad,
    sector: 'West',
    location: LatLng(17.3833, 78.4017),
    contactNumber: '040-2320-1241',
    dutyOfficerName: 'Inspector N. Gupta',
    dutyOfficerPhone: '94906-XXXXX',
  ),
  PoliceStation(
    id: 'HYD-PS-009',
    name: 'Jubilee Hills Police Station',
    commissionerate: Commissionerate.hyderabad,
    sector: 'West',
    location: LatLng(17.4280, 78.4080),
    contactNumber: '040-2320-1242',
    dutyOfficerName: 'Inspector R. Sharma',
    dutyOfficerPhone: '94906-XXXXX',
  ),
  PoliceStation(
    id: 'HYD-PS-010',
    name: 'Malakpet Police Station',
    commissionerate: Commissionerate.hyderabad,
    sector: 'East',
    location: LatLng(17.3650, 78.5050),
    contactNumber: '040-2320-1243',
    dutyOfficerName: 'Inspector D. Patel',
    dutyOfficerPhone: '94906-XXXXX',
  ),
  PoliceStation(
    id: 'HYD-PS-011',
    name: 'Marredpally Police Station',
    commissionerate: Commissionerate.hyderabad,
    sector: 'North',
    location: LatLng(17.4550, 78.5050),
    contactNumber: '040-2320-1244',
    dutyOfficerName: 'Inspector S. Reddy',
    dutyOfficerPhone: '94906-XXXXX',
  ),
  PoliceStation(
    id: 'HYD-PS-012',
    name: 'Nallakunta Police Station',
    commissionerate: Commissionerate.hyderabad,
    sector: 'Central',
    location: LatLng(17.4050, 78.5150),
    contactNumber: '040-2320-1245',
    dutyOfficerName: 'Inspector K. Naidu',
    dutyOfficerPhone: '94906-XXXXX',
  ),
  PoliceStation(
    id: 'HYD-PS-013',
    name: 'Panjagutta Police Station',
    commissionerate: Commissionerate.hyderabad,
    sector: 'West',
    location: LatLng(17.4250, 78.4550),
    contactNumber: '040-2320-1246',
    dutyOfficerName: 'Inspector P. Kumar',
    dutyOfficerPhone: '94906-XXXXX',
  ),
  PoliceStation(
    id: 'HYD-PS-014',
    name: 'Saidabad Police Station',
    commissionerate: Commissionerate.hyderabad,
    sector: 'South',
    location: LatLng(17.3450, 78.5050),
    contactNumber: '040-2320-1247',
    dutyOfficerName: 'Inspector V. Reddy',
    dutyOfficerPhone: '94906-XXXXX',
  ),
  PoliceStation(
    id: 'HYD-PS-015',
    name: 'Secunderabad Police Station',
    commissionerate: Commissionerate.hyderabad,
    sector: 'North',
    location: LatLng(17.4399, 78.4983),
    contactNumber: '040-2320-1248',
    dutyOfficerName: 'Inspector R. Naik',
    dutyOfficerPhone: '94906-XXXXX',
  ),
  PoliceStation(
    id: 'HYD-PS-016',
    name: 'Trimulgherry Police Station',
    commissionerate: Commissionerate.hyderabad,
    sector: 'North',
    location: LatLng(17.4700, 78.5300),
    contactNumber: '040-2320-1249',
    dutyOfficerName: 'Inspector M. Rao',
    dutyOfficerPhone: '94906-XXXXX',
  ),
  PoliceStation(
    id: 'HYD-PS-017',
    name: 'Tankbund Police Station',
    commissionerate: Commissionerate.hyderabad,
    sector: 'Central',
    location: LatLng(17.4100, 78.4800),
    contactNumber: '040-2320-1250',
    dutyOfficerName: 'Inspector S. Kumar',
    dutyOfficerPhone: '94906-XXXXX',
  ),

  // Cyberabad Commissionerate
  PoliceStation(
    id: 'CYB-PS-001',
    name: 'Gachibowli Police Station',
    commissionerate: Commissionerate.cyberabad,
    sector: 'Madhapur',
    location: LatLng(17.4320, 78.3550),
    contactNumber: '040-2321-1234',
    dutyOfficerName: 'Inspector A. Reddy',
    dutyOfficerPhone: '94906-XXXXX',
  ),
  PoliceStation(
    id: 'CYB-PS-002',
    name: 'Hitech City Police Station',
    commissionerate: Commissionerate.cyberabad,
    sector: 'Madhapur',
    location: LatLng(17.4430, 78.3770),
    contactNumber: '040-2321-1235',
    dutyOfficerName: 'Inspector K. Sharma',
    dutyOfficerPhone: '94906-XXXXX',
  ),
  PoliceStation(
    id: 'CYB-PS-003',
    name: 'Kukatpally Police Station',
    commissionerate: Commissionerate.cyberabad,
    sector: 'Kukatpally',
    location: LatLng(17.4800, 78.4000),
    contactNumber: '040-2321-1236',
    dutyOfficerName: 'Inspector V. Patel',
    dutyOfficerPhone: '94906-XXXXX',
  ),
  PoliceStation(
    id: 'CYB-PS-004',
    name: 'Madhapur Police Station',
    commissionerate: Commissionerate.cyberabad,
    sector: 'Madhapur',
    location: LatLng(17.4470, 78.3800),
    contactNumber: '040-2321-1237',
    dutyOfficerName: 'Inspector R. Singh',
    dutyOfficerPhone: '94906-XXXXX',
  ),
  PoliceStation(
    id: 'CYB-PS-005',
    name: 'Miyapur Police Station',
    commissionerate: Commissionerate.cyberabad,
    sector: 'Miyapur',
    location: LatLng(17.5000, 78.3500),
    contactNumber: '040-2321-1238',
    dutyOfficerName: 'Inspector S. Gupta',
    dutyOfficerPhone: '94906-XXXXX',
  ),
  PoliceStation(
    id: 'CYB-PS-006',
    name: 'Raidugrm Police Station',
    commissionerate: Commissionerate.cyberabad,
    sector: 'Madhapur',
    location: LatLng(17.4550, 78.3650),
    contactNumber: '040-2321-1239',
    dutyOfficerName: 'Inspector P. Naidu',
    dutyOfficerPhone: '94906-XXXXX',
  ),
  PoliceStation(
    id: 'CYB-PS-007',
    name: 'Shamshabad Police Station',
    commissionerate: Commissionerate.cyberabad,
    sector: 'Shamshabad',
    location: LatLng(17.2500, 78.4300),
    contactNumber: '040-2321-1240',
    dutyOfficerName: 'Inspector M. Reddy',
    dutyOfficerPhone: '94906-XXXXX',
  ),

  // Rachakonda Commissionerate
  PoliceStation(
    id: 'RCH-PS-001',
    name: 'Boduppal Police Station',
    commissionerate: Commissionerate.rachakonda,
    sector: 'Boduppal',
    location: LatLng(17.4200, 78.6000),
    contactNumber: '040-2322-1234',
    dutyOfficerName: 'Inspector K. Reddy',
    dutyOfficerPhone: '94906-XXXXX',
  ),
  PoliceStation(
    id: 'RCH-PS-002',
    name: 'Chaitanyapuri Police Station',
    commissionerate: Commissionerate.rachakonda,
    sector: 'Chaitanyapuri',
    location: LatLng(17.3600, 78.5500),
    contactNumber: '040-2322-1235',
    dutyOfficerName: 'Inspector R. Kumar',
    dutyOfficerPhone: '94906-XXXXX',
  ),
  PoliceStation(
    id: 'RCH-PS-003',
    name: 'Hayathnagar Police Station',
    commissionerate: Commissionerate.rachakonda,
    sector: 'Hayathnagar',
    location: LatLng(17.3200, 78.6000),
    contactNumber: '040-2322-1236',
    dutyOfficerName: 'Inspector V. Sharma',
    dutyOfficerPhone: '94906-XXXXX',
  ),
  PoliceStation(
    id: 'RCH-PS-004',
    name: 'Ibrahimpatnam Police Station',
    commissionerate: Commissionerate.rachakonda,
    sector: 'Ibrahimpatnam',
    location: LatLng(17.2000, 78.5300),
    contactNumber: '040-2322-1237',
    dutyOfficerName: 'Inspector P. Singh',
    dutyOfficerPhone: '94906-XXXXX',
  ),
  PoliceStation(
    id: 'RCH-PS-005',
    name: 'LB Nagar Police Station',
    commissionerate: Commissionerate.rachakonda,
    sector: 'LB Nagar',
    location: LatLng(17.3500, 78.5400),
    contactNumber: '040-2322-1238',
    dutyOfficerName: 'Inspector S. Patel',
    dutyOfficerPhone: '94906-XXXXX',
  ),
  PoliceStation(
    id: 'RCH-PS-006',
    name: 'Malkajgiri Police Station',
    commissionerate: Commissionerate.rachakonda,
    sector: 'Malkajgiri',
    location: LatLng(17.4500, 78.5300),
    contactNumber: '040-2322-1239',
    dutyOfficerName: 'Inspector M. Gupta',
    dutyOfficerPhone: '94906-XXXXX',
  ),
  PoliceStation(
    id: 'RCH-PS-007',
    name: 'Uppal Police Station',
    commissionerate: Commissionerate.rachakonda,
    sector: 'Uppal',
    location: LatLng(17.4000, 78.5600),
    contactNumber: '040-2322-1240',
    dutyOfficerName: 'Inspector R. Naidu',
    dutyOfficerPhone: '94906-XXXXX',
  ),
  PoliceStation(
    id: 'RCH-PS-008',
    name: 'Vanasthalipuram Police Station',
    commissionerate: Commissionerate.rachakonda,
    sector: 'Vanasthalipuram',
    location: LatLng(17.3000, 78.5800),
    contactNumber: '040-2322-1241',
    dutyOfficerName: 'Inspector A. Reddy',
    dutyOfficerPhone: '94906-XXXXX',
  ),
];

List<PoliceStation> getAllPoliceStations() => hyderabadPoliceStations;

List<PoliceStation> getPoliceStationsByCommissionerate(Commissionerate commissionerate) {
  return hyderabadPoliceStations.where((ps) => ps.commissionerate == commissionerate).toList();
}

PoliceStation? getPoliceStationById(String id) {
  try {
    return hyderabadPoliceStations.firstWhere((ps) => ps.id == id);
  } catch (_) {
    return null;
  }
}

List<PoliceStation> getPoliceStationsWithinRadius(LatLng center, double radiusKm) {
  return hyderabadPoliceStations.where((ps) => ps.distanceTo(center) <= radiusKm).toList()
    ..sort((a, b) => a.distanceTo(center).compareTo(b.distanceTo(center)));
}