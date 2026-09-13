import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/resource_providers.dart';
import '../../models/resource_models.dart';

class MyStationRequestsScreen extends ConsumerStatefulWidget {
  const MyStationRequestsScreen({super.key});

  @override
  ConsumerState<MyStationRequestsScreen> createState() => _MyStationRequestsScreenState();
}

class _MyStationRequestsScreenState extends ConsumerState<MyStationRequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPoliceStationId = 'HYD-PS-001'; // From user context

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Station Requests'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Outgoing'),
            Tab(text: 'Incoming'),
            Tab(text: 'Active'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOutgoingTab(currentPoliceStationId),
          _buildIncomingTab(currentPoliceStationId),
          _buildActiveTab(currentPoliceStationId),
          _buildHistoryTab(currentPoliceStationId),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/resources/request/new'),
        icon: const Icon(Icons.add),
        label: const Text('New Request'),
        backgroundColor: const Color(0xFF17365D),
      ),
    );
  }

  Widget _buildOutgoingTab(String policeStationId) {
    return Consumer(
      builder: (context, ref, _) {
        final requestsAsync = ref.watch(outgoingRequestsProvider(policeStationId));
        return requestsAsync.when(
          data: (requests) => _buildRequestsList(requests, 'No outgoing requests'),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        );
      },
    );
  }

  Widget _buildIncomingTab(String policeStationId) {
    return Consumer(
      builder: (context, ref, _) {
        final requestsAsync = ref.watch(incomingRequestsProvider(policeStationId));
        return requestsAsync.when(
          data: (requests) => _buildRequestsList(requests, 'No incoming requests'),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        );
      },
    );
  }

  Widget _buildActiveTab(String policeStationId) {
    return Consumer(
      builder: (context, ref, _) {
        final requestsAsync = ref.watch(activeRequestsProvider);
        return requestsAsync.when(
          data: (requests) {
            final filtered = requests.where((r) =>
              r.raisingPoliceStationId == policeStationId ||
              r.assignedFromPoliceStationId == policeStationId
            ).toList();
            return _buildRequestsList(filtered, 'No active requests');
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        );
      },
    );
  }

  Widget _buildHistoryTab(String policeStationId) {
    return Consumer(
      builder: (context, ref, _) {
        final requestsAsync = ref.watch(activeRequestsProvider);
        return requestsAsync.when(
          data: (requests) {
            final filtered = requests.where((r) =>
              (r.raisingPoliceStationId == policeStationId ||
               r.assignedFromPoliceStationId == policeStationId) &&
              r.status.isTerminal
            ).toList();
            return _buildRequestsList(filtered, 'No history');
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        );
      },
    );
  }

  Widget _buildRequestsList(List<ResourceRequest> requests, String emptyMessage) {
    if (requests.isEmpty) {
      return Center(child: Text(emptyMessage, style: TextStyle(color: Colors.grey[600])));
    }

    requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return _RequestListTile(request: request);
      },
    );
  }
}

class _RequestListTile extends StatelessWidget {
  final ResourceRequest request;

  const _RequestListTile({required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: request.resourceCategory.icon == Icons.category ? Colors.grey : const Color(0xFF17365D),
          child: Icon(request.resourceCategory.icon, color: Colors.white),
        ),
        title: Text(request.requestNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${request.resourceCategory.displayName} x${request.quantityRequested}'),
            Text(request.siteAddress),
            Text('Priority: ${request.priority.displayName}', style: TextStyle(color: request.priority.color, fontWeight: FontWeight.w500)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Chip(
              label: Text(request.status.displayName, style: const TextStyle(fontSize: 10, color: Colors.white)),
              backgroundColor: request.status.color,
              visualDensity: VisualDensity.compact,
            ),
            if (request.slaDueAt != null) ...[
              const SizedBox(height: 4),
              Text(
                _formatTimeUntilSla(request.slaDueAt!),
                style: TextStyle(fontSize: 10, color: _getSlaColor(request.slaDueAt!), fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
        onTap: () => context.push('/resources/request/${request.id}'),
      ),
    );
  }

  String _formatTimeUntilSla(DateTime slaDueAt) {
    final remaining = slaDueAt.difference(DateTime.now());
    if (remaining.isNegative) return 'SLA BREACHED';
    if (remaining.inHours > 0) return '${remaining.inHours}h ${remaining.inMinutes % 60}m left';
    return '${remaining.inMinutes}m left';
  }

  Color _getSlaColor(DateTime slaDueAt) {
    final remaining = slaDueAt.difference(DateTime.now());
    if (remaining.isNegative) return Colors.red;
    if (remaining.inMinutes <= 10) return Colors.red;
    if (remaining.inMinutes <= 30) return Colors.orange;
    return Colors.green;
  }
}