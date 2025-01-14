import 'package:business_scheduler/features/appointments/models/appointment.dart';
import 'package:business_scheduler/features/home/models/opening_hours.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class CalendarMonthView extends StatelessWidget {
  final bool isAdmin;
  final DateTime? selectedDate;
  final DateTime baseDate;
  final List<Appointment>? appointments;
  final List<OpeningHours>? openingHours;
  final Function(DateTime date, bool isBusinessOpen) onDateSelected;
  final int maxAppointmentsPerDay;

  const CalendarMonthView({
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
    final l10n = AppLocalizations.of(context)!;
    final firstDayOfMonth = DateTime(baseDate.year, baseDate.month, 1);
    final lastDayOfMonth = DateTime(baseDate.year, baseDate.month + 1, 0);
    
    final daysBeforeMonth = firstDayOfMonth.weekday % 7;
    final firstDateToShow = firstDayOfMonth.subtract(Duration(days: daysBeforeMonth));
    
    final totalDays = daysBeforeMonth + lastDayOfMonth.day;
    final totalWeeks = ((totalDays + 6) ~/ 7);

    return Column(
      children: [
        SizedBox(
          height: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final date = DateTime(2024, 1, 7 + index); // Start with a Sunday
              return SizedBox(
                width: 32,
                child: Center(
                  child: Text(
                    DateFormat('E', Localizations.localeOf(context).languageCode)
                        .format(date)
                        .toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 2),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.8,
            ),
            itemCount: 7 * totalWeeks,
            itemBuilder: (context, index) {
              final date = firstDateToShow.add(Duration(days: index));
              final isSelected = selectedDate != null &&
                  date.year == selectedDate!.year &&
                  date.month == selectedDate!.month &&
                  date.day == selectedDate!.day;
              final isToday = _isToday(date);
              final isCurrentMonth = date.month == baseDate.month;

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
              if (!isCurrentMonth) {
                cellColor = Colors.transparent;
              } else if (!isBusinessOpen) {
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

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isCurrentMonth ? () => onDateSelected(date, isBusinessOpen) : null,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).primaryColor : cellColor,
                      borderRadius: BorderRadius.circular(4),
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
                          date.day.toString(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: !isCurrentMonth
                                ? Colors.grey[400]
                                : isSelected
                                    ? Colors.white
                                    : null,
                            fontWeight: isToday ? FontWeight.bold : null,
                            fontSize: 11,
                          ),
                        ),
                        if (isAdmin && isCurrentMonth && hasAppointments(date)) ...[
                          const SizedBox(height: 1),
                          Container(
                            width: 14,
                            height: 14,
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
              );
            },
          ),
        ),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
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