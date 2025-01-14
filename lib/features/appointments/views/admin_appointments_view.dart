import 'package:business_scheduler/features/common/widgets/unified_calendar.dart';
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
import 'package:business_scheduler/features/services/providers/business_services_provider.dart';
import '../../../features/admin/widgets/admin_app_bar.dart';
import '../../../features/home/widgets/calendar/calendar_providers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:business_scheduler/features/common/widgets/calendar/calendar_types.dart';


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
    final l10n = AppLocalizations.of(context)!;
    
    // Show index message if there's an index error
    if (_indexError != null && _indexError.toString().contains('indexes?create_composite=')) {
      return Scaffold(
        appBar: AdminAppBar(
          title: l10n.manageAppointments,
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
        title: l10n.manageAppointments,
        backPath: '/admin',
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: l10n.filterAppointments,
          ),
          IconButton(
            icon: Icon(_showAppointmentList ? Icons.calendar_month : Icons.list),
            onPressed: () {
              setState(() {
                _showAppointmentList = !_showAppointmentList;
              });
            },
            tooltip: _showAppointmentList ? l10n.showCalendar : l10n.showList,
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
                    child: UnifiedCalendar(
                      id: calendarId,
                      isAdmin: true,
                      showTimeSlotPicker: false,
                      onDateSelected: (date) {
                        ref.read(selectedDateProvider(calendarId).notifier).state = date;
                      },
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
    final l10n = AppLocalizations.of(context)!;
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
                DateFormat.yMMMMd(Localizations.localeOf(context).languageCode).format(selectedDate),
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
    final l10n = AppLocalizations.of(context)!;

    return appointmentsStream.when(
      data: (appointments) => appointments.isEmpty
          ? Center(
              child: Text(
                l10n.noAppointmentsOnDate(DateFormat('MMM dd, yyyy').format(date)),
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
    final l10n = AppLocalizations.of(context)!;
    
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
          return Center(
            child: Text(l10n.noAppointmentsFound),
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
                    DateFormat.yMMMMEEEEd(Localizations.localeOf(context).languageCode).format(date),
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
    final service = ref.watch(businessServicesProvider).value?.where((service) => service.id == appointment.serviceId).firstOrNull;
    final l10n = AppLocalizations.of(context)!;
    
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
                        l10n.clientId(appointment.userId),
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
                  tooltip: l10n.editAppointment,
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
                        l10n.service,
                        service?.name ?? l10n.unknownService,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        context,
                        Icons.timer_outlined,
                        l10n.duration,
                        l10n.durationMinutes(service?.durationMinutes ?? 0),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        context,
                        Icons.attach_money_outlined,
                        l10n.price,
                        l10n.priceAmount(service?.price.toString() ?? '0'),
                      ),
                      if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          context,
                          Icons.notes_outlined,
                          l10n.notes,
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