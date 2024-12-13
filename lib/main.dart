import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'core/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase and SharedPreferences concurrently
  final [_, prefs] = await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    SharedPreferences.getInstance(),
  ]);
  
  runApp(
    ProviderScope(
      overrides: [
        // Override the provider with the initialized SharedPreferences instance
        sharedPreferencesProvider.overrideWithValue(prefs as SharedPreferences),
      ],
      child: const AppointmentApp(),
    ),
  );
}

