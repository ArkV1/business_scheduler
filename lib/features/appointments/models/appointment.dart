import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/models/business_service.dart';

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
    required BusinessService service,
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
      'serviceId': service.id,
      'status': status.toString(),
      'notes': notes,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  static Future<Appointment> fromFirestore(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    
    // Get the service from Firestore
    final serviceDoc = await FirebaseFirestore.instance
        .collection('business_services')
        .doc(data['serviceId'] as String)
        .get();
    
    if (!serviceDoc.exists) {
      throw Exception('Service not found');
    }

    return Appointment(
      id: doc.id,
      userId: data['userId'] as String,
      date: (data['date'] as Timestamp).toDate(),
      timeSlot: data['timeSlot'] as String,
      service: BusinessService.fromFirestore(serviceDoc),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
      ),
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
} 