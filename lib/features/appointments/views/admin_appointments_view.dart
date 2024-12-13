import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../providers/appointment_state_provider.dart';
import '../providers/appointment_data_provider.dart';
import '../providers/appointment_availability_provider.dart';
import '../../../core/widgets/firebase_index_message.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_message.dart';
import '../widgets/appointment_edit_dialog.dart';
import '../widgets/filter_dialog.dart';
import '../../services/models/business_service.dart';
import '../../../features/admin/widgets/admin_app_bar.dart';
import '../../../features/home/widgets/calendar/calendar_providers.dart';

class AdminAppointmentsView extends ConsumerStatefulWidget {
  const AdminAppointmentsView({super.key});

  @override
  ConsumerState<AdminAppointmentsView> createState() => _AdminAppointmentsViewState();
}

class _AdminAppointmentsViewState extends ConsumerState<AdminAppointmentsView> {
  static const String calendarId = 'admin_appointments_calendar';
  AppointmentStatus? _selectedStatus;
  String? _selectedServiceId;
  bool _showAppointmentList = false;
  DateTimeRange? _dateRange;
  Object? _indexError;
  StackTrace? _indexErrorStack;

  @override
  void initState() {
    super.initState();
    _testRequiredIndexes();
  }

  Future<void> _testRequiredIndexes() async {
    try {
      final appointmentService = ref.read(appointmentServiceProvider);
      final now = DateTime.now();
      
      // Test query 1: Basic time slot availability
      await appointmentService.isTimeSlotAvailable(now, "12:00");
      
      // Test query 2: Get appointments for a specific date range with filters
      await appointmentService.getFilteredAppointments(
        startDate: now,
        endDate: now.add(const Duration(days: 1)),
        status: AppointmentStatus.pending,
        serviceId: 'test-service',
      ).first;

      // Test query 3: Get user appointments with date ordering
      await appointmentService.getUserAppointments('test-user').first;

      if (mounted) {
        setState(() {
          _indexError = null;
          _indexErrorStack = null;
        });
      }
    } catch (e, stack) {
      if (mounted) {
        setState(() {
          _indexError = e;
          _indexErrorStack = stack;
        });
      }
    }
  }

  void _showEditDialog(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AppointmentEditDialog(appointment: appointment),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        status: _selectedStatus,
        serviceId: _selectedServiceId,
        dateRange: _dateRange,
        onApply: (status, serviceId, dateRange) {
          setState(() {
            _selectedStatus = status;
            _selectedServiceId = serviceId;
            _dateRange = dateRange;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider(calendarId)) ?? DateTime.now();
    final currentMonth = ref.watch(currentMonthProvider(calendarId));
    final calendarViewType = ref.watch(calendarViewTypeProvider(calendarId));
    
    // Show index message if there's an index error
    if (_indexError != null && _indexError.toString().contains('indexes?create_composite=')) {
      return Scaffold(
        appBar: AdminAppBar(
          title: 'Manage Appointments',
          backPath: '/admin',
        ),
        body: FirebaseIndexMessage(
          error: _indexError!,
          stackTrace: _indexErrorStack,
          onRefresh: () {
            setState(() {
              _indexError = null;
              _indexErrorStack = null;
            });
            _testRequiredIndexes();
          },
        ),
      );
    }
    
    return Scaffold(
      appBar: AdminAppBar(
        title: 'Manage Appointments',
        backPath: '/admin',
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter appointments',
          ),
          IconButton(
            icon: Icon(_showAppointmentList ? Icons.calendar_month : Icons.list),
            onPressed: () {
              setState(() {
                _showAppointmentList = !_showAppointmentList;
              });
            },
            tooltip: _showAppointmentList ? 'Show calendar' : 'Show list',
          ),
        ],
      ),
      body: _buildBody(selectedDate, currentMonth, calendarViewType),
    );
  }

