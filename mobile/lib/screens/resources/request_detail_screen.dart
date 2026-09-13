import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/resource_providers.dart';
import '../../models/resource_models.dart';
import '../../models/resource_enums.dart';
import '../../models/user_models.dart';
import '../../data/static_users.dart';
import '../../data/static_resources.dart';
import '../../data/police_stations.dart';

class RequestDetailScreen extends ConsumerStatefulWidget {
  final String requestId;

  const RequestDetailScreen({super.key, required this.requestId});

  @override
  ConsumerState<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends ConsumerState<RequestDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final requestAsync = ref.watch(requestByIdProvider(widget.requestId));
    final currentUserRole = UserRole.sho; // From auth context

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () => context.push('/resources/request/${widget.requestId}/dispatch'),
            tooltip: 'Live Dispatch Map',
          ),
        ],
      ),
      body: requestAsync.when(
        data: (request) {
          if (request == null) {
            return const Center(child: Text('Request not found'));
          }
          return _buildDetailView(context, request, currentUserRole);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildDetailView(BuildContext context, ResourceRequest request, UserRole currentUserRole) {
    final assignedResource = request.assignedResourceId != null
        ? getResourceById(request.assignedResourceId!)
        : null;
    final fromPs = request.assignedFromPoliceStationId != null
        ? getPoliceStationById(request.assignedFromPoliceStationId!)
        : null;
    final raisingPs = getPoliceStationById(request.raisingPoliceStationId);
    final raisedByUser = getUserById(request.raisedByUserId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(request),
          const SizedBox(height: 16),
          _buildResourceCard(request, assignedResource),
          const SizedBox(height: 16),
          _buildLocationCard(request, fromPs, raisingPs),
          const SizedBox(height: 16),
          _buildContactCard(request, raisedByUser),
          const SizedBox(height: 16),
          _buildTimelineCard(request),
          const SizedBox(height: 16),
          _buildActionButtons(context, request, currentUserRole),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(ResourceRequest request) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: request.resourceCategory.icon == Icons.category ? Colors.grey : const Color(0xFF17365D),
                  child: Icon(request.resourceCategory.icon, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.requestNumber, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('${request.resourceCategory.displayName} x${request.quantityRequested}'),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Chip(
                      label: Text(request.status.displayName, style: const TextStyle(fontSize: 12, color: Colors.white)),
                      backgroundColor: request.status.color,
                    ),
                    const SizedBox(height: 4),
                    Chip(
                      label: Text(request.priority.displayName, style: const TextStyle(fontSize: 10, color: Colors.white)),
                      backgroundColor: request.priority.color,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (request.applicationId != null)
              _infoRow(Icons.link, 'Linked Application', request.applicationId!),
            _infoRow(Icons.location_city, 'Mandal', request.mandalName),
            _infoRow(Icons.access_time, 'Required', '${_formatDateTime(request.requiredAt)} - ${_formatDateTime(request.requiredUntil)}'),
            if (request.slaDueAt != null) ...[
              const SizedBox(height: 8),
              _infoRow(
                Icons.timer,
                'SLA Due',
                _formatDateTime(request.slaDueAt!),
                valueStyle: TextStyle(color: _getSlaColor(request.slaDueAt!), fontWeight: FontWeight.bold),
              ),
            ],
            if (request.escalationLevel > 0) ...[
              const SizedBox(height: 8),
              _infoRow(Icons.trending_up, 'Escalation Level', 'Level ${request.escalationLevel}', valueStyle: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResourceCard(ResourceRequest request, ResourceItem? resource) {
    if (resource == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Assigned Resource', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('No resource assigned yet', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text('Find Match'),
                  onPressed: () => context.push('/resources/request/${widget.requestId}/matching'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Assigned Resource', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: resource.category.icon == Icons.category ? Colors.grey : const Color(0xFF17365D),
                  child: Icon(resource.category.icon, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(resource.displayName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Available: ${resource.quantityAvailable}/${resource.quantityTotal}'),
                    ],
                  ),
                ),
                Chip(
                  label: Text(resource.status.displayName, style: const TextStyle(fontSize: 12, color: Colors.white)),
                  backgroundColor: resource.status.color,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(ResourceRequest request, PoliceStation? fromPs, PoliceStation? raisingPs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Locations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _infoRow(Icons.flag, 'Site Address', request.siteAddress),
            _infoRow(Icons.gps_fixed, 'Site Coordinates', '${request.siteLocation.latitude.toStringAsFixed(6)}, ${request.siteLocation.longitude.toStringAsFixed(6)}'),
            const Divider(),
            if (fromPs != null) ...[
              _infoRow(Icons.local_shipping, 'Source PS', fromPs.displayName),
              _infoRow(Icons.contact_phone, 'Source PS Contact', fromPs.contactNumber),
              _infoRow(Icons.person, 'Duty Officer', '${fromPs.dutyOfficerName} (${fromPs.dutyOfficerPhone})'),
              const Divider(),
            ],
            if (raisingPs != null) ...[
              _infoRow(Icons.local_police, 'Requesting PS', raisingPs.displayName),
              _infoRow(Icons.contact_phone, 'Requesting PS Contact', raisingPs.contactNumber),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(ResourceRequest request, User? raisedByUser) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Contact Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _infoRow(Icons.person, 'Raised By', raisedByUser?.name ?? request.raisedByUserId),
            _infoRow(Icons.person, 'Site Contact', request.contactName),
            _infoRow(Icons.phone, 'Site Phone', request.contactPhone, onTap: () => _launchPhone(request.contactPhone)),
            _infoRow(Icons.description, 'Reason', request.reason),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard(ResourceRequest request) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Timeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _timelineEvent(
              title: 'Request Created',
              time: request.createdAt,
              description: 'Request raised by ${request.raisedByUserId}',
              isCompleted: true,
            ),
            if (request.approvedAt != null)
              _timelineEvent(
                title: 'Approved',
                time: request.approvedAt!,
                description: 'Approved by ${request.approvedByUserId}',
                isCompleted: true,
              ),
            _timelineEvent(
              title: _getStatusDisplay(request.status),
              time: request.updatedAt,
              description: 'Current status: ${request.status.displayName}',
              isCompleted: request.status.isTerminal,
              isCurrent: !request.status.isTerminal,
            ),
            if (request.status.isTerminal)
              _timelineEvent(
                title: 'Closed',
                time: request.updatedAt,
                description: 'Request closed',
                isCompleted: true,
              ),
          ],
        ),
      ),
    );
  }

  String _getStatusDisplay(RequestStatus status) {
    switch (status) {
      case RequestStatus.assigned:
        return 'Resource Assigned';
      case RequestStatus.enRoute:
        return 'En Route';
      case RequestStatus.onSite:
        return 'On Site';
      case RequestStatus.inUse:
        return 'In Use';
      case RequestStatus.released:
        return 'Released';
      case RequestStatus.returned:
        return 'Returned';
      default:
        return status.displayName;
    }
  }

  Widget _buildActionButtons(BuildContext context, ResourceRequest request, UserRole currentUserRole) {
    final canApprove = currentUserRole.canApproveRequests;
    final isRaisingPS = request.raisingPoliceStationId == 'HYD-PS-001'; // From user context
    final isHoldingPS = request.assignedFromPoliceStationId == 'HYD-PS-001';

    final actions = <Widget>[];

    // SHO of lending PS: Approve / Reject / Assign specific asset
    if (canApprove && isHoldingPS && request.status == RequestStatus.open) {
      actions.add(_actionButton(
        label: 'Approve',
        icon: Icons.check_circle,
        color: Colors.green,
        onPressed: () => _showApproveDialog(context, request),
      ));
      actions.add(_actionButton(
        label: 'Reject',
        icon: Icons.cancel,
        color: Colors.red,
        onPressed: () => _showRejectDialog(context, request),
      ));
    }

    // Raising officer: Mark En Route / On Site / Released / Returned
    if (isRaisingPS) {
      if (request.status == RequestStatus.assigned) {
        actions.add(_actionButton(
          label: 'Mark En Route',
          icon: Icons.local_shipping,
          color: Colors.blue,
          onPressed: () => _updateStatus(request, RequestStatus.enRoute),
        ));
      }
      if (request.status == RequestStatus.enRoute) {
        actions.add(_actionButton(
          label: 'Mark On Site',
          icon: Icons.location_on,
          color: Colors.teal,
          onPressed: () => _updateStatus(request, RequestStatus.onSite),
        ));
      }
      if (request.status == RequestStatus.onSite || request.status == RequestStatus.inUse) {
        actions.add(_actionButton(
          label: 'Mark Released',
          icon: Icons.check_circle_outline,
          color: Colors.lightGreen,
          onPressed: () => _updateStatus(request, RequestStatus.released),
        ));
      }
      if (request.status == RequestStatus.released) {
        actions.add(_actionButton(
          label: 'Mark Returned',
          icon: Icons.assignment_return,
          color: Colors.green,
          onPressed: () => _showReturnDialog(context, request),
        ));
      }
    }

    // SHO of lending PS: Close with remarks
    if (canApprove && isHoldingPS && request.status == RequestStatus.returned) {
      actions.add(_actionButton(
        label: 'Close Request',
        icon: Icons.lock,
        color: Colors.grey,
        onPressed: () => _showCloseDialog(context, request),
      ));
    }

    // Any superior: Escalate
    if (currentUserRole.canEscalate && !request.status.isTerminal) {
      actions.add(_actionButton(
        label: 'Escalate',
        icon: Icons.warning_amber,
        color: Colors.deepOrange,
        onPressed: () => _escalateRequest(context, request),
      ));
    }

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(spacing: 12, runSpacing: 12, children: actions),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {TextStyle? valueStyle, VoidCallback? onTap}) {
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
                  Text(value, style: valueStyle ?? const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timelineEvent({
    required String title,
    required DateTime time,
    required String description,
    required bool isCompleted,
    bool isCurrent = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green : (isCurrent ? const Color(0xFF17365D) : Colors.grey[300]),
                  shape: BoxShape.circle,
                  border: Border.all(color: isCompleted ? Colors.green : (isCurrent ? const Color(0xFF17365D) : Colors.grey), width: 2),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
              if (!isCurrent)
                Container(width: 2, height: 40, color: Colors.grey[300]),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                  color: isCurrent ? const Color(0xFF17365D) : Colors.black87,
                )),
                Text(_formatDateTime(time), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text(description, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      icon: Icon(icon, color: color),
      label: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  void _showApproveDialog(BuildContext context, ResourceRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Request'),
        content: const Text('Approve this resource request?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(request, RequestStatus.assigned);
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, ResourceRequest request) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Reason for rejection'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(request, RequestStatus.rejected);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showReturnDialog(BuildContext context, ResourceRequest request) {
    ResourceCondition condition = ResourceCondition.good;
    final fuelController = TextEditingController();
    final damageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Mark Returned'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<ResourceCondition>(
                  initialValue: condition,
                  decoration: const InputDecoration(labelText: 'Condition on Return'),
                  items: ResourceCondition.values.map((c) => DropdownMenuItem(value: c, child: Text(c.displayName))).toList(),
                  onChanged: (v) => setState(() => condition = v!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: fuelController,
                  decoration: const InputDecoration(labelText: 'Fuel In (liters)', hintText: 'Enter fuel reading'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: damageController,
                  decoration: const InputDecoration(labelText: 'Damage Notes (if any)'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _updateStatusWithReturn(request, condition, fuelController.text, damageController.text);
              },
              child: const Text('Confirm Return'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCloseDialog(BuildContext context, ResourceRequest request) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Request'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Closing Remarks'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(request, RequestStatus.closed);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(ResourceRequest request, RequestStatus newStatus) async {
    try {
      final repo = ref.read(resourceRequestRepositoryProvider);
      final updated = request.copyWith(status: newStatus, updatedAt: DateTime.now());
      await repo.updateRequest(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to ${newStatus.displayName}'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _updateStatusWithReturn(ResourceRequest request, ResourceCondition condition, String fuelIn, String damageNotes) async {
    try {
      final repo = ref.read(resourceRequestRepositoryProvider);
      final updated = request.copyWith(status: RequestStatus.returned, updatedAt: DateTime.now());
      await repo.updateRequest(updated);

      // Create transfer return record
      if (request.assignedResourceId != null && request.assignedFromPoliceStationId != null) {
        final transfer = ResourceTransfer(
          id: 'XFR-${DateTime.now().millisecondsSinceEpoch}-ret',
          resourceId: request.assignedResourceId!,
          fromPoliceStationId: request.assignedFromPoliceStationId!,
          toPoliceStationId: request.raisingPoliceStationId,
          requestId: request.id,
          returnedAt: DateTime.now(),
          conditionOnDispatch: request.assignedResourceId != null ? getResourceById(request.assignedResourceId!)!.condition : ResourceCondition.good,
          conditionOnReturn: condition,
          fuelIn: double.tryParse(fuelIn),
          damageNotes: damageNotes.isEmpty ? null : damageNotes,
          status: TransferStatus.returned,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await repo.createTransfer(transfer);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resource returned successfully'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _escalateRequest(BuildContext context, ResourceRequest request) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request escalated to next level'), backgroundColor: Colors.deepOrange));
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Color _getSlaColor(DateTime slaDueAt) {
    final remaining = slaDueAt.difference(DateTime.now());
    if (remaining.isNegative) return Colors.red;
    if (remaining.inMinutes <= 10) return Colors.red;
    if (remaining.inMinutes <= 30) return Colors.orange;
    return Colors.green;
  }

  String _formatDateTime(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}