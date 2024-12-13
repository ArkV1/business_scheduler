import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/appointment_state_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../features/home/widgets/calendar/calendar_providers.dart';

class AdminCalendar extends ConsumerWidget {
  final String id;
  
  const AdminCalendar({
    super.key,
    this.id = 'admin_calendar',
  });

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewType = ref.watch(calendarViewTypeProvider(id));
    final currentDate = ref.watch(currentMonthProvider(id));
    final selectedDate = ref.watch(selectedDateProvider(id));
    final l10n = AppLocalizations.of(context)!;
    final pageController = PageController(initialPage: 500);
    
    final dateText = _formatDate(context, currentDate, viewType, currentDate);

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
                    ref.read(calendarViewTypeProvider(id).notifier).state = value.first;
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
                  'Appointments',
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
                dateText,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // Calendar view with page view
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
                        pageController.previousPage(
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
                        controller: pageController,
                        onPageChanged: (index) {
                          final newDate = viewType == CalendarViewType.week
                              ? currentDate.add(Duration(days: (index - 500) * 7))
                              : DateTime(
                                  currentDate.year,
                                  currentDate.month + (index - 500),
                                );
                          ref.read(currentMonthProvider(id).notifier).state = newDate;
                        },
                        itemBuilder: (context, index) {
                          final date = viewType == CalendarViewType.week
                              ? currentDate.add(Duration(days: (index - 500) * 7))
                              : DateTime(
                                  currentDate.year,
                                  currentDate.month + (index - 500),
                                );
                          return viewType == CalendarViewType.week
                              ? _AdminWeekView(selectedDate: selectedDate, baseDate: date, id: id)
                              : _AdminMonthView(selectedDate: selectedDate, baseDate: date, id: id);
                        },
                      ),
                    ),
                    // Right arrow
                    GestureDetector(
                      onTap: () {
                        pageController.nextPage(
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
            ],
          ),
        ),
      ],
    );
  }
}

class _AdminWeekView extends ConsumerWidget {
  final DateTime? selectedDate;
  final DateTime baseDate;
  final String id;

  const _AdminWeekView({
    this.selectedDate,
    required this.baseDate,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startOfWeek = baseDate.subtract(Duration(days: baseDate.weekday % 7));
    final weekDays = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

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

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: dayWidth,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        ref.read(selectedDateProvider(id).notifier).state = date;
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
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
                if (index < 6) const SizedBox(width: padding),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}

class _AdminMonthView extends ConsumerWidget {
  final DateTime? selectedDate;
  final DateTime baseDate;
  final String id;

  const _AdminMonthView({
    this.selectedDate,
    required this.baseDate,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

                        return SizedBox(
                          width: dayWidth,
                          height: dayHeight,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: isCurrentMonth
                                  ? () {
                                      ref.read(selectedDateProvider(id).notifier).state = date;
                                    }
                                  : null,
                              borderRadius: BorderRadius.circular(2),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
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
                                              ? null
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
  }
}

String _formatWeekday(BuildContext context, DateTime date) {
  final l10n = AppLocalizations.of(context)!;
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