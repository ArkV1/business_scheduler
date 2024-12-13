import 'package:flutter/material.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:appointment_app/core/providers/theme_provider.dart';

part 'locale_provider.g.dart';

@riverpod
class LocaleController extends _$LocaleController {
  static const _localeKey = 'selected_locale';
  
  @override
  Locale build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedLocale = prefs.getString(_localeKey);
    return savedLocale != null ? Locale(savedLocale) : const Locale('en');
  }

  Future<void> toggleLocale() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final currentLocale = state.languageCode;
    final newLocale = currentLocale == 'en' ? const Locale('he') : const Locale('en');
    await prefs.setString(_localeKey, newLocale.languageCode);
    state = newLocale;
  }
}