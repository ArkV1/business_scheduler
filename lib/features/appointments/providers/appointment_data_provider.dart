import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../../auth/providers/user_provider.dart';
import '../providers/appointment_availability_provider.dart';
import '../../services/models/business_service.dart';

// Provider for the appointment service
final appointmentServiceProvider = Provider<AppointmentService>((ref) {
  return AppointmentService();
});

// Stream of user's appointments
final userAppointmentsProvider = StreamProvider<List<Appointment>>((ref) {
  final user = ref.watch(userProvider).value;
  if (user == null) return Stream.value([]);

  final appointmentService = ref.watch(appointmentServiceProvider);
  return appointmentService.getUserAppointments(user.id);
});

// Stream of appointments for a specific date
final dateAppointmentsProvider = StreamProvider.family<List<Appointment>, DateTime>((ref, date) {
  final appointmentService = ref.watch(appointmentServiceProvider);
  return appointmentService.getAppointmentsForDate(date);
});

// Stream of all appointments with search and filter functionality
final searchAppointmentsProvider = StreamProvider.family<List<Appointment>, ({
  String? userId,
  DateTime? startDate,
  DateTime? endDate,
  AppointmentStatus? status,
  String? serviceId,
})>((ref, filters) {
  final appointmentService = ref.watch(appointmentServiceProvider);
  return appointmentService.getFilteredAppointments(
    userId: filters.userId,
    startDate: filters.startDate,
    endDate: filters.endDate,
    status: filters.status,
    serviceId: filters.serviceId,
  );
});

// Provider for updating appointment details
final appointmentUpdateProvider = Provider.family<Future<void>, ({
  String appointmentId,
  DateTime date,
  String timeSlot,
  BusinessService service,
  AppointmentStatus status,
  String? notes,
})>((ref, params) async {
  final appointmentService = ref.watch(appointmentServiceProvider);
  
  // Check time slot availability
  final isAvailable = ref.read(timeSlotAvailabilityProvider((
    date: params.date,
    timeSlot: params.timeSlot,
    service: params.service,
  ))).when(
    data: (available) => available,
    loading: () => false,
    error: (_, __) => false,
  );

  if (!isAvailable) {
    throw Exception('Time slot is not available');
  }

  return appointmentService.updateAppointment(
    params.appointmentId,
    date: params.date,
    timeSlot: params.timeSlot,
    service: params.service,
    status: params.status,
    notes: params.notes,
  );
});

// Time slot formatting provider
final formattedTimeSlotProvider = Provider.family<String, String>((ref, timeSlot) {
  final appointmentService = ref.watch(appointmentServiceProvider);
  return appointmentService.formatTimeSlot(timeSlot);
});
 