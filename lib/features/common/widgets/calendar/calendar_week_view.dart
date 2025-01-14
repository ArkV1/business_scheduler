import 'package:business_scheduler/features/appointments/models/appointment.dart';
import 'package:business_scheduler/features/home/models/opening_hours.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class CalendarWeekView extends StatelessWidget {
  final bool isAdmin;
  final DateTime? selectedDate;
  final DateTime baseDate;
  final List<Appointment>? appointments;
  final List<OpeningHours>? openingHours;
  final Function(DateTime date, bool isBusinessOpen) onDateSelected;
  final int maxAppointmentsPerDay;

  const CalendarWeekView({
    super.key,
    required this.isAdmin,
    this.selectedDate,
    required this.baseDate,
    this.appointments,
    this.openingHours,
    required this.onDateSelected,
    this.maxAppointmentsPerDay = 8,
  });

  @override
  Widget build(BuildContext context) {
    // Get the start of the week (Sunday) for the current base date
    // First, normalize the base date to remove time components
    final normalizedDate = DateTime(baseDate.year, baseDate.month, baseDate.day);
    
    // Calculate days to subtract to get to Sunday (0 for Sunday, 1 for Monday, etc.)
    final daysToSubtract = normalizedDate.weekday % 7;
    final startOfWeek = normalizedDate.subtract(Duration(days: daysToSubtract));
    
    // Generate the week days
    final weekDays = List.generate(7, (index) => 
      startOfWeek.add(Duration(days: index))
    );

    // Debug prints
    print('CalendarWeekView Debug:');
    print('Base Date: ${normalizedDate.toIso8601String()}');
    print('Days to Subtract: $daysToSubtract');
    print('Start of Week: ${startOfWeek.toIso8601String()}');
    print('Week Days: ${weekDays.map((d) => '${d.toIso8601String()}').join(', ')}');

    return LayoutBuilder(
      builder: (context, constraints) {
        const padding = 6.0;
        const totalPadding = padding * 6;
        final dayWidth = (constraints.maxWidth - totalPadding) / 7;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: weekDays.asMap().entries.map((entry) {
            final index = entry.key;
            final date = entry.value;
            final isSelected = selectedDate != null &&
                date.year == selectedDate!.year &&
                date.month == selectedDate!.month &&
                date.day == selectedDate!.day;
            final isToday = _isToday(date);

            // First check if the business is open on this day
            final dayOfWeek = date.weekday;
            final isBusinessOpen = openingHours?.any((hour) {
              final hourWeekday = _getWeekdayFromName(hour.dayOfWeek);
              return hourWeekday == dayOfWeek && !hour.isClosed;
            }) ?? false;

            // For admin view, check appointment status if business is open
            final appointmentCount = isAdmin ? getAppointmentCount(date) : 0;
            final isFullyBooked = appointmentCount >= maxAppointmentsPerDay;

            // Determine the cell color
            Color? cellColor;
            if (!isBusinessOpen) {
              cellColor = Colors.grey.withAlpha(26);
            } else if (isAdmin) {
              if (isFullyBooked) {
                cellColor = Colors.orange.withAlpha(26);
              } else if (appointmentCount > 0) {
                cellColor = Colors.green.withAlpha(26);
              } else {
                cellColor = Colors.green.withAlpha(26);
              }
            } else {
              cellColor = Colors.green.withAlpha(26);
            }

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: dayWidth,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onDateSelected(date, isBusinessOpen),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? Theme.of(context).primaryColor : cellColor,
                          borderRadius: BorderRadius.circular(8),
                          border: isToday
                              ? Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatWeekday(context, date),
                              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              date.day.toString(),
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                color: isSelected ? Colors.white : null,
                              ),
                            ),
                            if (isAdmin && hasAppointments(date)) ...[
                              const SizedBox(height: 2),
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withAlpha(51)
                                      : Theme.of(context).primaryColor.withAlpha(26),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    getAppointmentCount(date).toString(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isSelected ? Colors.white : Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (index < 6) const SizedBox(width: padding),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _formatWeekday(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat('E', locale).format(date).toUpperCase();
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

  bool hasAppointments(DateTime date) {
    return getAppointmentCount(date) > 0;
  }

  int getAppointmentCount(DateTime date) {
    return appointments?.where((apt) =>
        apt.date.year == date.year &&
        apt.date.month == date.month &&
        apt.date.day == date.day).length ?? 0;
  }

  bool isFullyBooked(DateTime date) {
    return getAppointmentCount(date) >= maxAppointmentsPerDay;
  }
} 