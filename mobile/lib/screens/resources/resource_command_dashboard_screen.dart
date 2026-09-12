import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/resource_providers.dart';
import '../../models/resource_models.dart';
import '../../models/resource_enums.dart';
import '../../services/matching_engine.dart';
import '../../data/police_stations.dart';
import '../../data/static_resources.dart';
import '../../config/feature_flags.dart';

class ResourceCommandDashboardScreen extends ConsumerWidget {
  const ResourceCommandDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeRequestsAsync = ref.watch(activeRequestsProvider);
    final allResourcesAsync = ref.watch(allResourcesProvider);
    final allPoliceStationsAsync = ref.watch(allPoliceStationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resource Command Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(activeRequestsProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildKpiCards(activeRequestsAsync, allResourcesAsync),
            const SizedBox(height: 24),
            _buildDemandVsSupplyHeatmap(allResourcesAsync, allPoliceStationsAsync),
            const SizedBox(height: 24),
            _buildSlaBreaches(activeRequestsAsync),
            const SizedBox(height: 24),
            _buildScarceCategories(allResourcesAsync, activeRequestsAsync),
            const SizedBox(height: 24),
            _buildPerPsUtilization(allResourcesAsync),
            const SizedBox(height: 24),
            _buildEscalationQueue(activeRequestsAsync),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCards(AsyncValue<List<ResourceRequest>> requestsAsync, AsyncValue<List<ResourceItem>> resourcesAsync) {
    return requestsAsync.when(
      data: (requests) {
        return resourcesAsync.when(
          data: (resources) {
            final openCount = requests.where((r) => r.status == RequestStatus.open).length;
            final assignedCount = requests.where((r) => r.status == RequestStatus.assigned).length;
            final enRouteCount = requests.where((r) => r.status == RequestStatus.enRoute).length;
            final onSiteCount = requests.where((r) => r.status == RequestStatus.onSite).length;
            final breachedCount = requests.where((r) => r.isSlaBreached).length;

            final totalResources = resources.length;
            final availableResources = resources.where((r) => r.isAvailable).length;
            final deployedResources = resources.where((r) => r.isDeployed).length;

            return Row(
              children: [
                Expanded(child: _KpiCard('Open Requests', openCount.toString(), Icons.assignment, Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _KpiCard('Assigned', assignedCount.toString(), Icons.local_shipping, Colors.indigo)),
                const SizedBox(width: 12),
                Expanded(child: _KpiCard('En Route', enRouteCount.toString(), Icons.directions, Colors.teal)),
                const SizedBox(width: 12),
                Expanded(child: _KpiCard('On Site', onSiteCount.toString(), Icons.location_on, Colors.orange)),
              ],
            );
          },
          loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildDemandVsSupplyHeatmap(AsyncValue<List<ResourceItem>> resourcesAsync, AsyncValue<List<PoliceStation>> psAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Demand vs Supply by Sector', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            resourcesAsync.when(
              data: (resources) {
                return psAsync.when(
                  data: (stations) {
                    final sectorData = <String, _SectorStats>{};

                    // Initialize sectors
                    for (final ps in stations) {
                      sectorData[ps.sector] = _SectorStats(sector: ps.sector, commissionerate: ps.commissionerate.displayName);
                    }

                    // Count resources by sector
                    for (final r in resources) {
                      final ps = getPoliceStationById(r.currentHoldingPoliceStationId);
                      if (ps != null && sectorData.containsKey(ps.sector)) {
                        final stats = sectorData[ps.sector]!;
                        stats.totalResources++;
                        if (r.isAvailable) stats.availableResources++;
                        if (r.isDeployed) stats.deployedResources++;
                      }
                    }

                    // Add demand from requests (placeholder - would come from requests)
                    // For now, use resource counts as proxy

                    final sectors = sectorData.values.toList()
                      ..sort((a, b) => b.utilizationRatio.compareTo(a.utilizationRatio));

                    return Column(
                      children: sectors.map((s) => _SectorHeatmapRow(stats: s)).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlaBreaches(AsyncValue<List<ResourceRequest>> requestsAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('SLA Breaches (Aging Past Due)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
            requestsAsync.when(
              data: (requests) {
                final breached = requests.where((r) => r.isSlaBreached).toList()
                  ..sort((a, b) => (b.slaDueAt ?? DateTime.now()).compareTo(a.slaDueAt ?? DateTime.now()));

                if (breached.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('No SLA breaches', style: TextStyle(color: Colors.green))),
                  );
                }

                return Column(
                  children: breached.take(10).map((r) => _SlaBreachRow(request: r)).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScarceCategories(AsyncValue<List<ResourceItem>> resourcesAsync, AsyncValue<List<ResourceRequest>> requestsAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Top 5 Scarce Categories This Week', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            resourcesAsync.when(
              data: (resources) {
                return requestsAsync.when(
                  data: (requests) {
                    final categoryDemand = <ResourceCategory, int>{};

                    for (final r in requests) {
                      if (r.status.isActive) {
                        categoryDemand[r.resourceCategory] = (categoryDemand[r.resourceCategory] ?? 0) + r.quantityRequested;
                      }
                    }

                    final categories = ResourceCategory.values.where((c) {
                      final available = resources.where((r) => r.category == c && r.isAvailable).length;
                      final demand = categoryDemand[c] ?? 0;
                      return demand > 0 || available > 0;
                    }).toList();

                    categories.sort((a, b) {
                      final availA = resources.where((r) => r.category == a && r.isAvailable).length;
                      final availB = resources.where((r) => r.category == b && r.isAvailable).length;
                      final demandA = categoryDemand[a] ?? 0;
                      final demandB = categoryDemand[b] ?? 0;
                      final ratioA = demandA > 0 ? demandA / (availA + 1) : 0.0;
                      final ratioB = demandB > 0 ? demandB / (availB + 1) : 0.0;
                      return ratioB.compareTo(ratioA);
                    });

                    return Column(
                      children: categories.take(5).map((cat) {
                        final available = resources.where((r) => r.category == cat && r.isAvailable).length;
                        final demand = categoryDemand[cat] ?? 0;
                        return _ScarceCategoryRow(
                          category: cat,
                          available: available,
                          demand: demand,
                          ratio: demand / (available + 1),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerPsUtilization(AsyncValue<List<ResourceItem>> resourcesAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Per-PS Utilization (Deployed / Total)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            resourcesAsync.when(
              data: (resources) {
                final psStats = <String, _PsUtilization>{};

                for (final r in resources) {
                  final ps = getPoliceStationById(r.currentHoldingPoliceStationId);
                  if (ps == null) continue;

                  if (!psStats.containsKey(ps.id)) {
                    psStats[ps.id] = _PsUtilization(ps: ps);
                  }
                  final stats = psStats[ps.id]!;
                  stats.total += r.quantityTotal;
                  stats.available += r.quantityAvailable;
                  stats.deployed += r.quantityDeployed;
                }

                final sorted = psStats.values.toList()
                  ..sort((a, b) => b.utilizationPercent.compareTo(a.utilizationPercent));

                return Column(
                  children: sorted.take(10).map((s) => _PsUtilizationRow(stats: s)).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEscalationQueue(AsyncValue<List<ResourceRequest>> requestsAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Escalation Queue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            requestsAsync.when(
              data: (requests) {
                final escalated = requests.where((r) => r.escalationLevel > 0 && !r.status.isTerminal).toList()
                  ..sort((a, b) => b.escalationLevel.compareTo(a.escalationLevel));

                if (escalated.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('No escalated requests', style: TextStyle(color: Colors.green))),
                  );
                }

                return Column(
                  children: escalated.map((r) => _EscalationRow(request: r)).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600]), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _SectorStats {
  final String sector;
  final String commissionerate;
  int totalResources = 0;
  int availableResources = 0;
  int deployedResources = 0;

  _SectorStats({required this.sector, required this.commissionerate});

  double get utilizationRatio => totalResources > 0 ? deployedResources / totalResources : 0.0;
}

class _SectorHeatmapRow extends StatelessWidget {
  final _SectorStats stats;

  const _SectorHeatmapRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    final color = stats.utilizationRatio > 0.8
        ? Colors.red
        : stats.utilizationRatio > 0.5
            ? Colors.orange
            : Colors.green;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text('Sector ${stats.sector} (${stats.commissionerate})', style: const TextStyle(fontWeight: FontWeight.w500))),
          Text('${stats.availableResources} / ${stats.totalResources} available', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(width: 12),
          Container(
            width: 60,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: stats.utilizationRatio.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('${(stats.utilizationRatio * 100).toInt()}%', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _SlaBreachRow extends StatelessWidget {
  final ResourceRequest request;

  const _SlaBreachRow({required this.request});

  @override
  Widget build(BuildContext context) {
    final overdue = DateTime.now().difference(request.slaDueAt!);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.requestNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${request.resourceCategory.displayName} | ${request.raisingPoliceStationId}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Overdue ${overdue.inHours}h ${overdue.inMinutes % 60}m', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              Text('SLA: ${_formatTime(request.slaDueAt!)}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _ScarceCategoryRow extends StatelessWidget {
  final ResourceCategory category;
  final int available;
  final int demand;
  final double ratio;

  const _ScarceCategoryRow({
    required this.category,
    required this.available,
    required this.demand,
    required this.ratio,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF17365D),
            child: Icon(category.icon, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(category.displayName, style: const TextStyle(fontWeight: FontWeight.w500))),
          Text('Avail: $available', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w500)),
          const SizedBox(width: 16),
          Text('Demand: $demand', style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.w500)),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ratio > 2 ? Colors.red : ratio > 1 ? Colors.orange : Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('Ratio: ${ratio.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _PsUtilization {
  final PoliceStation ps;
  int total = 0;
  int available = 0;
  int deployed = 0;

  _PsUtilization({required this.ps});

  double get utilizationPercent => total > 0 ? (deployed / total) * 100 : 0.0;
}

class _PsUtilizationRow extends StatelessWidget {
  final _PsUtilization stats;

  const _PsUtilizationRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    final color = stats.utilizationPercent > 80
        ? Colors.red
        : stats.utilizationPercent > 50
            ? Colors.orange
            : Colors.green;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color,
            child: Text(stats.ps.name.substring(0, 1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(stats.ps.name, style: const TextStyle(fontWeight: FontWeight.w500))),
          Text('${stats.deployed}/${stats.total} (${stats.available} avail)', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(width: 12),
          Text('${stats.utilizationPercent.toStringAsFixed(0)}%', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _EscalationRow extends StatelessWidget {
  final ResourceRequest request;

  const _EscalationRow({required this.request});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.deepOrange,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(child: Text('L${request.escalationLevel}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.requestNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${request.resourceCategory.displayName} | ${request.raisingPoliceStationId} | ${request.priority.displayName}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Chip(
            label: Text(request.status.displayName, style: const TextStyle(fontSize: 10, color: Colors.white)),
            backgroundColor: request.status.color,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}