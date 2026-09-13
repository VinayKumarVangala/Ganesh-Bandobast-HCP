import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/resource_providers.dart';
import '../../models/resource_models.dart';
import '../../models/resource_enums.dart';
import '../../services/matching_engine.dart';

class RequestMatchingScreen extends ConsumerStatefulWidget {
  final String requestId;

  const RequestMatchingScreen({super.key, required this.requestId});

  @override
  ConsumerState<RequestMatchingScreen> createState() => _RequestMatchingScreenState();
}

class _RequestMatchingScreenState extends ConsumerState<RequestMatchingScreen> {
  ResourceRequest? _request;
  List<MatchResult> _matches = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRequestAndMatches();
  }

  Future<void> _loadRequestAndMatches() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

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

      final matches = MatchingEngine.findMatches(
        requestLocation: request.siteLocation,
        resourceCategory: request.resourceCategory,
        quantityRequested: request.quantityRequested,
        priority: request.priority,
        searchRadiusKm: 15.0,
        excludePoliceStationId: request.raisingPoliceStationId,
      );

      setState(() {
        _matches = matches;
        _isLoading = false;
      });
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
        appBar: AppBar(title: const Text('Finding Matches...')),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Matching'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRequestAndMatches,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildRequestSummary(_request!),
          const Divider(height: 1),
          Expanded(
            child: _matches.isEmpty
                ? _buildNoMatchesView()
                : _buildMatchesList(_matches),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestSummary(ResourceRequest request) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: request.resourceCategory.icon == Icons.category ? Colors.grey : const Color(0xFF17365D),
                  child: Icon(request.resourceCategory.icon, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.resourceCategory.displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Qty: ${request.quantityRequested} | Priority: ${request.priority.displayName}',
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
                Chip(
                  label: Text(request.priority.displayName, style: const TextStyle(color: Colors.white, fontSize: 12)),
                  backgroundColor: request.priority.color,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Site: ${request.siteAddress}', style: TextStyle(color: Colors.grey[700])),
            Text('Required: ${_formatDateTime(request.requiredAt)} - ${_formatDateTime(request.requiredUntil)}'),
            if (request.slaDueAt != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.timer, size: 16, color: _getSlaColor(request.slaDueAt!)),
                  const SizedBox(width: 4),
                  Text('SLA Due: ${_formatDateTime(request.slaDueAt!)}',
                      style: TextStyle(color: _getSlaColor(request.slaDueAt!), fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getSlaColor(DateTime slaDueAt) {
    final remaining = slaDueAt.difference(DateTime.now());
    if (remaining.isNegative) return Colors.red;
    if (remaining.inMinutes <= 10) return Colors.red;
    if (remaining.inMinutes <= 30) return Colors.orange;
    return Colors.green;
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildNoMatchesView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              'No Matching Resources Found',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'No ${_request!.resourceCategory.displayName.toLowerCase()} resources available within 15 km of your police station.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.warning_amber),
              label: const Text('Escalate to Superior'),
              onPressed: _escalateRequest,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Back to Request'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchesList(List<MatchResult> matches) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return _MatchCard(
          match: match,
          request: _request!,
          onSendRequest: () => _sendLendRequest(match),
          rank: index + 1,
        );
      },
    );
  }

  Future<void> _sendLendRequest(MatchResult match) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Lend Request'),
        content: Text(
          'Send a lend request to ${match.policeStation.name} for ${match.resource.name}?\n\n'
          'Distance: ${match.distanceKm.toStringAsFixed(1)} km\n'
          'Estimated ETA: ${match.estimatedDurationMinutes} minutes\n'
          'Available: ${match.resource.quantityAvailable} units',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Send Request')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Create a transfer record
      final transfer = ResourceTransfer(
        id: 'XFR-${DateTime.now().millisecondsSinceEpoch}',
        resourceId: match.resource.id,
        fromPoliceStationId: match.policeStation.id,
        toPoliceStationId: _request!.raisingPoliceStationId,
        requestId: _request!.id,
        conditionOnDispatch: match.resource.condition,
        status: TransferStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final repo = ref.read(resourceRequestRepositoryProvider);
      await repo.createTransfer(transfer);

      // Update request status
      final updatedRequest = _request!.copyWith(
        status: RequestStatus.matching,
        assignedResourceId: match.resource.id,
        assignedFromPoliceStationId: match.policeStation.id,
        updatedAt: DateTime.now(),
      );
      await repo.updateRequest(updatedRequest);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lend request sent to ${match.policeStation.name}!'), backgroundColor: Colors.green),
        );
        context.push('/resources/request/${_request!.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _escalateRequest() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Escalation sent to Circle Inspector'), backgroundColor: Colors.deepOrange),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final MatchResult match;
  final ResourceRequest request;
  final VoidCallback onSendRequest;
  final int rank;

  const _MatchCard({
    required this.match,
    required this.request,
    required this.onSendRequest,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF17365D),
                  child: Text('$rank', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(match.resource.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(match.resource.assetCode, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Chip(
                      label: Text(match.resource.status.displayName, style: const TextStyle(fontSize: 10, color: Colors.white)),
                      backgroundColor: match.resource.status.color,
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(height: 4),
                    Chip(
                      label: Text(match.resource.condition.displayName, style: const TextStyle(fontSize: 10, color: Colors.white)),
                      backgroundColor: match.resource.condition.color,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                _InfoBadge(Icons.local_police, match.policeStation.name),
                const SizedBox(width: 12),
                _InfoBadge(Icons.straighten, '${match.distanceKm.toStringAsFixed(1)} km'),
                const SizedBox(width: 12),
                _InfoBadge(Icons.timer, '${match.estimatedDurationMinutes} min'),
                const SizedBox(width: 12),
                _InfoBadge(Icons.inventory, 'Avail: ${match.resource.quantityAvailable}'),
              ],
            ),
            const SizedBox(height: 12),
            if (match.resource.chargeableRatePerHour != null)
              Text('Rate: ₹${match.resource.chargeableRatePerHour!.toStringAsFixed(0)}/hr', style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('Send Lend Request'),
                onPressed: onSendRequest,
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF17365D)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoBadge(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}