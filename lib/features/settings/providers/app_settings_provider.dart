import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import '../services/app_settings_service.dart';

final appSettingsServiceProvider = Provider<AppSettingsService>((ref) {
  return AppSettingsService();
});

final appSettingsProvider = StreamProvider<AppSettings>((ref) {
  final service = ref.watch(appSettingsServiceProvider);
  return service.watchAppSettings();
});

final startWeekWithSundayProvider = Provider<bool>((ref) {
  return ref.watch(appSettingsProvider).maybeWhen(
    data: (settings) => settings.startWeekWithSunday,
    orElse: () => true,
  );
}); 