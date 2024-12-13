import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/opening_hours.dart';
import '../models/special_hours.dart';
import '../../../core/utils/firebase_error_handler.dart';

final hoursServiceProvider = Provider((ref) => HoursService());

class HoursService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Regular Opening Hours Methods
  Stream<List<OpeningHours>> getOpeningHours() {
    return _firestore
        .collection('opening_hours')
        .orderBy('order')
        .snapshots()
        .handleError((error, stackTrace) {
          final errorInfo = FirebaseErrorInfo.fromError(error, stackTrace);
          if (errorInfo.isIndexError) {
            print('Index error: ${errorInfo.message}'); // Debug log
            print('Stack trace: $stackTrace'); // Debug log
            throw error;
          }
          // For other errors, log and return empty list
          print('Non-index error: ${errorInfo.message}'); // Debug log
          print('Stack trace: $stackTrace'); // Debug log
          handleFirebaseError(error, stackTrace);
          return const Stream.empty();
        })
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data();
              data['id'] = doc.id; // Include the document ID in the map
              return OpeningHours.fromMap(data);
            })
            .toList());
  }

  // Special Hours Methods
  Stream<List<SpecialHours>> getSpecialHours() {
    return _firestore
        .collection('special_hours')
        .orderBy('date')
        .snapshots()
        .handleError((error, stackTrace) {
          final errorInfo = FirebaseErrorInfo.fromError(error, stackTrace);
          if (errorInfo.isIndexError) {
            // Propagate index errors so they can be shown in the UI
            throw error;
          }
          // For other errors, log and return empty list
          handleFirebaseError(error, stackTrace);
          return const Stream.empty();
        })
        .map((snapshot) => snapshot.docs
            .map((doc) => SpecialHours.fromMap(doc.data()))
            .toList());
  }

  Future<void> updateOpeningHours(OpeningHours hours) async {
    try {
      await _firestore
          .collection('opening_hours')
          .doc(hours.dayOfWeek.toLowerCase())
          .set(hours.toFirestore());
    } catch (error, stackTrace) {
      final errorInfo = FirebaseErrorInfo.fromError(error, stackTrace);
      handleFirebaseError(error, stackTrace);
      throw Exception('Failed to update opening hours: ${errorInfo.message}');
    }
  }

  Future<void> deleteOpeningHours(String dayOfWeek) async {
    try {
      await _firestore
          .collection('opening_hours')
          .doc(dayOfWeek.toLowerCase())
          .delete();
    } catch (error, stackTrace) {
      final errorInfo = FirebaseErrorInfo.fromError(error, stackTrace);
      handleFirebaseError(error, stackTrace);
      throw Exception('Failed to delete opening hours: ${errorInfo.message}');
    }
  }

  Future<void> addSpecialHours(SpecialHours hours) async {
    try {
      final dateStr = hours.date.toIso8601String().split('T')[0];
      await _firestore
          .collection('special_hours')
          .doc(dateStr)
          .set(hours.toMap());
    } catch (error, stackTrace) {
      final errorInfo = FirebaseErrorInfo.fromError(error, stackTrace);
      handleFirebaseError(error, stackTrace);
      throw Exception('Failed to add special hours: ${errorInfo.message}');
    }
  }

  Future<void> deleteSpecialHours(DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      await _firestore
          .collection('special_hours')
          .doc(dateStr)
          .delete();
    } catch (error, stackTrace) {
      final errorInfo = FirebaseErrorInfo.fromError(error, stackTrace);
      handleFirebaseError(error, stackTrace);
      throw Exception('Failed to delete special hours: ${errorInfo.message}');
    }
  }

  Future<SpecialHours?> getSpecialHoursForDate(DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final doc = await _firestore
          .collection('special_hours')
          .doc(dateStr)
          .get();
      
      if (doc.exists) {
        return SpecialHours.fromMap(doc.data()!);
      }
      return null;
    } catch (error, stackTrace) {
      final errorInfo = FirebaseErrorInfo.fromError(error, stackTrace);
      handleFirebaseError(error, stackTrace);
      throw Exception('Failed to get special hours: ${errorInfo.message}');
    }
  }
} 