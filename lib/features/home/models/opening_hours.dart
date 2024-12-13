import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/day_order.dart';

class OpeningHours {
  final String id;
  final String dayOfWeek;
  final bool isClosed;
  final String openTime;
  final String closeTime;
  final int order;
  final String? note;

  OpeningHours({
    required this.id,
    required this.dayOfWeek,
    required this.isClosed,
    required this.openTime,
    required this.closeTime,
    required this.order,
    this.note,
  });

  factory OpeningHours.fromMap(Map<String, dynamic> map) {
    return OpeningHours(
      id: map['id'] ?? '',
      dayOfWeek: map['dayOfWeek'] ?? '',
      isClosed: map['isClosed'] ?? false,
      openTime: map['openTime'] ?? '',
      closeTime: map['closeTime'] ?? '',
      order: map['order'] ?? 0,
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dayOfWeek': dayOfWeek,
      'isClosed': isClosed,
      'openTime': openTime,
      'closeTime': closeTime,
      'order': order,
      'note': note,
    };
  }

  factory OpeningHours.fromJson(Map<String, dynamic> json) {
    return OpeningHours(
      id: json['id'] as String? ?? '',
      dayOfWeek: json['dayOfWeek'] as String,
      openTime: json['openTime'] as String,
      closeTime: json['closeTime'] as String,
      isClosed: json['isClosed'] as bool? ?? false,
      order: json['order'] as int? ?? getDayOrder(json['dayOfWeek'] as String),
      note: json['note'] as String?,
    );
  }

  factory OpeningHours.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OpeningHours(
      id: doc.id,
      dayOfWeek: data['dayOfWeek'] as String,
      openTime: data['openTime'] as String,
      closeTime: data['closeTime'] as String,
      isClosed: data['isClosed'] as bool? ?? false,
      order: data['order'] as int? ?? getDayOrder(data['dayOfWeek'] as String),
      note: data['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'openTime': openTime,
      'closeTime': closeTime,
      'isClosed': isClosed,
      'order': order,
      'note': note,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'dayOfWeek': dayOfWeek,
      'openTime': openTime,
      'closeTime': closeTime,
      'isClosed': isClosed,
      'order': order,
      'note': note,
    };
  }
} 