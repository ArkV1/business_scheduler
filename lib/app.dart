import 'package:flutter/material.dart';
import 'core/router/router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:business_scheduler/core/providers/theme_provider.dart' hide ThemeMode;
import 'package:business_scheduler/core/providers/locale_provider.dart' hide LocaleController;


import 'package:mix/mix.dart';
import 'package:business_scheduler/design/theme/theme.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class AppointmentApp extends ConsumerWidget {
  const AppointmentApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final isDarkMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeControllerProvider);

    return MaterialApp.router(
      title: 'Appointment Booking',
      routerConfig: router,
      locale: locale, // Set the current locale
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('he'), // Hebrew
      ],
      builder: (context, child) {
        return MixTheme(
          data: isDarkMode ? AppTheme.dark : AppTheme.light,
          child: child!,
        );
      },
    );
  }
}