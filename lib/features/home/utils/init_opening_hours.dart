import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/opening_hours.dart';
import '../../../core/utils/firebase_error_handler.dart';

class OpeningHoursInitializer {
  static Future<void> initializeOpeningHours() async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final hoursRef = FirebaseFirestore.instance.collection('opening_hours');

      final defaultHours = DefaultOpeningHours.defaultHours;

      print('Starting to initialize ${defaultHours.length} days'); // Debug log

      for (var hours in defaultHours) {
        final docRef = hoursRef.doc(hours.dayOfWeek.toLowerCase());
        final data = hours.toFirestore();
        print('Adding hours for ${hours.dayOfWeek}: $data'); // Debug log
        batch.set(docRef, data);
      }

      print('Committing batch write...'); // Debug log
      await batch.commit();
      print('Successfully initialized opening hours'); // Debug log
    } catch (error, stackTrace) {
      print('Error initializing opening hours: $error'); // Debug log
      print('Stack trace: $stackTrace'); // Debug log
      final errorInfo = FirebaseErrorInfo.fromError(error, stackTrace);
      handleFirebaseError(error, stackTrace);
      throw Exception('Failed to initialize opening hours: ${errorInfo.message}');
    }
  }
}

class DefaultOpeningHours {
  static List<OpeningHours> get defaultHours => [
        OpeningHours(
          id: 'sunday',
          dayOfWeek: 'Sunday',
          openTime: '10:00',
          closeTime: '21:00',
          isClosed: false,
          order: 1,
        ),
        OpeningHours(
          id: 'monday',
          dayOfWeek: 'Monday',
          openTime: '09:00',
          closeTime: '21:00',
          isClosed: false,
          order: 2,
        ),
        OpeningHours(
          id: 'tuesday',
          dayOfWeek: 'Tuesday',
          openTime: '09:00',
          closeTime: '20:00',
          isClosed: false,
          order: 3,
        ),
        OpeningHours(
          id: 'wednesday',
          dayOfWeek: 'Wednesday',
          openTime: '09:00',
          closeTime: '21:00',
          isClosed: false,
          order: 4,
        ),
        OpeningHours(
          id: 'thursday',
          dayOfWeek: 'Thursday',
          openTime: '09:00',
          closeTime: '18:00',
          isClosed: false,
          order: 5,
        ),
        OpeningHours(
          id: 'friday',
          dayOfWeek: 'Friday',
          isClosed: true,
          openTime: '',
          closeTime: '',
          order: 6,
        ),
        OpeningHours(
          id: 'saturday',
          dayOfWeek: 'Saturday',
          isClosed: true,
          openTime: '',
          closeTime: '',
          order: 7,
        ),
      ];
} 