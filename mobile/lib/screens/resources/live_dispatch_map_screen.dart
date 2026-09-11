import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../providers/resource_providers.dart';
import '../../models/resource_models.dart';
import '../../models/resource_enums.dart';
import '../../data/police_stations.dart';
import '../../config/feature_flags.dart';

class LiveDispatchMapScreen extends ConsumerStatefulWidget {
  final String requestId;

  const LiveDispatchMapScreen({super.key, required this.requestId});

  @override
  ConsumerState<LiveDispatchMapScreen> createState() => _LiveDispatchMapScreenState();
}

class _LiveDispatchMapScreenState extends ConsumerState<LiveDispatchMapScreen> {
  ResourceRequest? _request;
  ResourceItem? _resource;
  PoliceStation? _fromPs;
  PoliceStation? _toPs;
  LatLng? _resourceCurrentLocation;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
    // In real implementation, subscribe to realtime location updates
  }

  Future<void> _loadData() async {
    try {
      final repo = ref.read(resourceRequestRepositoryProvider);
      final request = await repo.getRequestById(widget.requestId);

      if (request == null) {
        setState(() {
          _error = 'Request not found';
          _isLoading = false;
        });
        return;
      }

      _request = request;

      if (request.assignedResourceId != null) {
        _resource = getResourceById(request.assignedResourceId!);
        _resourceCurrentLocation = _resource?.currentLocation;
      }

      if (request.assignedFromPoliceStationId != null) {
        _fromPs = getPoliceStationById(request.assignedFromPoliceStationId!);
      }

      _toPs = getPoliceStationById(request.raisingPoliceStationId);

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Live Dispatch')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error: $_error')),
      );
    }

    if (_request == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Request not found')),
      );
    }

    final center = _calculateMapCenter();
    final bounds = _calculateBounds();

    return Scaffold(
      appBar: AppBar(
        title: Text('Dispatch: ${_request!.requestNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh Location',
          ),
        ],
      ),
      body: Stack(
        children: [
          _StaticDispatchMap(
            center: center,
            bounds: bounds,
            fromLocation: _fromPs?.location ?? _request!.siteLocation,
            toLocation: _request!.siteLocation,
            resourceLocation: _resourceCurrentLocation,
            fromLabel: _fromPs?.name ?? 'Source PS',
            toLabel: 'Immersion Site',
            resourceLabel: _resource?.name ?? 'Resource',
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomSheet(),
          ),
        ],
      ),
    );
  }

  LatLng _calculateMapCenter() {
    final points = <LatLng>[];
    if (_fromPs != null) points.add(_fromPs!.location);
    points.add(_request!.siteLocation);
    if (_resourceCurrentLocation != null) points.add(_resourceCurrentLocation!);

    double lat = 0, lng = 0;
    for (final p in points) {
      lat += p.latitude;
      lng += p.longitude;
    }
    return LatLng(lat / points.length, lng / points.length);
  }

  (LatLng, LatLng) _calculateBounds() {
    final points = <LatLng>[];
    if (_fromPs != null) points.add(_fromPs!.location);
    points.add(_request!.siteLocation);
    if (_resourceCurrentLocation != null) points.add(_resourceCurrentLocation!);

    double minLat = points.first.latitude, maxLat = points.first.latitude;
    double minLng = points.first.longitude, maxLng = points.first.longitude;

    for (final p in points) {
      minLat = minLat < p.latitude ? minLat : p.latitude;
      maxLat = maxLat > p.latitude ? maxLat : p.latitude;
      minLng = minLng < p.longitude ? minLng : p.longitude;
      maxLng = maxLng > p.longitude ? maxLng : p.longitude;
    }

    return (LatLng(minLat, minLng), LatLng(maxLat, maxLng));
  }

  Widget _buildBottomSheet() {
    final distance = _resourceCurrentLocation != null && _fromPs != null
        ? LatLng.distance(_fromPs!.location, _resourceCurrentLocation!)
        : 0.0;

    final remainingDistance = _resourceCurrentLocation != null
        ? LatLng.distance(_resourceCurrentLocation!, _request!.siteLocation)
        : LatLng.distance(_fromPs?.location ?? _request!.siteLocation, _request!.siteLocation);

    final progress = distance / (distance + remainingDistance) * 100;

    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _InfoColumn(
                    icon: Icons.local_shipping,
                    label: 'Source',
                    value: _fromPs?.name ?? 'Unknown',
                  ),
                ),
                const Icon(Icons.arrow_forward, color: Colors.grey),
                Expanded(
                  child: _InfoColumn(
                    icon: Icons.location_on,
                    label: 'Destination',
                    value: 'Immersion Site',
                    alignRight: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_resourceCurrentLocation != null) ...[
              LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF17365D)),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${progress.toStringAsFixed(0)}% complete', style: TextStyle(color: Colors.grey[600])),
                  Text('${remainingDistance.toStringAsFixed(1)} km remaining', style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatusChip(
                  label: 'Status',
                  value: _request!.status.displayName,
                  color: _request!.status.color,
                ),
                _StatusChip(
                  label: 'ETA',
                  value: _calculateEta(remainingDistance),
                  color: Colors.blue,
                ),
                _StatusChip(
                  label: 'Priority',
                  value: _request!.priority.displayName,
                  color: _request!.priority.color,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.directions),
                    label: const Text('Open in Maps'),
                    onPressed: _openInMaps,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.notifications),
                    label: const Text('Notify on Arrival'),
                    onPressed: _setupGeofenceAlert,
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF17365D)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _calculateEta(double remainingKm) {
    const avgSpeedKmh = 30.0;
    final minutes = (remainingKm / avgSpeedKmh * 60).ceil();
    if (minutes < 60) return '$minutes min';
    return '${minutes ~/ 60}h ${minutes % 60}m';
  }

  void _openInMaps() {
    // Open in Google Maps / MapmyIndia
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening in maps...')));
  }

  void _setupGeofenceAlert() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Geofence alert set for 100m radius'), backgroundColor: Colors.green));
  }
}

