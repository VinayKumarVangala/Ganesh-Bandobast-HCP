import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/resource_providers.dart';
import '../../models/resource_models.dart';
import '../../models/resource_enums.dart';
import '../../data/police_stations.dart';

class ResourceDetailScreen extends ConsumerWidget {
  final String resourceId;

  const ResourceDetailScreen({super.key, required this.resourceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourceAsync = ref.watch(resourceByIdProvider(resourceId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resource Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareResource(context),
            tooltip: 'Share',
          ),
        ],
      ),
      body: resourceAsync.when(
        data: (resource) {
          if (resource == null) {
            return const Center(child: Text('Resource not found'));
          }
          return _buildDetailView(context, resource);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildDetailView(BuildContext context, ResourceItem resource) {
    final ps = getPoliceStationById(resource.currentHoldingPoliceStationId);
    final owningPs = getPoliceStationById(resource.owningPoliceStationId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(resource),
          const SizedBox(height: 16),
          _buildSpecsCard(resource),
const SizedBox(height: 16),
            _buildLocationCard(resource, ps, owningPs),
          const SizedBox(height: 16),
          _buildCustodianCard(resource),
          const SizedBox(height: 16),
          _buildServiceHistoryCard(resource),
          const SizedBox(height: 16),
          _buildAvailabilityCalendar(resource),
          const SizedBox(height: 16),
          _buildActionButtons(context, resource),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(ResourceItem resource) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: resource.category.icon == Icons.category ? Colors.grey : const Color(0xFF17365D),
                  child: Icon(resource.category.icon, size: 30, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(resource.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(resource.assetCode, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Chip(
                            label: Text(resource.status.displayName, style: const TextStyle(fontSize: 12, color: Colors.white)),
                            backgroundColor: resource.status.color,
                            visualDensity: VisualDensity.compact,
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(resource.condition.displayName, style: const TextStyle(fontSize: 12, color: Colors.white)),
                            backgroundColor: resource.condition.color,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatChip(label: 'Available', value: '${resource.quantityAvailable}', color: Colors.green),
                const SizedBox(width: 12),
                _StatChip(label: 'Deployed', value: '${resource.quantityDeployed}', color: Colors.orange),
                const SizedBox(width: 12),
                _StatChip(label: 'Total', value: '${resource.quantityTotal}', color: Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecsCard(ResourceItem resource) {
    final specs = <_SpecRow>[
      _SpecRow('Category', resource.category.displayName, icon: resource.category.icon),
      if (resource.capacitySpec != null) _SpecRow('Capacity', resource.capacitySpec!),
      if (resource.fuelType != null) _SpecRow('Fuel Type', resource.fuelType!),
      _SpecRow('Requires Operator', resource.requiresOperator ? 'Yes' : 'No'),
      _SpecRow('Chargeable Rate', resource.chargeableRatePerHour != null ? '₹${resource.chargeableRatePerHour!.toStringAsFixed(0)}/hr' : 'N/A'),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Specifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...specs.map((s) => _buildSpecRow(s)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(_SpecRow spec) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (spec.icon != null) ...[
            Icon(spec.icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
          ],
          Expanded(child: Text(spec.label, style: TextStyle(fontSize: 16, color: Colors.grey[700]))),
          Text(spec.value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildLocationCard(ResourceItem resource, PoliceStation? ps, PoliceStation? owningPs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Current Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (resource.currentLocation != null) ...[
              _InfoRow(Icons.location_on, 'Coordinates', '${resource.currentLocation!.latitude.toStringAsFixed(6)}, ${resource.currentLocation!.longitude.toStringAsFixed(6)}'),
              const SizedBox(height: 8),
            ],
            if (ps != null) ...[
              _InfoRow(Icons.local_police, 'Holding Police Station', ps.displayName),
              _InfoRow(Icons.contact_phone, 'PS Contact', ps.contactNumber),
              _InfoRow(Icons.person, 'Duty Officer', '${ps.dutyOfficerName} (${ps.dutyOfficerPhone})'),
              const SizedBox(height: 8),
            ],
            if (owningPs != null && owningPs.id != ps?.id) ...[
              const Divider(),
              _InfoRow(Icons.account_balance, 'Owning Police Station', owningPs.displayName),
            ],
            if (resource.lastKnownLocationAt != null) ...[
              const Divider(),
              _InfoRow(Icons.access_time, 'Last Location Update', _formatDateTime(resource.lastKnownLocationAt!)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustodianCard(ResourceItem resource) {
    if (resource.custodianName == null && resource.custodianPhone == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Custodian', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (resource.custodianName != null)
              _InfoRow(Icons.person, 'Name', resource.custodianName!),
            if (resource.custodianPhone != null)
              _InfoRow(Icons.phone, 'Phone', resource.custodianPhone!, onTap: () => _launchPhone(resource.custodianPhone!)),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceHistoryCard(ResourceItem resource) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Service History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _InfoRow(Icons.build, 'Last Serviced', resource.lastServicedAt != null ? _formatDate(resource.lastServicedAt!) : 'Not recorded'),
            _InfoRow(Icons.calendar_today, 'Added to System', _formatDate(resource.createdAt)),
            _InfoRow(Icons.update, 'Last Updated', _formatDate(resource.updatedAt)),
            if (resource.remarks != null && resource.remarks!.isNotEmpty) ...[
              const Divider(),
              const Text('Remarks', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(resource.remarks!, style: TextStyle(color: Colors.grey[700])),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityCalendar(ResourceItem resource) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Availability Calendar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_month, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text('Calendar view coming soon', style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text(
                      resource.isAvailable ? 'Currently AVAILABLE' : 'Currently NOT AVAILABLE',
                      style: TextStyle(
                        color: resource.isAvailable ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ResourceItem resource) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_task),
            label: const Text('Request This Resource'),
            onPressed: () => context.push('/resources/request/new'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF17365D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.directions),
            label: const Text('Get Directions'),
            onPressed: () => _getDirections(resource),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF17365D),
              side: const BorderSide(color: Color(0xFF17365D)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _InfoRow(IconData icon, String label, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _getDirections(ResourceItem resource) async {
    if (resource.currentLocation == null) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${resource.currentLocation!.latitude},${resource.currentLocation!.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _shareResource(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share functionality coming soon')));
  }
}

Widget _StatChip({required String label, required String value, required Color color}) {
  return Chip(
    label: Text('$label: $value', style: TextStyle(fontSize: 12, color: color)),
    backgroundColor: color.withValues(alpha: 0.1),
    visualDensity: VisualDensity.compact,
  );
}

class _SpecRow {
  final String label;
  final String value;
  final IconData? icon;

  _SpecRow(this.label, this.value, {this.icon});
}