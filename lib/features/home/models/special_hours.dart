import 'package:cloud_firestore/cloud_firestore.dart';

class SpecialHours {
  final String id;
  final DateTime date;
  final bool isClosed;
  final String? openTime;
  final String? closeTime;
  final String? note;

  SpecialHours({
    required this.id,
    required this.date,
    required this.isClosed,
    this.openTime,
    this.closeTime,
    this.note,
  });

  factory SpecialHours.fromMap(Map<String, dynamic> map) {
    return SpecialHours(
      id: map['id'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      isClosed: map['isClosed'] ?? false,
      openTime: map['openTime'],
      closeTime: map['closeTime'],
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': Timestamp.fromDate(date),
      'isClosed': isClosed,
      'openTime': openTime,
      'closeTime': closeTime,
      'note': note,
    };
  }
} 