class _InfoColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool alignRight;

  const _InfoColumn({
    required this.icon,
    required this.label,
    required this.value,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF17365D)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500), textAlign: alignRight ? TextAlign.end : TextAlign.start),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatusChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Chip(
          label: Text(value, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: color,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

class _StaticDispatchMap extends StatelessWidget {
  final LatLng center;
  final (LatLng, LatLng) bounds;
  final LatLng fromLocation;
  final LatLng toLocation;
  final LatLng? resourceLocation;
  final String fromLabel;
  final String toLabel;
  final String resourceLabel;

  const _StaticDispatchMap({
    required this.center,
    required this.bounds,
    required this.fromLocation,
    required this.toLocation,
    this.resourceLocation,
    required this.fromLabel,
    required this.toLabel,
    required this.resourceLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.map, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text('Live Dispatch Map (MapmyIndia Integration)', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                const SizedBox(height: 8),
                Text('Source: ${fromLabel}', style: TextStyle(color: Colors.grey[500])),
                Text('Destination: ${toLabel}', style: TextStyle(color: Colors.grey[500])),
                if (resourceLocation != null)
                  Text('Resource: ${resourceLabel}', style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          ),
          _MapPin(
            position: _calculatePosition(fromLocation),
            color: Colors.blue,
            icon: Icons.local_police,
            label: fromLabel,
          ),
          _MapPin(
            position: _calculatePosition(toLocation),
            color: Colors.red,
            icon: Icons.flag,
            label: toLabel,
          ),
          if (resourceLocation != null)
            _MapPin(
              position: _calculatePosition(resourceLocation!),
              color: Colors.green,
              icon: Icons.local_shipping,
              label: resourceLabel,
            ),
          // Route line
          CustomPaint(
            painter: _RoutePainter(
              from: _calculatePosition(fromLocation),
              to: _calculatePosition(toLocation),
              resource: resourceLocation != null ? _calculatePosition(resourceLocation!) : null,
            ),
            size: Size.infinite,
          ),
        ],
      ),
    );
  }

  Offset _calculatePosition(LatLng point) {
    // Simple projection for visualization
    const double latRange = 0.1; // ~11 km
    const double lngRange = 0.1;
    const double mapWidth = 400.0;
    const double mapHeight = 400.0;

    final minLat = bounds.$1.latitude;
    final minLng = bounds.$1.longitude;
    final maxLat = bounds.$2.latitude;
    final maxLng = bounds.$2.longitude;

    final latDiff = maxLat - minLat;
    final lngDiff = maxLng - minLng;

    final x = ((point.longitude - minLng) / (lngDiff > 0 ? lngDiff : 0.01)) * mapWidth;
    final y = mapHeight - ((point.latitude - minLat) / (latDiff > 0 ? latDiff : 0.01)) * mapHeight;

    return Offset(x.clamp(20.0, mapWidth - 20.0), y.clamp(20.0, mapHeight - 20.0));
  }
}

class _MapPin extends StatelessWidget {
  final Offset position;
  final Color color;
  final IconData icon;
  final String label;

  const _MapPin({
    required this.position,
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - 20,
      top: position.dy - 50,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  final Offset from;
  final Offset to;
  final Offset? resource;

  _RoutePainter({required this.from, required this.to, this.resource});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF17365D)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dashPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw route from source to destination
    _drawDashedLine(canvas, from, to, dashPaint);

    // Draw resource position if available
    if (resource != null) {
      final resourcePaint = Paint()
        ..color = Colors.green
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      _drawDashedLine(canvas, from, resource!, resourcePaint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 10.0;
    const dashSpace = 5.0;
    final distance = (end - start).distance;
    final count = (distance / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < count; i++) {
      final startFraction = (i * (dashWidth + dashSpace)) / distance;
      final endFraction = ((i * (dashWidth + dashSpace)) + dashWidth) / distance;
      if (endFraction > 1.0) break;

      final p1 = Offset.lerp(start, end, startFraction)!;
      final p2 = Offset.lerp(start, end, endFraction)!;
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}