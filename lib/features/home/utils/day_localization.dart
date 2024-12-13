import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DayLocalization {
  static String getLocalizedDay(BuildContext context, String englishDay) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (englishDay.toLowerCase()) {
      case 'monday':
        return l10n.monday;
      case 'tuesday':
        return l10n.tuesday;
      case 'wednesday':
        return l10n.wednesday;
      case 'thursday':
        return l10n.thursday;
      case 'friday':
        return l10n.friday;
      case 'saturday':
        return l10n.saturday;
      case 'sunday':
        return l10n.sunday;
      default:
        return englishDay;
    }
  }

  static List<String> getOrderedDays(bool startWithSunday) {
    final List<String> days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    if (startWithSunday) {
      // Move Sunday to the beginning
      final sunday = days.removeLast();
      days.insert(0, sunday);
    }

    return days;
  }

  static int getDayOrder(String day, bool startWithSunday) {
    final orderedDays = getOrderedDays(startWithSunday);
    return orderedDays.indexOf(day);
  }
} 