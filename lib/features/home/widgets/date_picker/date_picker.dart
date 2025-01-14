// date_picker.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../time_slot_picker/time_slot_picker.dart';
import 'package:business_scheduler/features/services/providers/business_services_provider.dart';
import 'package:business_scheduler/features/services/models/business_service.dart';
import 'package:business_scheduler/features/appointments/providers/appointment_state_provider.dart';
import 'package:business_scheduler/features/appointments/providers/appointment_availability_provider.dart';
import 'package:business_scheduler/features/home/widgets/calendar/calendar_providers.dart';

class DatePicker extends ConsumerWidget {
  final String id;
  
  const DatePicker({
    super.key,
    this.id = 'date_picker',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider(id));
    final l10n = AppLocalizations.of(context)!;
    final next7Days = List.generate(
      7,
      (index) => DateTime.now().add(Duration(days: index)),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: next7Days.map((date) {
          final isSelected = selectedDate != null &&
              date.day == selectedDate.day &&
              date.month == selectedDate.month &&
              date.year == selectedDate.year;
          final hasAvailability = date.weekday != DateTime.sunday;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: hasAvailability 
                  ? () {
                      ref.read(selectedDateProvider(id).notifier).state = date;
                      _showTimeSlotDialog(context, ref, date);
                    }
                  : null,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : !hasAvailability
                            ? Colors.grey.withOpacity(0.1)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : !hasAvailability
                              ? Colors.grey
                              : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatWeekday(context, date),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : !hasAvailability
                                  ? Colors.grey
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date.day.toString(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : !hasAvailability
                                  ? Colors.grey
                                  : null,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasAvailability ? l10n.openingHoursOpen : l10n.openingHoursClosed,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: hasAvailability
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showTimeSlotDialog(BuildContext context, WidgetRef ref, DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        final services = ref.watch(businessServicesProvider);
        final timeSlots = ref.watch(availableTimeSlotsProvider(date));
        
        return services.when(
          data: (servicesList) => timeSlots.when(
            data: (slots) => TimeSlotPicker(
              services: servicesList,
              timeSlots: slots,
              selectedDate: date,
              onConfirm: () {
                Navigator.pop(context);
              },
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => Center(
              child: Text('Error loading time slots: $error'),
            ),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Text('Error loading services: $error'),
          ),
        );
      },
    );
  }

  String _formatWeekday(BuildContext context, DateTime date) {
    return DateFormat('E').format(date).toUpperCase();
  }
}