import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../providers/resource_providers.dart';
import '../../models/resource_models.dart';
import '../../models/resource_enums.dart';
import '../../config/feature_flags.dart';
import '../../data/police_stations.dart';
import '../../utils/distance.dart';

class ResourceDirectoryScreen extends ConsumerStatefulWidget {
  const ResourceDirectoryScreen({super.key});

  @override
  ConsumerState<ResourceDirectoryScreen> createState() => _ResourceDirectoryScreenState();
}

class _ResourceDirectoryScreenState extends ConsumerState<ResourceDirectoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ResourceCategory? _selectedCategory;
  ResourceStatus? _selectedStatus;
  Commissionerate? _selectedCommissionerate;
  ResourceCondition? _selectedCondition;
  double _searchRadiusKm = 15.0;
  String _searchQuery = '';
  bool _isMapView = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allResourcesAsync = ref.watch(allResourcesProvider);
    final currentLocationAsync = ref.watch(currentLocationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resource Directory'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'List'),
            Tab(icon: Icon(Icons.map), text: 'Map'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
            tooltip: 'Filters',
          ),
          IconButton(
            icon: Icon(_isMapView ? Icons.list : Icons.map),
            onPressed: () => setState(() => _isMapView = !_isMapView),
            tooltip: _isMapView ? 'List View' : 'Map View',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_hasActiveFilters) _buildActiveFiltersChips(),
          Expanded(
            child: allResourcesAsync.when(
              data: (resources) {
                final filtered = _applyFilters(resources);
                if (_isMapView) {
                  return _buildMapView(filtered, currentLocationAsync);
                }
                return _buildListView(filtered);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/resources/request/new'),
        icon: const Icon(Icons.add),
        label: const Text('Raise Request'),
        backgroundColor: const Color(0xFF17365D),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by asset code, name, or category...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  bool get _hasActiveFilters {
    return _selectedCategory != null ||
        _selectedStatus != null ||
        _selectedCommissionerate != null ||
        _selectedCondition != null;
  }

  Widget _buildActiveFiltersChips() {
    final chips = <Widget>[];
    if (_selectedCategory != null) {
      chips.add(_FilterChip(
        label: _selectedCategory!.displayName,
        onDeleted: () => setState(() => _selectedCategory = null),
      ));
    }
    if (_selectedStatus != null) {
      chips.add(_FilterChip(
        label: _selectedStatus!.displayName,
        color: _selectedStatus!.color,
        onDeleted: () => setState(() => _selectedStatus = null),
      ));
    }
    if (_selectedCommissionerate != null) {
      chips.add(_FilterChip(
        label: _selectedCommissionerate!.displayName,
        onDeleted: () => setState(() => _selectedCommissionerate = null),
      ));
    }
    if (_selectedCondition != null) {
      chips.add(_FilterChip(
        label: _selectedCondition!.displayName,
        color: _selectedCondition!.color,
        onDeleted: () => setState(() => _selectedCondition = null),
      ));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: chips.map((c) => Padding(padding: const EdgeInsets.only(right: 8), child: c)).toList()),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterBottomSheet(
        selectedCategory: _selectedCategory,
        selectedStatus: _selectedStatus,
        selectedCommissionerate: _selectedCommissionerate,
        selectedCondition: _selectedCondition,
        searchRadiusKm: _searchRadiusKm,
        onCategoryChanged: (v) => setState(() => _selectedCategory = v),
        onStatusChanged: (v) => setState(() => _selectedStatus = v),
        onCommissionerateChanged: (v) => setState(() => _selectedCommissionerate = v),
        onConditionChanged: (v) => setState(() => _selectedCondition = v),
        onRadiusChanged: (v) => setState(() => _searchRadiusKm = v),
        onClear: () => setState(() {
          _selectedCategory = null;
          _selectedStatus = null;
          _selectedCommissionerate = null;
          _selectedCondition = null;
          _searchRadiusKm = 15.0;
        }),
      ),
    );
  }

  List<ResourceItem> _applyFilters(List<ResourceItem> resources) {
    var filtered = resources.where((r) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!r.name.toLowerCase().contains(query) &&
            !r.assetCode.toLowerCase().contains(query) &&
            !r.category.displayName.toLowerCase().contains(query)) {
          return false;
        }
      }
      if (_selectedCategory != null && r.category != _selectedCategory) return false;
      if (_selectedStatus != null && r.status != _selectedStatus) return false;
      if (_selectedCondition != null && r.condition != _selectedCondition) return false;
      if (_selectedCommissionerate != null) {
        final ps = getPoliceStationById(r.currentHoldingPoliceStationId);
        if (ps == null || ps.commissionerate != _selectedCommissionerate) return false;
      }
      return true;
    }).toList();

    filtered.sort((a, b) {
      if (a.isAvailable != b.isAvailable) return b.isAvailable ? -1 : 1;
      return a.name.compareTo(b.name);
    });

    return filtered;
  }

  Widget _buildListView(List<ResourceItem> resources) {
    if (resources.isEmpty) {
      return const Center(child: Text('No resources found matching criteria'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final resource = resources[index];
        return _ResourceListTile(resource: resource);
      },
    );
  }

  Widget _buildMapView(List<ResourceItem> resources, AsyncValue<LatLng?> currentLocationAsync) {
    return currentLocationAsync.when(
      data: (currentLocation) {
        final center = currentLocation ?? const LatLng(17.3850, 78.4867);
        return Stack(
          children: [
            _StaticMapPlaceholder(
              center: center,
              resources: resources,
              onResourceTap: (resource) => context.push('/resources/${resource.id}'),
            ),
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${resources.length} resources shown', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ResourceCategory.values.map((cat) {
                          final count = resources.where((r) => r.category == cat).length;
                          if (count == 0) return const SizedBox.shrink();
                          return Chip(
                            avatar: Icon(cat.icon, size: 16),
                            label: Text('$cat ($count)'),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading map: $e')),
    );
  }
}

class _ResourceListTile extends StatelessWidget {
  final ResourceItem resource;

  const _ResourceListTile({required this.resource});

  @override
  Widget build(BuildContext context) {
    final ps = getPoliceStationById(resource.currentHoldingPoliceStationId);
    final distance = ps != null && resource.currentLocation != null
        ? calculateDistance(ps.location.latitude, ps.location.longitude, resource.currentLocation!.latitude, resource.currentLocation!.longitude)
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: resource.category.icon == Icons.category ? Colors.grey : const Color(0xFF17365D),
          child: Icon(resource.category.icon, color: Colors.white),
        ),
        title: Text(resource.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Category: ${resource.category.displayName}'),
            Text('Holding PS: ${ps?.name ?? resource.currentHoldingPoliceStationId}'),
            Text('Available: ${resource.quantityAvailable} / ${resource.quantityTotal}'),
            if (distance != null) Text('Distance: ${distance.toStringAsFixed(1)} km'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Chip(
              label: Text(resource.status.displayName, style: const TextStyle(fontSize: 10, color: Colors.white)),
              backgroundColor: resource.status.color,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(height: 4),
            Chip(
              label: Text(resource.condition.displayName, style: const TextStyle(fontSize: 10, color: Colors.white)),
              backgroundColor: resource.condition.color,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        onTap: () => context.push('/resources/${resource.id}'),
      ),
    );
  }
}

class _FilterBottomSheet extends StatelessWidget {
  final ResourceCategory? selectedCategory;
  final ResourceStatus? selectedStatus;
  final Commissionerate? selectedCommissionerate;
  final ResourceCondition? selectedCondition;
  final double searchRadiusKm;
  final ValueChanged<ResourceCategory?> onCategoryChanged;
  final ValueChanged<ResourceStatus?> onStatusChanged;
  final ValueChanged<Commissionerate?> onCommissionerateChanged;
  final ValueChanged<ResourceCondition?> onConditionChanged;
  final ValueChanged<double> onRadiusChanged;
  final VoidCallback onClear;

  const _FilterBottomSheet({
    required this.selectedCategory,
    required this.selectedStatus,
    required this.selectedCommissionerate,
    required this.selectedCondition,
    required this.searchRadiusKm,
    required this.onCategoryChanged,
    required this.onStatusChanged,
    required this.onCommissionerateChanged,
    required this.onConditionChanged,
    required this.onRadiusChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: onClear, child: const Text('Clear All')),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildSection('Category', ResourceCategory.values.map((c) => _FilterOption(
                      label: c.displayName,
                      icon: c.icon,
                      selected: selectedCategory == c,
                      onTap: () => onCategoryChanged(c),
                    )).toList()),
                    _buildSection('Status', ResourceStatus.values.map((s) => _FilterOption(
                      label: s.displayName,
                      selected: selectedStatus == s,
                      color: s.color,
                      onTap: () => onStatusChanged(s),
                    )).toList()),
                    _buildSection('Condition', ResourceCondition.values.map((c) => _FilterOption(
                      label: c.displayName,
                      selected: selectedCondition == c,
                      color: c.color,
                      onTap: () => onConditionChanged(c),
                    )).toList()),
                    _buildSection('Commissionerate', Commissionerate.values.map((c) => _FilterOption(
                      label: c.displayName,
                      selected: selectedCommissionerate == c,
                      onTap: () => onCommissionerateChanged(c),
                    )).toList()),
                    const SizedBox(height: 16),
                    Text('Search Radius: ${searchRadiusKm.toInt()} km', style: const TextStyle(fontWeight: FontWeight.w500)),
                    Slider(
                      value: searchRadiusKm,
                      min: 5,
                      max: 50,
                      divisions: 9,
                      label: '${searchRadiusKm.toInt()} km',
                      onChanged: onRadiusChanged,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, List<Widget> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: options),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _FilterOption extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterOption({
    required this.label,
    this.icon,
    required this.selected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      avatar: icon != null ? Icon(icon, size: 16, color: selected ? Colors.white : color) : null,
      label: Text(label),
      selected: selected,
      selectedColor: color ?? const Color(0xFF17365D),
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
      onSelected: (_) => onTap(),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final Color? color;
  final VoidCallback onDeleted;

  const _FilterChip({
    required this.label,
    this.color,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: color?.withOpacity(0.2) ?? const Color(0xFF17365D).withOpacity(0.2),
      labelStyle: TextStyle(color: color ?? const Color(0xFF17365D), fontWeight: FontWeight.w500),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onDeleted,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _StaticMapPlaceholder extends StatelessWidget {
  final LatLng center;
  final List<ResourceItem> resources;
  final Function(ResourceItem) onResourceTap;

  const _StaticMapPlaceholder({
    required this.center,
    required this.resources,
    required this.onResourceTap,
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
                Text('Map View (MapmyIndia Integration)', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                const SizedBox(height: 8),
                Text('Center: ${center.latitude.toStringAsFixed(4)}, ${center.longitude.toStringAsFixed(4)}', style: TextStyle(color: Colors.grey[500])),
                const SizedBox(height: 16),
                Text('${resources.length} resource pins would be shown here', style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          ),
          ...resources.where((r) => r.currentLocation != null).map((resource) {
            final offset = _calculateOffset(center, resource.currentLocation!);
            return Positioned(
              left: offset.dx,
              top: offset.dy,
              child: GestureDetector(
                onTap: () => onResourceTap(resource),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: resource.status.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  child: Icon(resource.category.icon, size: 16, color: Colors.white),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Offset _calculateOffset(LatLng center, LatLng point) {
    const double degreesPerPixel = 0.001;
    final dx = ((point.longitude - center.longitude) / degreesPerPixel) + 200;
    final dy = 200 - ((point.latitude - center.latitude) / degreesPerPixel);
    return Offset(dx.clamp(20.0, 380.0), dy.clamp(20.0, 380.0));
  }
}