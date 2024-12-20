import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/appointment.dart';
import '../providers/appointment_data_provider.dart';
import '../../services/models/business_service.dart';
import 'package:business_scheduler/features/services/providers/business_services_provider.dart';

class AppointmentEditDialog extends ConsumerStatefulWidget {
  final Appointment appointment;

  const AppointmentEditDialog({
    required this.appointment,
    super.key,
  });

  @override
  ConsumerState<AppointmentEditDialog> createState() => _AppointmentEditDialogState();
}

class _AppointmentEditDialogState extends ConsumerState<AppointmentEditDialog> {
  late AppointmentStatus _status;
  late BusinessService _selectedService;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _status = widget.appointment.status;
    _selectedService = ref.read(businessServicesProvider).value?.firstWhere((service) => service.id == widget.appointment.serviceId) ?? BusinessService(id: widget.appointment.serviceId, name: 'Unknown Service', nameHe: 'שירות לא ידוע', durationMinutes: 0, price: 0, isActive: false, category: 'unknown');
    _noteController.text = widget.appointment.notes ?? '';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _updateAppointment() {
    ref.read(appointmentUpdateProvider((
      appointmentId: widget.appointment.id,
      date: widget.appointment.date,
      timeSlot: widget.appointment.timeSlot,
      service: _selectedService,
      status: _status,
      notes: _noteController.text.isEmpty ? null : _noteController.text,
    )));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsyncValue = ref.watch(businessServicesProvider);

    return AlertDialog(
      title: const Text('Edit Appointment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<AppointmentStatus>(
            value: _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: AppointmentStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status.toString().split('.').last),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _status = value);
              }
            },
          ),
          const SizedBox(height: 16),
          servicesAsyncValue.when(
            data: (services) => DropdownButtonFormField<BusinessService>(
              value: _selectedService,
              decoration: const InputDecoration(labelText: 'Service'),
              items: services.map((service) {
                return DropdownMenuItem(
                  value: service,
                  child: Text(service.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedService = value);
                }
              },
            ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Text('Failed to load services'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Notes',
              hintText: 'Add any additional notes here',
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _updateAppointment,
          child: const Text('Save'),
        ),
      ],
    );
  }
} 