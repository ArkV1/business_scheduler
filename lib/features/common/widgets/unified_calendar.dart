import 'package:business_scheduler/core/widgets/error_message.dart';
import 'package:business_scheduler/features/appointments/models/appointment.dart';
import 'package:business_scheduler/features/appointments/providers/appointment_availability_provider.dart';
import 'package:business_scheduler/features/appointments/providers/appointment_data_provider.dart';
import 'package:business_scheduler/features/appointments/providers/appointment_state_provider.dart';
import 'package:business_scheduler/features/auth/providers/user_provider.dart';
import 'package:business_scheduler/features/home/models/opening_hours.dart';
import 'package:business_scheduler/features/home/providers/opening_hours_provider.dart';
import 'package:business_scheduler/features/home/widgets/calendar/calendar_providers.dart';
import 'package:business_scheduler/features/home/widgets/time_slot_picker/time_slot_picker.dart';
import 'package:business_scheduler/features/services/providers/business_services_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'calendar/calendar_header.dart';
import 'calendar/calendar_legend.dart';
import 'calendar/calendar_month_view.dart';
import 'calendar/calendar_week_view.dart';
import 'calendar/calendar_types.dart';

class UnifiedCalendar extends ConsumerWidget {
  final String id;
  final bool isAdmin;
  final bool showTimeSlotPicker;
  final Function(DateTime)? onDateSelected;
  final int maxAppointmentsPerDay;
  
