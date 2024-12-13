import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

@Riverpod(keepAlive: true)
class ThemeMode extends _$ThemeMode {
  static const _themeKey = 'theme_mode';

  @override
  bool build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getBool(_themeKey) ?? false;
  }

  void toggleTheme() {
    final prefs = ref.read(sharedPreferencesProvider);
    state = !state;
    prefs.setBool(_themeKey, state);
  }
}

// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});