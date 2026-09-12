import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../applications/my_idols_screen.dart';
import '../login/login_screen.dart';
import '../../config/feature_flags.dart';
import '../../config/app_router.dart';
import '../../providers/resource_providers.dart';
import '../../models/resource_enums.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final String officerName;
  final String role;
  final String policeStation;
  final String sector;

  const DashboardScreen({
    super.key,
    required this.officerName,
    required this.role,
    required this.policeStation,
    required this.sector,
  });

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  UserRole get _userRole {
    switch (widget.role.toUpperCase()) {
      case 'SHO':
        return UserRole.sho;
      case 'CIRCLE INSPECTOR':
        return UserRole.circleInspector;
      case 'ACP':
        return UserRole.acp;
      case 'DCP':
        return UserRole.dcp;
      case 'CONTROL ROOM':
        return UserRole.controlRoom;
      case 'ADMIN':
        return UserRole.admin;
      default:
        return UserRole.fieldOfficer;
    }
  }

  bool get _canSeeResourceSharing {
    return FeatureFlags.enableResourceSharing && _userRole != UserRole.fieldOfficer;
  }

  bool get _canSeeCommandDashboard {
    return FeatureFlags.enableResourceSharing && _userRole.canViewCommandDashboard;
  }

  @override
  Widget build(BuildContext context) {
    final openRequestsAsync = ref.watch(activeRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ganesh Bandobust 2026',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_canSeeResourceSharing)
            openRequestsAsync.when(
              data: (requests) {
                final myRequests = requests.where((r) => r.raisingPoliceStationId == widget.policeStation).toList();
                if (myRequests.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Chip(
                      avatar: Icon(Icons.local_shipping, size: 16, color: Colors.white),
                      label: Text(
                        '${myRequests.length}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: Colors.red,
                      labelStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                );
              },
              loading: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
              error: (_, __) => const SizedBox.shrink(),
            ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.go('/login');
            },
          ),
        ],
      ),
      drawer: _canSeeResourceSharing ? _buildDrawer(context) : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Logged-in Officer',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.officerName,
                      style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(widget.role),
                    Text(widget.policeStation),
                    Text('Sector: ${widget.sector}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'My Work',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF17365D),
                  child: Icon(Icons.temple_hindu, color: Colors.white),
                ),
                title: const Text('My Idols / Applications', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('12 assigned applications'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/my-idols'),
              ),
            ),
            if (_canSeeResourceSharing) ...[
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF17365D),
                    child: Icon(Icons.local_shipping, color: Colors.white),
                  ),
                  title: const Text('Resource Requests', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: openRequestsAsync.when(
                    data: (requests) {
                      final myRequests = requests.where((r) => r.raisingPoliceStationId == widget.policeStation).toList();
                      return Text('${myRequests.length} active request${myRequests.length != 1 ? 's' : ''}');
                    },
                    loading: () => const Text('Loading...'),
                    error: (_, __) => const Text('Error loading requests'),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/resources/my-requests'),
                ),
              ),
            ],
            const SizedBox(height: 20),
            const Text(
              'Festival Stages',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const _StageTile(number: '1', title: 'Pre-Installation', status: 'ACTIVE', active: true),
            const _StageTile(number: '2', title: 'Installation', status: 'Not Started'),
            const _StageTile(number: '3', title: 'During Festivity', status: 'Not Started'),
            _StageTileWithResourceAccess(
              number: '4',
              title: 'Immersion (Nimarjan)',
              status: 'Not Started',
              canAccessResources: _canSeeResourceSharing,
              onResourceTap: () => context.push('/resources'),
            ),
            const _StageTile(number: '5', title: 'Post-Immersion', status: 'Not Started'),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF17365D)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.local_police, size: 48, color: Colors.white),
                const SizedBox(height: 12),
                Text(widget.officerName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(widget.role, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.temple_hindu),
            title: const Text('My Idols / Applications'),
            onTap: () {
              Navigator.pop(context);
              context.push('/my-idols');
            },
          ),
          if (FeatureFlags.enableResourceSharing) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.local_shipping),
              title: const Text('Resources'),
              onTap: () {
                Navigator.pop(context);
                context.push('/resources');
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('My Station Requests'),
              onTap: () {
                Navigator.pop(context);
                context.push('/resources/my-requests');
              },
            ),
            if (_canSeeCommandDashboard) ...[
              ListTile(
                leading: const Icon(Icons.analytics),
                title: const Text('Command Dashboard'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/resources/command-dashboard');
                },
              ),
            ],
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => context.go('/login'),
          ),
        ],
      ),
    );
  }
}

class _StageTile extends StatelessWidget {
  final String number;
  final String title;
  final String status;
  final bool active;

  const _StageTile({
    required this.number,
    required this.title,
    required this.status,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: active ? const Color(0xFF17365D) : const Color(0xFFE2E8F0),
          foregroundColor: active ? Colors.white : Colors.black54,
          child: Text(number),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(status),
        trailing: active ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.lock_outline),
      ),
    );
  }
}

class _StageTileWithResourceAccess extends StatelessWidget {
  final String number;
  final String title;
  final String status;
  final bool canAccessResources;
  final VoidCallback? onResourceTap;

  const _StageTileWithResourceAccess({
    required this.number,
    required this.title,
    required this.status,
    required this.canAccessResources,
    this.onResourceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFE2E8F0),
              foregroundColor: Colors.black54,
              child: Text(number),
            ),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(status),
            trailing: const Icon(Icons.lock_outline),
          ),
          if (canAccessResources)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.local_shipping, size: 18),
                      label: const Text('Resource Directory'),
                      onPressed: onResourceTap,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF17365D),
                        side: const BorderSide(color: Color(0xFF17365D)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('Raise Request'),
                      onPressed: () => context.push('/resources/request/new'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF17365D),
                        side: const BorderSide(color: Color(0xFF17365D)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}