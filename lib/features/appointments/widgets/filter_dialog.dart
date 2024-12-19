import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/appointment.dart';
import '../../services/models/business_service.dart';
import 'package:business_scheduler/features/services/providers/business_services_provider.dart';


class FilterDialog extends ConsumerStatefulWidget {
  final AppointmentStatus? status;
  final String? serviceId;
  final DateTimeRange? dateRange;
  final Function(AppointmentStatus?, String?, DateTimeRange?) onApply;

  const FilterDialog({
    this.status,
    this.serviceId,
    this.dateRange,
    required this.onApply,
    super.key,
  });

  @override
  ConsumerState<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends ConsumerState<FilterDialog> {
  late AppointmentStatus? _status;
  late String? _serviceId;
  late DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _status = widget.status;
    _serviceId = widget.serviceId;
    _dateRange = widget.dateRange;
  }

  Future<void> _selectDateRange() async {
    final initialDateRange = _dateRange ?? DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(const Duration(days: 7)),
    );

    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
      initialDateRange: initialDateRange,
    );

    if (pickedRange != null) {
      setState(() => _dateRange = pickedRange);
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsyncValue = ref.watch(businessServicesProvider);

    return AlertDialog(
      title: const Text('Filter Appointments'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<AppointmentStatus>(
            value: _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All Statuses'),
              ),
              ...AppointmentStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.toString().split('.').last),
                );
              }),
            ],
            onChanged: (value) => setState(() => _status = value),
          ),
          const SizedBox(height: 16),
          servicesAsyncValue.when(
            data: (services) => DropdownButtonFormField<String>(
              value: _serviceId,
              decoration: const InputDecoration(labelText: 'Service'),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Services'),
                ),
                ...services.map((service) {
                  return DropdownMenuItem(
                    value: service.id,
                    child: Text(service.name),
                  );
                }),
              ],
              onChanged: (value) => setState(() => _serviceId = value),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Text('Failed to load services'),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: Text(_dateRange == null
                ? 'Select Date Range'
                : '${_dateRange!.start.toString().split(' ')[0]} - ${_dateRange!.end.toString().split(' ')[0]}'),
            trailing: _dateRange == null
                ? const Icon(Icons.calendar_today)
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _dateRange = null),
                  ),
            onTap: _selectDateRange,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onApply(_status, _serviceId, _dateRange);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
} 