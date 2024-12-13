import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_settings.dart';

class AppSettingsService {
  final FirebaseFirestore _firestore;
  static const String _collection = 'settings';
  static const String _document = 'app_settings';

  AppSettingsService([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _settingsRef =>
      _firestore.collection(_collection).doc(_document);

  Stream<AppSettings> watchAppSettings() {
    return _settingsRef.snapshots().map((snapshot) {
      if (!snapshot.exists) {
        // Initialize with default settings if they don't exist
        final defaultSettings = AppSettings();
        _settingsRef.set(defaultSettings.toJson());
        return defaultSettings;
      }
      return AppSettings.fromJson(snapshot.data()!);
    });
  }

  Future<void> updateAppSettings(AppSettings settings) async {
    await _settingsRef.set(settings.toJson());
  }

  Future<void> updateSetting<T>(String field, T value) async {
    await _settingsRef.update({field: value});
  }

  Future<void> initializeDefaultSettings() async {
    final snapshot = await _settingsRef.get();
    if (!snapshot.exists) {
      await _settingsRef.set(AppSettings().toJson());
    }
  }
} 