  const UnifiedCalendar({
    super.key,
    required this.id,
    this.isAdmin = false,
    this.showTimeSlotPicker = true,
    this.onDateSelected,
    this.maxAppointmentsPerDay = 8,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewType = ref.watch(calendarViewTypeProvider(id));
    final currentDate = ref.watch(currentMonthProvider(id));
    final selectedDate = ref.watch(selectedDateProvider(id));

    final openingHours = ref.watch(openingHoursStreamProvider);
    final appointmentsStream = isAdmin ? ref.watch(dateAppointmentsProvider(currentDate)) : null;
    final availableTimeSlots = ref.watch(availableTimeSlotsProvider(currentDate));

    // Universal date selection handler
    void handleDateSelection(DateTime date, bool isBusinessOpen) {
      // For admin view, always update the date regardless of business hours
      if (isAdmin) {
        // Update the selected date
        ref.read(selectedDateProvider(id).notifier).state = date;
        // Update the current month if the selected date is in a different month
        if (date.month != currentDate.month || date.year != currentDate.year) {
          ref.read(currentMonthProvider(id).notifier).state = DateTime(date.year, date.month);
        }
        onDateSelected?.call(date);
      } 
      // For regular users, only allow selection on open business days
      else if (isBusinessOpen) {
        ref.read(selectedDateProvider(id).notifier).state = date;
        if (showTimeSlotPicker) {
          _showTimeSlotDialog(context, date);
        }
        onDateSelected?.call(date);
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header with controls
        CalendarHeader(
          id: id,
          currentDate: currentDate,
          viewType: viewType,
          isAdmin: isAdmin,
          onViewTypeChanged: (value) {
            ref.read(calendarViewTypeProvider(id).notifier).state = value;
          },
          onNavigateMonth: (monthDelta) {
            ref.read(currentMonthProvider(id).notifier).state = DateTime(
              currentDate.year,
              currentDate.month + monthDelta,
            );
          },
        ),

        // Calendar grid with animation
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: viewType == CalendarViewType.week ? 80 : 220,
          child: Row(
            children: [
              _buildNavigationButton(
                context,
                Icons.chevron_left,
                () => _navigateMonth(ref, currentDate, -1),
              ),
              Expanded(
                child: isAdmin
                    ? _buildAdminCalendarContent(
                        context,
                        ref,
                        viewType,
                        currentDate,
                        selectedDate,
                        appointmentsStream,
                        availableTimeSlots,
                        handleDateSelection,
                      )
                    : _buildUserCalendarContent(
                        context,
                        ref,
                        viewType,
                        currentDate,
                        selectedDate,
                        openingHours,
                        availableTimeSlots,
                        handleDateSelection,
                      ),
              ),
              _buildNavigationButton(
                context,
                Icons.chevron_right,
                () => _navigateMonth(ref, currentDate, 1),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),
        CalendarLegend(isAdmin: isAdmin),
      ],
    );
  }

  Widget _buildNavigationButton(BuildContext context, IconData icon, VoidCallback onPressed) {
    return Container(
      width: 24,
      alignment: Alignment.center,
      child: IconButton(
        icon: Icon(
          icon,
          size: 24,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        onPressed: onPressed,
        splashRadius: 20,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _buildAdminCalendarContent(
    BuildContext context,
    WidgetRef ref,
    CalendarViewType viewType,
    DateTime currentDate,
    DateTime? selectedDate,
    AsyncValue<List<Appointment>>? appointmentsStream,
    AsyncValue<List<String>> availableTimeSlots,
    void Function(DateTime date, bool isBusinessOpen) onDateSelected,
  ) {
    final openingHours = ref.watch(openingHoursStreamProvider);
    
    print('UnifiedCalendar Admin Content Debug:');
    print('View Type: $viewType');
    print('Current Date: $currentDate');
    print('Selected Date: $selectedDate');
    
    return appointmentsStream?.when(
      data: (appointments) {
        return openingHours.when(
          data: (hours) => viewType == CalendarViewType.week
              ? CalendarWeekView(
                  isAdmin: true,
                  selectedDate: selectedDate,
                  baseDate: currentDate,
                  appointments: appointments,
                  openingHours: hours,
                  onDateSelected: onDateSelected,
                  maxAppointmentsPerDay: maxAppointmentsPerDay,
                )
              : CalendarMonthView(
                  isAdmin: true,
                  selectedDate: selectedDate,
                  baseDate: currentDate,
                  appointments: appointments,
                  openingHours: hours,
                  onDateSelected: onDateSelected,
                  maxAppointmentsPerDay: maxAppointmentsPerDay,
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error loading opening hours')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    ) ?? const Center(child: CircularProgressIndicator());
  }

  Widget _buildUserCalendarContent(
    BuildContext context,
    WidgetRef ref,
    CalendarViewType viewType,
    DateTime currentDate,
    DateTime? selectedDate,
    AsyncValue<List<OpeningHours>>? openingHours,
    AsyncValue<List<String>> availableTimeSlots,
    void Function(DateTime date, bool isBusinessOpen) onDateSelected,
  ) {
    return openingHours?.when(
      data: (hours) {
        return viewType == CalendarViewType.week
            ? CalendarWeekView(
                isAdmin: false,
                selectedDate: selectedDate,
                baseDate: currentDate,
                openingHours: hours,
                onDateSelected: onDateSelected,
              )
            : CalendarMonthView(
                isAdmin: false,
                selectedDate: selectedDate,
                baseDate: currentDate,
                openingHours: hours,
                onDateSelected: onDateSelected,
              );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    ) ?? const Center(child: CircularProgressIndicator());
  }

  void _navigateMonth(WidgetRef ref, DateTime currentDate, int monthDelta) {
    print('UnifiedCalendar Navigation Debug:');
    print('Current Date Before: $currentDate');
    
    final viewType = ref.read(calendarViewTypeProvider(id));
    DateTime newDate;
    
    if (viewType == CalendarViewType.week) {
      // For week view, navigate by 7 days
      newDate = currentDate.add(Duration(days: 7 * monthDelta));
    } else {
      // For month view, navigate by months
      newDate = DateTime(
        currentDate.year,
        currentDate.month + monthDelta,
      );
    }
    
    print('New Date After: $newDate');
    print('Navigation Type: ${viewType == CalendarViewType.week ? "Week" : "Month"}');
    ref.read(currentMonthProvider(id).notifier).state = newDate;
  }
}

void _showTimeSlotDialog(BuildContext context, DateTime date) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => Consumer(
      builder: (context, ref, child) {
        final timeSlots = ref.watch(availableTimeSlotsProvider(date));
        final user = ref.watch(userProvider).value;
        
        return timeSlots.when(
          data: (slots) => TimeSlotPicker(
            services: ref.watch(businessServicesProvider).value ?? [],
            timeSlots: slots,
            selectedDate: date,
            onConfirm: () async {
              final selectedService = ref.read(selectedServiceProvider);
              final selectedTimeSlot = ref.read(selectedTimeSlotProvider);
              
              if (user == null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.pleaseSignInToBook))
                  );
                }
                return;
              }
              
              if (selectedService == null || selectedTimeSlot == null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.pleaseSelectServiceAndTime))
                  );
                }
                return;
              }
              
              try {
                final appointmentService = ref.read(appointmentServiceProvider);
                await appointmentService.createAppointment(
                  userId: user.id,
                  date: date,
                  timeSlot: selectedTimeSlot,
                  service: selectedService,
                );
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.appointmentCreatedSuccessfully))
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${AppLocalizations.of(context)!.errorCreatingAppointment}: $e'))
                  );
                }
              }
            },
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => ErrorMessage(error.toString()),
        );
      },
    ),
  );
}