  Widget _buildBody(DateTime selectedDate, DateTime currentMonth, CalendarViewType calendarViewType) {
    final appointmentsStream = ref.watch(dateAppointmentsProvider(currentMonth));
    final availableTimeSlots = ref.watch(availableTimeSlotsProvider(currentMonth));

    return appointmentsStream.when(
      data: (appointments) {
        return availableTimeSlots.when(
          data: (_) {
            return Column(
              children: [
                if (!_showAppointmentList) ...[
                  // Calendar Section
                  Container(
                    padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
                    child: Column(
                      children: [
                        // Header row containing switch, title, and date interval
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Row(
                            children: [
                              // View type switch
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
                                  selected: {calendarViewType},
                                  onSelectionChanged: (value) {
                                    ref.read(calendarViewTypeProvider(calendarId).notifier).state = value.first;
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
                                  'Appointments Overview',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Date text
                              Text(
                                DateFormat('MMM yyyy').format(currentMonth),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const AdminCalendar(id: calendarId),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _buildDailyAppointments(context, selectedDate),
                  ),
                ] else ...[
                  Expanded(
                    child: _AllAppointmentsList(
                      status: _selectedStatus,
                      serviceId: _selectedServiceId,
                      dateRange: _dateRange,
                      onEdit: _showEditDialog,
                    ),
                  ),
                ],
              ],
            );
          },
          loading: () => const LoadingIndicator(),
          error: (error, stack) => FirebaseIndexMessage(
            error: error,
            stackTrace: stack,
            onRefresh: () {
              ref.invalidate(availableTimeSlotsProvider);
              ref.invalidate(dateAppointmentsProvider);
            },
          ),
        );
      },
      loading: () => const LoadingIndicator(),
      error: (error, stack) => FirebaseIndexMessage(
        error: error,
        stackTrace: stack,
        onRefresh: () {
          ref.invalidate(availableTimeSlotsProvider);
          ref.invalidate(dateAppointmentsProvider);
        },
      ),
    );
  }

  Widget _buildDailyAppointments(BuildContext context, DateTime selectedDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.event,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                DateFormat('MMMM d, y').format(selectedDate),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _AppointmentsList(
            date: selectedDate,
            status: _selectedStatus,
            serviceId: _selectedServiceId,
            onEdit: _showEditDialog,
          ),
        ),
      ],
    );
  }
}

class AdminCalendar extends ConsumerWidget {
  final String id;

  const AdminCalendar({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewType = ref.watch(calendarViewTypeProvider(id));
    final currentDate = ref.watch(currentMonthProvider(id));
    final selectedDate = ref.watch(selectedDateProvider(id));
    
    // Watch both the appointments stream and available time slots
    final appointmentsStream = ref.watch(dateAppointmentsProvider(currentDate));
    final availableTimeSlots = ref.watch(availableTimeSlotsProvider(currentDate));

    // Handle both streams together
    return availableTimeSlots.when(
      data: (timeSlots) {
        return appointmentsStream.when(
          data: (appointments) {
            return Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: viewType == CalendarViewType.week ? 90 : 280,
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            // Left arrow
                            _buildNavigationButton(
                              context,
                              Icons.chevron_left,
                              () {
                                ref.read(currentMonthProvider(id).notifier).state = DateTime(
                                  currentDate.year,
                                  currentDate.month - 1,
                                );
                              },
                            ),
                            // Calendar
                            Expanded(
                              child: viewType == CalendarViewType.week
                                  ? _WeekView(
                                      selectedDate: selectedDate,
                                      baseDate: currentDate,
                                      appointments: appointments,
                                    )
                                  : _MonthView(
                                      selectedDate: selectedDate,
                                      baseDate: currentDate,
                                      appointments: appointments,
                                    ),
                            ),
                            // Right arrow
                            _buildNavigationButton(
                              context,
                              Icons.chevron_right,
                              () {
                                ref.read(currentMonthProvider(id).notifier).state = DateTime(
                                  currentDate.year,
                                  currentDate.month + 1,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildLegend(context),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const LoadingIndicator(),
          error: (error, stack) {
            if (error.toString().contains('indexes?create_composite=')) {
              return FirebaseIndexMessage(error: error.toString());
            }
            return ErrorMessage(error.toString());
          },
        );
      },
      loading: () => const LoadingIndicator(),
      error: (error, stack) {
        if (error.toString().contains('indexes?create_composite=')) {
          return FirebaseIndexMessage(error: error.toString());
        }
        return ErrorMessage(error.toString());
      },
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

  Widget _buildLegend(BuildContext context) {
    return SizedBox(
      height: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(context, 'Available', Colors.green),
          const SizedBox(width: 16),
          _buildLegendItem(context, 'Fully Booked', Colors.orange),
          const SizedBox(width: 16),
          _buildLegendItem(context, 'Past Date', Colors.grey),
        ],
      ),
    );
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

class _WeekView extends ConsumerWidget {
  final DateTime? selectedDate;
  final DateTime baseDate;
  final List<Appointment> appointments;

  const _WeekView({
    required this.selectedDate,
    required this.baseDate,
    required this.appointments,
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
            
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: dayWidth,
                  child: _DayCell(
                    date: date,
                    isSelected: selectedDate != null &&
                        date.year == selectedDate!.year &&
                        date.month == selectedDate!.month &&
                        date.day == selectedDate!.day,
                    appointments: appointments.where((apt) =>
                        apt.date.year == date.year &&
                        apt.date.month == date.month &&
                        apt.date.day == date.day).toList(),
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

class _MonthView extends ConsumerWidget {
  final DateTime? selectedDate;
  final DateTime baseDate;
  final List<Appointment> appointments;

  const _MonthView({
    required this.selectedDate,
    required this.baseDate,
    required this.appointments,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstDayOfMonth = DateTime(baseDate.year, baseDate.month, 1);
    final lastDayOfMonth = DateTime(baseDate.year, baseDate.month + 1, 0);
    
    final daysBeforeMonth = firstDayOfMonth.weekday % 7;
    final firstDateToShow = firstDayOfMonth.subtract(Duration(days: daysBeforeMonth));
    
    final totalDays = daysBeforeMonth + lastDayOfMonth.day;
    final totalWeeks = ((totalDays + 6) ~/ 7);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight - 24;
        final dayHeight = availableHeight / totalWeeks;

        return Column(
          children: [
            _buildWeekdayHeaders(),
            Expanded(
              child: Column(
                children: List.generate(totalWeeks, (weekIndex) {
                  return Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(7, (dayIndex) {
                        final date = firstDateToShow.add(
                          Duration(days: weekIndex * 7 + dayIndex),
                        );
                        
                        return SizedBox(
                          width: 40,
                          height: dayHeight,
                          child: _DayCell(
                            date: date,
                            isSelected: selectedDate != null &&
                                date.year == selectedDate!.year &&
                                date.month == selectedDate!.month &&
                                date.day == selectedDate!.day,
                            isCurrentMonth: date.month == baseDate.month,
                            appointments: appointments.where((apt) =>
                                apt.date.year == date.year &&
                                apt.date.month == date.month &&
                                apt.date.day == date.day).toList(),
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

  Widget _buildWeekdayHeaders() {
    return SizedBox(
      height: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
            .map((day) => SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _DayCell extends ConsumerWidget {
  final DateTime date;
  final bool isSelected;
  final bool isCurrentMonth;
  final List<Appointment> appointments;

  const _DayCell({
    required this.date,
    required this.isSelected,
    this.isCurrentMonth = true,
    required this.appointments,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isToday = ref.watch(isDateTodayProvider(date));
    final isPastDate = ref.watch(isPastDateProvider(date));
    final isFullyBooked = appointments.length >= 8; // Using constant from service

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (!isCurrentMonth || isPastDate) ? null : () {
          ref.read(selectedDateProvider('admin_calendar').notifier).state = date;
        },
        borderRadius: BorderRadius.circular(4),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? theme.primaryColor
                : !isCurrentMonth || isPastDate
                    ? Colors.transparent
                    : isFullyBooked
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: isToday
                ? Border.all(
                    color: theme.primaryColor,
                    width: 1,
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                date.day.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? Colors.white
                      : !isCurrentMonth
                          ? Colors.grey
                          : null,
                ),
              ),
              if (appointments.isNotEmpty && isCurrentMonth) ...[
                const SizedBox(height: 2),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : theme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      appointments.length.toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected
                            ? Colors.white
                            : theme.primaryColor,
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
  }
}

class _AppointmentsList extends ConsumerWidget {
  final DateTime date;
  final AppointmentStatus? status;
  final String? serviceId;
  final Function(Appointment) onEdit;

  const _AppointmentsList({
    required this.date,
    this.status,
    this.serviceId,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsStream = ref.watch(searchAppointmentsProvider((
      userId: null,
      startDate: date,
      endDate: date,
      status: status,
      serviceId: serviceId,
    )));

    return appointmentsStream.when(
      data: (appointments) => appointments.isEmpty
          ? Center(
              child: Text(
                'No appointments on ${DateFormat('MMM dd, yyyy').format(date)}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                return AppointmentCard(
                  appointment: appointment,
                  onEdit: () => onEdit(appointment),
                );
              },
            ),
      loading: () => const LoadingIndicator(),
      error: (error, stack) {
        if (error.toString().contains('indexes?create_composite=')) {
          return FirebaseIndexMessage(error: error.toString());
        }
        return ErrorMessage(error.toString());
      },
    );
  }
}

class _AllAppointmentsList extends ConsumerWidget {
  final AppointmentStatus? status;
  final String? serviceId;
  final DateTimeRange? dateRange;
  final Function(Appointment) onEdit;

  const _AllAppointmentsList({
    required this.status,
    this.serviceId,
    this.dateRange,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    
    final appointmentsStream = ref.watch(searchAppointmentsProvider((
      userId: null,
      startDate: dateRange?.start ?? startOfDay,
      endDate: dateRange?.end ?? startOfDay.add(const Duration(days: 365)),
      status: status,
      serviceId: serviceId,
    )));

    return appointmentsStream.when(
      data: (appointments) {
        if (appointments.isEmpty) {
          return const Center(
            child: Text('No appointments found'),
          );
        }

        final groupedAppointments = _groupAppointmentsByDate(appointments);
        final sortedDates = groupedAppointments.keys.toList()..sort();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: sortedDates.length,
          itemBuilder: (context, index) {
            final date = sortedDates[index];
            final dateAppointments = groupedAppointments[date]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    DateFormat('EEEE, MMMM d, y').format(date),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...dateAppointments.map((appointment) => AppointmentCard(
                  appointment: appointment,
                  onEdit: () => onEdit(appointment),
                )),
                if (index < sortedDates.length - 1) const Divider(),
              ],
            );
          },
        );
      },
      loading: () => const LoadingIndicator(),
      error: (error, stack) {
        if (error.toString().contains('indexes?create_composite=')) {
          return FirebaseIndexMessage(error: error.toString());
        }
        return ErrorMessage(error.toString());
      },
    );
  }

  Map<DateTime, List<Appointment>> _groupAppointmentsByDate(List<Appointment> appointments) {
    final groupedAppointments = <DateTime, List<Appointment>>{};
    for (final appointment in appointments) {
      final date = DateTime(
        appointment.date.year,
        appointment.date.month,
        appointment.date.day,
      );
      groupedAppointments.putIfAbsent(date, () => []).add(appointment);
    }
    return groupedAppointments;
  }
}

class AppointmentCard extends ConsumerWidget {
  final Appointment appointment;
  final VoidCallback onEdit;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formattedTime = ref.watch(formattedTimeSlotProvider(appointment.timeSlot));
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Client ID: ${appointment.userId}',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedTime,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                _AppointmentStatusBadge(status: appointment.status),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: onEdit,
                  tooltip: 'Edit Appointment',
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        context,
                        Icons.calendar_today_outlined,
                        'Service',
                        appointment.service.name,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        context,
                        Icons.timer_outlined,
                        'Duration',
                        '${appointment.service.durationMinutes} minutes',
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        context,
                        Icons.attach_money_outlined,
                        'Price',
                        '\$${appointment.service.price}',
                      ),
                      if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          context,
                          Icons.notes_outlined,
                          'Notes',
                          appointment.notes!,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _AppointmentStatusBadge extends StatelessWidget {
  final AppointmentStatus status;

  const _AppointmentStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color statusColor;
    switch (status) {
      case AppointmentStatus.pending:
        statusColor = Colors.orange;
        break;
      case AppointmentStatus.confirmed:
        statusColor = Colors.green;
        break;
      case AppointmentStatus.cancelled:
        statusColor = Colors.red;
        break;
      case AppointmentStatus.completed:
        statusColor = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
} 