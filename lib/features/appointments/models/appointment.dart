import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'appointment.freezed.dart';
part 'appointment.g.dart';

enum AppointmentStatus {
  pending,
  confirmed,
  cancelled,
  completed
}

@freezed
class Appointment with _$Appointment {
  const Appointment._();

  const factory Appointment({
    required String id,
    required String userId,
    required DateTime date,
    required String timeSlot,
    required String serviceId,
    @Default(AppointmentStatus.pending) AppointmentStatus status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Appointment;

  factory Appointment.fromJson(Map<String, dynamic> json) =>
      _$AppointmentFromJson(json);

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'timeSlot': timeSlot,
      'serviceId': serviceId,
      'status': status.toString(),
      'notes': notes,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  static Appointment fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Appointment(
      id: doc.id,
      userId: data['userId'] as String,
      date: (data['date'] as Timestamp).toDate(),
      timeSlot: data['timeSlot'] as String,
      serviceId: data['serviceId'] as String,
      status: AppointmentStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
      ),
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
} 