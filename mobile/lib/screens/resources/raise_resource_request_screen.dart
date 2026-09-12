import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../../providers/resource_providers.dart';
import '../../models/resource_models.dart';
import '../../models/resource_enums.dart';
import '../../config/feature_flags.dart';
import '../../data/police_stations.dart';
import '../applications/my_idols_screen.dart';

class RaiseResourceRequestScreen extends ConsumerStatefulWidget {
  const RaiseResourceRequestScreen({super.key});

  @override
  ConsumerState<RaiseResourceRequestScreen> createState() => _RaiseResourceRequestScreenState();
}

class _RaiseResourceRequestScreenState extends ConsumerState<RaiseResourceRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _siteAddressController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  ResourceCategory _selectedCategory = ResourceCategory.crane;
  int _quantity = 1;
  RequestPriority _priority = RequestPriority.normal;
  DateTime _requiredAt = DateTime.now().add(const Duration(hours: 1));
  DateTime _requiredUntil = DateTime.now().add(const Duration(hours: 4));
  LatLng? _siteLocation;
  String? _selectedApplicationId;
  String _mandalName = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _contactNameController.text = 'Field Officer Demo';
    _contactPhoneController.text = '94906-XXXXX';
    _siteLocation = const LatLng(17.3850, 78.4867); // Default to Hyderabad center
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _siteAddressController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Raise Resource Request'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text('Submit', style: TextStyle(color: Colors.white)),
            onPressed: _isLoading ? null : _submitRequest,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Resource Details'),
              const SizedBox(height: 12),
              _buildCategoryDropdown(),
              const SizedBox(height: 16),
              _buildQuantityField(),
              const SizedBox(height: 16),
              _buildPrioritySelector(),
              const SizedBox(height: 24),
              _buildSectionHeader('Timing'),
              const SizedBox(height: 12),
              _buildDateTimePickers(),
              const SizedBox(height: 24),
              _buildSectionHeader('Site Location'),
              const SizedBox(height: 12),
              _buildLocationFields(),
              const SizedBox(height: 24),
              _buildSectionHeader('Application Link (Optional)'),
              const SizedBox(height: 12),
              _buildApplicationPicker(),
              const SizedBox(height: 24),
              _buildSectionHeader('Contact & Reason'),
              const SizedBox(height: 12),
              _buildContactFields(),
              const SizedBox(height: 16),
              _buildReasonField(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF17365D)));
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<ResourceCategory>(
      value: _selectedCategory,
      decoration: _inputDecoration('Resource Category', Icons.category),
      items: ResourceCategory.values.map((cat) {
        return DropdownMenuItem(
          value: cat,
          child: Row(
            children: [
              Icon(cat.icon, size: 20, color: const Color(0xFF17365D)),
              const SizedBox(width: 12),
              Text(cat.displayName),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedCategory = value!),
      validator: (value) => value == null ? 'Please select a category' : null,
    );
  }

  Widget _buildQuantityField() {
    return TextFormField(
      initialValue: _quantity.toString(),
      decoration: _inputDecoration('Quantity', Icons.numbers),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        final qty = int.tryParse(value);
        if (qty == null || qty < 1) return 'Must be at least 1';
        return null;
      },
      onSaved: (value) => _quantity = int.parse(value!),
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Priority', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: RequestPriority.values.map((priority) {
            final isSelected = _priority == priority;
            return FilterChip(
              avatar: Icon(_getPriorityIcon(priority), size: 18, color: isSelected ? Colors.white : priority.color),
              label: Text(priority.displayName),
              selected: isSelected,
              selectedColor: priority.color,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
              onSelected: (_) => setState(() => _priority = priority),
              showCheckmark: false,
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          _getPriorityDescription(_priority),
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  IconData _getPriorityIcon(RequestPriority priority) {
    switch (priority) {
      case RequestPriority.normal: return Icons.flag;
      case RequestPriority.urgent: return Icons.priority_high;
      case RequestPriority.emergency: return Icons.emergency;
    }
  }

  String _getPriorityDescription(RequestPriority priority) {
    switch (priority) {
      case RequestPriority.normal: return 'Standard response within 60 minutes';
      case RequestPriority.urgent: return 'Expedited response within 20 minutes';
      case RequestPriority.emergency: return 'Immediate response - notifies SHO & superior simultaneously';
    }
  }

  Widget _buildDateTimePickers() {
    return Row(
      children: [
        Expanded(
          child: _DateTimePickerField(
            label: 'Required From',
            value: _requiredAt,
            onTap: () => _pickDateTime(isFrom: true),
            firstDate: DateTime.now(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _DateTimePickerField(
            label: 'Required Until',
            value: _requiredUntil,
            onTap: () => _pickDateTime(isFrom: false),
            firstDate: _requiredAt,
          ),
        ),
      ],
    );
  }

  Future<void> _pickDateTime({required bool isFrom}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isFrom ? _requiredAt : _requiredUntil,
      firstDate: isFrom ? DateTime.now() : _requiredAt,
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isFrom ? _requiredAt : _requiredUntil),
    );
    if (time == null) return;

    final newDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isFrom) {
        _requiredAt = newDateTime;
        if (_requiredUntil.isBefore(_requiredAt)) {
          _requiredUntil = _requiredAt.add(const Duration(hours: 2));
        }
      } else {
        _requiredUntil = newDateTime;
      }
    });
  }

  Widget _buildLocationFields() {
    return Column(
      children: [
        TextFormField(
          controller: _siteAddressController,
          decoration: _inputDecoration('Site Address', Icons.location_on),
          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.my_location),
                label: const Text('Use Current GPS'),
                onPressed: _useCurrentLocation,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.map),
                label: const Text('Pick on Map'),
                onPressed: _pickOnMap,
              ),
            ),
          ],
        ),
        if (_siteLocation != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.gps_fixed, color: Color(0xFF17365D)),
                const SizedBox(width: 12),
                Text('Lat: ${_siteLocation!.latitude.toStringAsFixed(6)}, Lng: ${_siteLocation!.longitude.toStringAsFixed(6)}'),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _useCurrentLocation() {
    setState(() {
      _siteLocation = const LatLng(17.3850, 78.4867);
      _siteAddressController.text = 'Current GPS Location';
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('GPS location set')));
  }

  void _pickOnMap() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Map picker coming soon - using default location')));
  }

  Widget _buildApplicationPicker() {
    final applications = [
      {'id': 'GH2026-0001', 'organizer': 'Sri Ganesh Youth Association', 'location': 'Main Road, Hyderabad', 'mandal': 'Secunderabad'},
      {'id': 'GH2026-0002', 'organizer': 'Sri Balaji Youth Association', 'location': 'Temple Road, Hyderabad', 'mandal': 'Khairatabad'},
      {'id': 'GH2026-0003', 'organizer': 'Friends Ganesh Association', 'location': 'Market Road, Hyderabad', 'mandal': 'Nampally'},
    ];

    return DropdownButtonFormField<String>(
      value: _selectedApplicationId,
      decoration: _inputDecoration('Link to Idol Application', Icons.link),
      hint: const Text('Select an application (optional)'),
      items: [
        const DropdownMenuItem(value: null, child: Text('None')),
        ...applications.map((app) => DropdownMenuItem(
          value: app['id'],
          child: Text('${app['id']} - ${app['organizer']}'),
        )),
      ],
      onChanged: (value) {
        setState(() {
          _selectedApplicationId = value;
          if (value != null) {
            final app = applications.firstWhere((a) => a['id'] == value);
            _mandalName = app['mandal']!;
            _siteAddressController.text = app['location']!;
          } else {
            _mandalName = '';
          }
        });
      },
    );
  }

  Widget _buildContactFields() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _contactNameController,
            decoration: _inputDecoration('Contact Name', Icons.person),
            validator: (value) => value == null || value.isEmpty ? 'Required' : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: _contactPhoneController,
            decoration: _inputDecoration('Contact Phone', Icons.phone),
            keyboardType: TextInputType.phone,
            validator: (value) => value == null || value.isEmpty ? 'Required' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildReasonField() {
    return TextFormField(
      controller: _reasonController,
      decoration: _inputDecoration('Reason for Request', Icons.description).copyWith(
        hintText: 'Explain why this resource is needed...',
      ),
      maxLines: 3,
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: _isLoading ? null : _submitRequest,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF17365D),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Submit Request', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF17365D)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      final request = ResourceRequest(
        id: 'REQ-${DateTime.now().millisecondsSinceEpoch}',
        requestNumber: 'PS-${DateTime.now().year}-${(DateTime.now().millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}',
        raisedByUserId: 'USER-DEMO-001',
        raisingPoliceStationId: 'HYD-PS-001',
        applicationId: _selectedApplicationId,
        mandalName: _mandalName,
        resourceCategory: _selectedCategory,
        quantityRequested: _quantity,
        priority: _priority,
        requiredAt: _requiredAt,
        requiredUntil: _requiredUntil,
        siteLocation: _siteLocation ?? const LatLng(17.3850, 78.4867),
        siteAddress: _siteAddressController.text,
        contactName: _contactNameController.text,
        contactPhone: _contactPhoneController.text,
        reason: _reasonController.text,
        status: RequestStatus.open,
        escalationLevel: 0,
        slaDueAt: _calculateSlaDueAt(_requiredAt, _priority),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final repo = ref.read(resourceRequestRepositoryProvider);
      await repo.createRequest(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request ${request.requestNumber} submitted successfully!'), backgroundColor: Colors.green),
        );
        context.push('/resources/request/${request.id}/matching');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  DateTime _calculateSlaDueAt(DateTime requiredAt, RequestPriority priority) {
    final minutes = switch (priority) {
      RequestPriority.normal => 60,
      RequestPriority.urgent => 20,
      RequestPriority.emergency => 0,
    };
    return requiredAt.add(Duration(minutes: minutes));
  }
}

class _DateTimePickerField extends StatelessWidget {
  final String label;
  final DateTime value;
  final VoidCallback onTap;
  final DateTime firstDate;

  const _DateTimePickerField({
    required this.label,
    required this.value,
    required this.onTap,
    required this.firstDate,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF17365D)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        child: Text(
          DateFormat('dd MMM, hh:mm a').format(value),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}