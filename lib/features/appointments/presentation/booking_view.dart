import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../providers/appointment_availability_provider.dart';
import '../providers/appointment_data_provider.dart';
import '../providers/appointment_state_provider.dart';
import '../../auth/providers/user_provider.dart';
import '../../home/providers/opening_hours_provider.dart';
import '../../home/widgets/calendar/calendar.dart';
import '../../home/widgets/time_slot_picker/time_slot_picker.dart';
import '../../services/providers/business_services_provider.dart';

import 'package:appointment_app/features/home/widgets/calendar/calendar_providers.dart';
import 'package:appointment_app/features/settings/providers/app_settings_provider.dart';


class BookingView extends ConsumerStatefulWidget {
  const BookingView({super.key});

  @override
  ConsumerState<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends ConsumerState<BookingView> {
  @override
  void initState() {
    super.initState();
    // Initialize with next available date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectNextAvailableDate();
    });
  }

  void _selectNextAvailableDate() {
    final openingHours = ref.read(openingHoursStreamProvider).value;
    if (openingHours == null) return;

    // Start with today at midnight
    final now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);
    bool foundAvailable = false;

    print('🔍 Starting search from: $date');

    // Look for the next 30 days maximum
    for (int i = 0; i < 30; i++) {
      final dayOfWeek = date.weekday;
      final isOpen = openingHours.any((hour) {
        final hourWeekday = _getWeekdayFromName(hour.dayOfWeek);
        return hourWeekday == dayOfWeek && !hour.isClosed;
      });

      print('📅 Checking date: $date (${_getWeekdayName(date.weekday)}) - isOpen: $isOpen');

      if (isOpen) {
        foundAvailable = true;
        break;
      }
      date = DateTime(date.year, date.month, date.day + 1); // Add one day while keeping midnight
    }

    if (foundAvailable) {
      print('✅ Found available date: $date (${_getWeekdayName(date.weekday)})');
      
      // Get today's date at midnight for consistent calculations
      final today = DateTime(now.year, now.month, now.day);
      
      // Find the start of the current week (Sunday)
      final currentWeekStart = today.subtract(Duration(days: today.weekday % 7));
      
      // Find the start of the target week (Sunday)
      final targetWeekStart = date.subtract(Duration(days: date.weekday % 7));
      
      // Calculate the week difference
      final weekOffset = targetWeekStart.difference(currentWeekStart).inDays ~/ 7;

      print('📊 Week calculation:');
      print('  • Today: $today');
      print('  • Current week start: $currentWeekStart');
      print('  • Target week start: $targetWeekStart');
      print('  • Week offset: $weekOffset');
      
      // Update the calendar state
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // First set the week offset
        ref.read(weekOffsetProvider('booking_calendar').notifier).state = weekOffset;
        
        // Then update the current month and selected date
        ref.read(currentMonthProvider('booking_calendar').notifier).state = date;
        ref.read(selectedDateProvider('booking_calendar').notifier).state = date;
      });

      print('📅 Calendar state updated:');
      print('  • Week offset: $weekOffset');
      print('  • Selected date: $date');
    } else {
      print('❌ No available dates found in the next 30 days');
    }
  }

  int _getWeekdayFromName(String dayName) {
    switch (dayName.toLowerCase()) {
      case 'sunday': return DateTime.sunday;
      case 'monday': return DateTime.monday;
      case 'tuesday': return DateTime.tuesday;
      case 'wednesday': return DateTime.wednesday;
      case 'thursday': return DateTime.thursday;
      case 'friday': return DateTime.friday;
      case 'saturday': return DateTime.saturday;
      default: return -1;
    }
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case DateTime.monday: return 'Monday';
      case DateTime.tuesday: return 'Tuesday';
      case DateTime.wednesday: return 'Wednesday';
      case DateTime.thursday: return 'Thursday';
      case DateTime.friday: return 'Friday';
      case DateTime.saturday: return 'Saturday';
      case DateTime.sunday: return 'Sunday';
      default: return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedDate = ref.watch(selectedDateProvider('booking_calendar'));
    final timeSlots = ref.watch(availableTimeSlotsProvider(selectedDate ?? DateTime.now()));
    final services = ref.watch(businessServicesProvider).value ?? [];
    final weekOffset = ref.watch(weekOffsetProvider('booking_calendar'));
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bookAppointment),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.selectDateAndTime,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.bookingInstructions,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Calendar(
            showTimeSlotPicker: false,
            initialOffset: weekOffset,
            initialDate: selectedDate,
            id: 'booking_calendar',
          ),
          const SizedBox(height: 16),
          // Time Slot Picker Section
          if (selectedDate != null)
            Expanded(
              child: timeSlots.when(
                data: (slots) => TimeSlotPicker(
                  services: services,
                  timeSlots: slots,
                  selectedDate: selectedDate,
                  onConfirm: () async {
                    final selectedService = ref.read(selectedServiceProvider);
                    final selectedTimeSlot = ref.read(selectedTimeSlotProvider);
                    final user = ref.read(userProvider).value;
                    
                    if (user == null) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.pleaseSignInToBook))
                        );
                      }
                      return;
                    }
                    
                    if (selectedService == null || selectedTimeSlot == null) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.pleaseSelectServiceAndTime))
                        );
                      }
                      return;
                    }
                    
                    try {
                      final appointmentService = ref.read(appointmentServiceProvider);
                      await appointmentService.createAppointment(
                        userId: user.id,
                        date: selectedDate,
                        timeSlot: selectedTimeSlot,
                        service: selectedService,
                      );
                      
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.appointmentCreatedSuccessfully))
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${l10n.errorCreatingAppointment}: $e'))
                        );
                      }
                    }
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
        ],
      ),
    );
  }
}