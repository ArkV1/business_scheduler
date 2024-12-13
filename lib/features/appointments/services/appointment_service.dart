import 'package:appointment_app/features/appointments/models/time_slot_section.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/appointment.dart';
import '../../../core/utils/firebase_error_handler.dart';
import 'package:intl/intl.dart';
import '../../services/models/business_service.dart';
import 'package:appointment_app/core/services/logger_service.dart';


class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const int maxSlotsPerDay = 8;

  // CRUD Operations

  // Create a new appointment
  Future<Appointment> createAppointment({
    required String userId,
    required DateTime date,
    required String timeSlot,
    required BusinessService service,
    String? notes,
  }) async {
    try {
      // Validate time slot availability
      final isAvailable = await isTimeSlotAvailable(date, timeSlot);
      if (!isAvailable) {
        throw Exception('Time slot is not available');
      }

      final appointmentData = Appointment(
        id: '', // Will be set after creation
        userId: userId,
        date: date,
        timeSlot: timeSlot,
        service: service,
        notes: notes,
        createdAt: DateTime.now(),
      ).toFirestore();

      Logger.firebase(
        'CREATE',
        'appointments',
        data: {
          'userId': userId,
          'date': date.toIso8601String(),
          'timeSlot': timeSlot,
          'serviceId': service.id,
          'notes': notes,
        },
      );

      final docRef = await _firestore.collection('appointments').add(appointmentData);
      final doc = await docRef.get();
      return Appointment.fromFirestore(doc);
    } catch (e, stackTrace) {
      handleFirebaseError(e, stackTrace);
      rethrow;
    }
  }

  // Get a single appointment
  Future<Appointment?> getAppointment(String appointmentId) async {
    try {
      Logger.firebase(
        'GET',
        'appointments',
        docId: appointmentId,
      );

      final doc = await _firestore.collection('appointments').doc(appointmentId).get();
      return doc.exists ? Appointment.fromFirestore(doc) : null;
    } catch (e, stackTrace) {
      handleFirebaseError(e, stackTrace);
      rethrow;
    }
  }

  // Get all appointments for a user
  Stream<List<Appointment>> getUserAppointments(String userId) {
    Logger.firebase(
      'LISTEN',
      'appointments',
      data: {'userId': userId},
    );

    return _firestore
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final appointments = <Appointment>[];
          for (var doc in snapshot.docs) {
            appointments.add(await Appointment.fromFirestore(doc));
          }
          return appointments;
        });
  }

  // Get appointments for a specific date
  Stream<List<Appointment>> getAppointmentsForDate(DateTime date) {
    final dateRange = _getDateRange(date);
    Logger.firebase(
      'LISTEN',
      'appointments',
      data: {
        'startDate': dateRange.$1.toIso8601String(),
        'endDate': dateRange.$2.toIso8601String(),
      },
    );

    return _firestore
        .collection('appointments')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.$1))
        .where('date', isLessThan: Timestamp.fromDate(dateRange.$2))
        .snapshots()
        .asyncMap((snapshot) async {
          final appointments = <Appointment>[];
          for (var doc in snapshot.docs) {
            appointments.add(await Appointment.fromFirestore(doc));
          }
          return appointments;
        });
  }

  // Update appointment details
  Future<void> updateAppointment(
    String appointmentId, {
    DateTime? date,
    String? timeSlot,
    BusinessService? service,
    AppointmentStatus? status,
    String? notes,
  }) async {
    try {
      // If date or time slot is changing, validate availability
      if (date != null || timeSlot != null) {
        final currentAppointment = await getAppointment(appointmentId);
        if (currentAppointment == null) {
          throw Exception('Appointment not found');
        }

        final newDate = date ?? currentAppointment.date;
        final newTimeSlot = timeSlot ?? currentAppointment.timeSlot;

        if (newDate != currentAppointment.date || newTimeSlot != currentAppointment.timeSlot) {
          final isAvailable = await isTimeSlotAvailable(newDate, newTimeSlot);
          if (!isAvailable) {
            throw Exception('Time slot is not available');
          }
        }
      }

      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (date != null) updates['date'] = Timestamp.fromDate(date);
      if (timeSlot != null) updates['timeSlot'] = timeSlot;
      if (service != null) updates['serviceId'] = service.id;
      if (status != null) updates['status'] = status.toString();
      if (notes != null) updates['notes'] = notes;

      Logger.firebase(
        'UPDATE',
        'appointments',
        docId: appointmentId,
        data: updates,
      );

      await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .update(updates);
    } catch (e, stackTrace) {
      handleFirebaseError(e, stackTrace);
      rethrow;
    }
  }

  // Delete appointment (soft delete by updating status)
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      Logger.firebase(
        'UPDATE',
        'appointments',
        docId: appointmentId,
        data: {'status': AppointmentStatus.cancelled.toString()},
      );

      await updateAppointmentStatus(appointmentId, AppointmentStatus.cancelled);
    } catch (e, stackTrace) {
      handleFirebaseError(e, stackTrace);
      rethrow;
    }
  }

  // Filtering and Search

  // Get filtered appointments with all possible filters
  Stream<List<Appointment>> getFilteredAppointments({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    AppointmentStatus? status,
    String? serviceId,
  }) {
    Query query = _firestore.collection('appointments');

    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    }

    if (startDate != null) {
      query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    if (status != null) {
      query = query.where('status', isEqualTo: status.toString());
    }

    if (serviceId != null) {
      query = query.where('serviceId', isEqualTo: serviceId);
    }

    Logger.firebase(
      'LISTEN',
      'appointments',
      data: {
        'userId': userId,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'status': status?.toString(),
        'serviceId': serviceId,
      },
    );

    return query
        .orderBy('date', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final appointments = <Appointment>[];
          for (var doc in snapshot.docs) {
            appointments.add(await Appointment.fromFirestore(doc));
          }
          return appointments;
        });
  }

  // Time Slot Management

  // Check if a time slot is available
  Future<bool> isTimeSlotAvailable(
    DateTime date,
    String timeSlot,
  ) async {
    try {
      final dateRange = _getDateRange(date);
      
      Logger.firebase(
        'GET',
        'appointments',
        data: {
          'date': date.toIso8601String(),
          'timeSlot': timeSlot,
        },
      );

      // Check if the slot is already booked
      final querySnapshot = await _firestore
          .collection('appointments')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.$1))
          .where('date', isLessThan: Timestamp.fromDate(dateRange.$2))
          .where('timeSlot', isEqualTo: timeSlot)
          .where('status', whereIn: [
            AppointmentStatus.pending.toString(),
            AppointmentStatus.confirmed.toString()
          ])
          .get();

      if (querySnapshot.docs.isNotEmpty) return false;

      // Check if maximum slots for the day are reached
      final dayAppointments = await _firestore
          .collection('appointments')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.$1))
          .where('date', isLessThan: Timestamp.fromDate(dateRange.$2))
          .where('status', whereIn: [
            AppointmentStatus.pending.toString(),
            AppointmentStatus.confirmed.toString()
          ])
          .get();

      return dayAppointments.docs.length < maxSlotsPerDay;
    } catch (e, stackTrace) {
      handleFirebaseError(e, stackTrace);
      rethrow;
    }
  }

  // Get available time slots for a date
  Future<List<String>> getAvailableTimeSlots(DateTime date) async {
    try {
      final allTimeSlots = _generateTimeSlots();
      final bookedTimeSlots = await _getBookedTimeSlots(date);
      return allTimeSlots.where((slot) => !bookedTimeSlots.contains(slot)).toList();
    } catch (e, stackTrace) {
      handleFirebaseError(e, stackTrace);
      rethrow;
    }
  }

  // Utility Methods

  // Update appointment status
  Future<void> updateAppointmentStatus(
    String appointmentId,
    AppointmentStatus status,
  ) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': status.toString(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, stackTrace) {
      handleFirebaseError(e, stackTrace);
      rethrow;
    }
  }

  // Date utility methods
  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool isPastDate(DateTime date) {
    return date.isBefore(DateTime.now().subtract(const Duration(days: 1)));
  }

  // Time slot formatting
  String formatTimeSlot(String timeSlot) {
    final hour = int.parse(timeSlot.split(':')[0]);
    final minute = int.parse(timeSlot.split(':')[1]);
    return DateFormat('h:mm a').format(DateTime(2022, 1, 1, hour, minute));
  }

  // Private helper methods

  List<String> _generateTimeSlots() {
    final slots = <String>[];
    for (var hour = 11; hour <= 17; hour++) {
      if (hour != 13) { // Skip lunch hour
        for (var minute = 0; minute < 60; minute += 10) {
          slots.add('${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
        }
      }
    }
    return slots;
  }

  // Groups time slots into sections for better UI organization
  List<TimeSlotSection> groupTimeSlots(List<String> slots) {
    final sections = <TimeSlotSection>[];
    String? currentHour;
    List<String> currentSlots = [];

    for (final slot in slots) {
      final hour = slot.split(':')[0];
      
      if (currentHour != hour && currentSlots.isNotEmpty) {
        sections.add(TimeSlotSection(
          hour: currentHour!,
          slots: List.from(currentSlots),
        ));
        currentSlots.clear();
      }
      
      currentHour = hour;
      currentSlots.add(slot);
    }

    if (currentSlots.isNotEmpty) {
      sections.add(TimeSlotSection(
        hour: currentHour!,
        slots: currentSlots,
      ));
    }

    return sections;
  }

  Future<List<String>> _getBookedTimeSlots(DateTime date) async {
    final dateRange = _getDateRange(date);

    final querySnapshot = await _firestore
        .collection('appointments')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(dateRange.$1))
        .where('date', isLessThan: Timestamp.fromDate(dateRange.$2))
        .where('status', whereIn: [
          AppointmentStatus.pending.toString(),
          AppointmentStatus.confirmed.toString()
        ])
        .get();

    return querySnapshot.docs
        .map((doc) => doc.data()['timeSlot'] as String)
        .toList();
  }

  (DateTime, DateTime) _getDateRange(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return (startOfDay, endOfDay);
  }
} 