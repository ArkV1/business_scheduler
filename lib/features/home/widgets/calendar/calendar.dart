import 'package:business_scheduler/core/widgets/error_message.dart';
import 'package:business_scheduler/features/home/providers/opening_hours_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../time_slot_picker/time_slot_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../services/providers/business_services_provider.dart';
import '../../../appointments/providers/appointment_state_provider.dart';
import '../../../appointments/providers/appointment_availability_provider.dart';
import '../../../appointments/providers/appointment_data_provider.dart';
import '../../../auth/providers/user_provider.dart';
import 'calendar_providers.dart';

class Calendar extends ConsumerStatefulWidget {
  final bool showTimeSlotPicker;
  final int? initialOffset;
  final DateTime? initialDate;
  final String id;
  
  const Calendar({
    super.key,
    this.showTimeSlotPicker = true,
    this.initialOffset,
    this.initialDate,
    required this.id,
  });

  @override
  ConsumerState<Calendar> createState() => _CalendarState();
}

class _CalendarState extends ConsumerState<Calendar> {
  late PageController _pageController;
  final int _baseOffset = 500;

  @override
  void initState() {
    super.initState();
    final weekOffset = ref.read(weekOffsetProvider(widget.id));
    _pageController = PageController(
      initialPage: _baseOffset + weekOffset,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(Calendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final weekOffset = ref.read(weekOffsetProvider(widget.id));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_baseOffset + weekOffset);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final openingHours = ref.watch(openingHoursStreamProvider);
    final viewType = ref.watch(calendarViewTypeProvider(widget.id));
    final currentDate = ref.watch(currentMonthProvider(widget.id));
    final weekOffset = ref.watch(weekOffsetProvider(widget.id));
    final selectedDate = ref.watch(selectedDateProvider(widget.id));
    final l10n = AppLocalizations.of(context)!;

    // Calculate the current display date based on week offset
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final startOfWeek = startOfToday.subtract(Duration(days: startOfToday.weekday % 7));
    final displayDate = startOfWeek.add(Duration(days: 7 * weekOffset));
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header row containing switch, title, and date interval
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              // Switch
              SizedBox(
                width: 100,
                height: 32,
                child: SegmentedButton<CalendarViewType>(
                  segments: const [
                    ButtonSegment(
                      value: CalendarViewType.week,
                      icon: Icon(Icons.view_week, size: 16),
                    ),
                    ButtonSegment(
                      value: CalendarViewType.month,
                      icon: Icon(Icons.calendar_view_month, size: 16),
                    ),
                  ],
                  selected: {viewType},
                  onSelectionChanged: (value) {
                    ref.read(calendarViewTypeProvider(widget.id).notifier).state = value.first;
                  },
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 8)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Header text
              Expanded(
                child: Text(
                  l10n.availableDates,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 16),
              // Date interval text
              Text(
                _formatDate(context, displayDate, viewType, displayDate),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // Calendar view with page view and legend
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: viewType == CalendarViewType.week ? 90 : 200,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Left arrow
                    GestureDetector(
                      onTap: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 24,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.chevron_left,
                          size: 24,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ),
                    // Calendar
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          final newOffset = index - _baseOffset;
                          if (viewType == CalendarViewType.week) {
                            // Calculate the new date based on the current date and page offset
                            final today = DateTime.now();
                            final startOfToday = DateTime(today.year, today.month, today.day);
                            final startOfWeek = startOfToday.subtract(Duration(days: startOfToday.weekday % 7));
                            final newDate = startOfWeek.add(Duration(days: 7 * newOffset));
                            
                            // Update providers
                            ref.read(weekOffsetProvider(widget.id).notifier).state = newOffset;
                            ref.read(currentMonthProvider(widget.id).notifier).state = newDate;
                          } else {
                            final newDate = DateTime(
                              currentDate.year,
                              currentDate.month + (newOffset - weekOffset),
                            );
                            ref.read(currentMonthProvider(widget.id).notifier).state = newDate;
                          }
                        },
                        itemBuilder: (context, index) {
                          final offset = index - _baseOffset;
                          final date = viewType == CalendarViewType.week
                              ? startOfWeek.add(Duration(days: 7 * offset))
                              : DateTime(
                                  currentDate.year,
                                  currentDate.month + offset,
                                );
                          return viewType == CalendarViewType.week
                              ? _WeekView(
                                  selectedDate: selectedDate,
                                  baseDate: date,
                                  showTimeSlotPicker: widget.showTimeSlotPicker,
                                  id: widget.id,
                                )
                              : _MonthView(
                                  selectedDate: selectedDate,
                                  baseDate: date,
                                  showTimeSlotPicker: widget.showTimeSlotPicker,
                                  id: widget.id,
                                );
                        },
                      ),
                    ),
                    // Right arrow
                    GestureDetector(
                      onTap: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 24,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.chevron_right,
                          size: 24,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  const SizedBox(height: 8),
                  // Legend
                  SizedBox(
                    height: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendItem(context, l10n.calendarAvailable, Colors.green),
                        const SizedBox(width: 16),
                        _buildLegendItem(context, l10n.calendarUnavailable, Colors.red),
                        const SizedBox(width: 16),
                        _buildLegendItem(context, l10n.calendarClosed, Colors.grey),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(BuildContext context, DateTime date, CalendarViewType viewType, DateTime currentDate) {
    final l10n = AppLocalizations.of(context)!;
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';
    
    String _getMonthName(DateTime date, bool isShort) {
      final monthIndex = date.month - 1;
      final months = isShort ? [
        l10n.monthShortJan, l10n.monthShortFeb, l10n.monthShortMar,
        l10n.monthShortApr, l10n.monthShortMay, l10n.monthShortJun,
        l10n.monthShortJul, l10n.monthShortAug, l10n.monthShortSep,
        l10n.monthShortOct, l10n.monthShortNov, l10n.monthShortDec,
      ] : [
        l10n.monthJan, l10n.monthFeb, l10n.monthMar,
        l10n.monthApr, l10n.monthMay, l10n.monthJun,
        l10n.monthJul, l10n.monthAug, l10n.monthSep,
        l10n.monthOct, l10n.monthNov, l10n.monthDec,
      ];
      return months[monthIndex];
    }
    
    if (viewType == CalendarViewType.week) {
      final startMonth = _getMonthName(currentDate, true);
      final endMonth = _getMonthName(currentDate.add(const Duration(days: 6)), true);
      final startDay = currentDate.day.toString();
      final endDay = currentDate.add(const Duration(days: 6)).day.toString();
      
      return isHebrew 
          ? '$endDay $endMonth - $startDay $startMonth'
          : '$startMonth $startDay - $endMonth $endDay';
    } else {
      final month = _getMonthName(currentDate, false);
      return '$month ${currentDate.year}';
    }
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 11,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            border: Border.all(color: color, width: 1),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
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

bool _hasServiceAvailability(DateTime date) {
  if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
    return false;
  }
  return true;
}

class _WeekView extends ConsumerWidget {
  final DateTime? selectedDate;
  final DateTime baseDate;
  final bool showTimeSlotPicker;
  final String id;

  const _WeekView({
    this.selectedDate,
    required this.baseDate,
    required this.showTimeSlotPicker,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final openingHours = ref.watch(openingHoursStreamProvider);
    
    return openingHours.when(
      data: (hours) {
        final startOfWeek = baseDate.subtract(Duration(days: baseDate.weekday % 7));
        final weekDays = List.generate(
          7,
          (index) => startOfWeek.add(Duration(days: index)),
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            const padding = 8.0;
            const totalPadding = padding * 6;
            final dayWidth = (constraints.maxWidth - totalPadding) / 7;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: weekDays.asMap().entries.map((entry) {
                final index = entry.key;
                final date = entry.value;
                final isSelected = selectedDate != null &&
                    date.day == selectedDate!.day &&
                    date.month == selectedDate!.month &&
                    date.year == selectedDate!.year;
                final isToday = _isToday(date);

                // Check if the business is open on this day
                final dayOfWeek = date.weekday;
                final isOpen = hours.any((hour) {
                  final hourWeekday = _getWeekdayFromName(hour.dayOfWeek);
                  return hourWeekday == dayOfWeek && !hour.isClosed;
                });
                final hasAvailability = isOpen && _hasServiceAvailability(date);

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: dayWidth,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: hasAvailability
                              ? () {
                                  ref.read(selectedDateProvider(id).notifier).state = date;
                                  if (showTimeSlotPicker) {
                                    _showTimeSlotDialog(context, date);
                                  }
                                }
                              : null,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : !isOpen
                                      ? Colors.grey.withOpacity(0.1)
                                      : hasAvailability
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
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
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (index < 6) const SizedBox(width: 8),
                  ],
                );
              }).toList(),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error loading calendar')),
    );
  }
}

class _MonthView extends ConsumerWidget {
  final DateTime? selectedDate;
  final DateTime baseDate;
  final bool showTimeSlotPicker;
  final String id;

  const _MonthView({
    this.selectedDate,
    required this.baseDate,
    required this.showTimeSlotPicker,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final openingHours = ref.watch(openingHoursStreamProvider);
    
    return openingHours.when(
      data: (hours) {
        final l10n = AppLocalizations.of(context)!;
        final firstDayOfMonth = DateTime(baseDate.year, baseDate.month, 1);
        final lastDayOfMonth = DateTime(baseDate.year, baseDate.month + 1, 0);
        
        final daysBeforeMonth = firstDayOfMonth.weekday - 1;
        final firstDateToShow = firstDayOfMonth.subtract(Duration(days: daysBeforeMonth));
        
        final totalDays = daysBeforeMonth + lastDayOfMonth.day;
        final totalWeeks = ((totalDays + 6) ~/ 7);

        return LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight - 16;
            final dayWidth = (constraints.maxWidth / 8.5);
            final dayHeight = (availableHeight - (4 * (totalWeeks - 1))) / totalWeeks;

            return Column(
              children: [
                // Weekday headers
                SizedBox(
                  height: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      l10n.weekdaySun,
                      l10n.weekdayMon,
                      l10n.weekdayTue,
                      l10n.weekdayWed,
                      l10n.weekdayThu,
                      l10n.weekdayFri,
                      l10n.weekdaySat,
                    ].map((day) => SizedBox(
                          width: 28,
                          child: Center(
                            child: Text(
                              day,
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Column(
                    children: List.generate(totalWeeks, (weekIndex) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: weekIndex < totalWeeks - 1 ? 4 : 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(7, (dayIndex) {
                            final date = firstDateToShow.add(
                              Duration(days: weekIndex * 7 + dayIndex),
                            );
                            final isSelected = selectedDate != null &&
                                date.day == selectedDate!.day &&
                                date.month == selectedDate!.month &&
                                date.year == selectedDate!.year;
                            final isToday = _isToday(date);
                            final isCurrentMonth = date.month == baseDate.month;
                            
                            // Check if the business is open on this day
                            final dayOfWeek = date.weekday;
                            final isOpen = hours.any((hour) {
                              final hourWeekday = _getWeekdayFromName(hour.dayOfWeek);
                              return hourWeekday == dayOfWeek && !hour.isClosed;
                            });
                            final hasAvailability = isOpen && isCurrentMonth && _hasServiceAvailability(date);

                            return SizedBox(
                              width: dayWidth,
                              height: dayHeight,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: hasAvailability
                                      ? () {
                                          ref.read(selectedDateProvider(id).notifier).state = date;
                                          if (showTimeSlotPicker) {
                                            _showTimeSlotDialog(context, date);
                                          }
                                        }
                                      : null,
                                  borderRadius: BorderRadius.circular(2),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : isCurrentMonth
                                              ? !isOpen
                                                  ? Colors.grey.withOpacity(0.1)
                                                  : hasAvailability
                                                      ? Colors.green.withOpacity(0.1)
                                                      : Colors.transparent
                                              : Colors.transparent,
                                      borderRadius: BorderRadius.circular(2),
                                      border: isToday
                                          ? Border.all(
                                              color: Theme.of(context).primaryColor,
                                              width: 1,
                                            )
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        date.day.toString(),
                                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                          color: isSelected
                                              ? Colors.white
                                              : isCurrentMonth
                                                  ? hasAvailability
                                                      ? null
                                                      : Colors.grey[400]
                                                  : Colors.grey[400],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error loading calendar')),
    );
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

String _formatWeekday(BuildContext context, DateTime date) {
  final l10n = AppLocalizations.of(context)!;
  // Week starts on Sunday for all languages
  final weekdayIndex = date.weekday % 7;
  
  final weekdays = [
    l10n.weekdaySun,
    l10n.weekdayMon,
    l10n.weekdayTue,
    l10n.weekdayWed,
    l10n.weekdayThu,
    l10n.weekdayFri,
    l10n.weekdaySat,
  ];
  
  return weekdays[weekdayIndex];
}

bool _isToday(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

bool _isHoliday(DateTime date) {
  // You might want to get this from a proper holiday calendar service
  // or from admin settings
  return false;
}
