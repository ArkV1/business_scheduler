import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/opening_hours.dart';
import '../models/special_hours.dart';
import '../services/hours_service.dart';

// Provider for HoursService
final hoursServiceProvider = Provider<HoursService>((ref) => HoursService());

// Stream of regular opening hours
final openingHoursStreamProvider = StreamProvider<List<OpeningHours>>((ref) {
  final service = ref.watch(hoursServiceProvider);
  return service.getOpeningHours();
});

// Stream of special hours for the current month
final specialHoursStreamProvider = StreamProvider<List<SpecialHours>>((ref) {
  final service = ref.watch(hoursServiceProvider);
  return service.getSpecialHours();
});

// Provider to check if a specific date has special hours
final specialHoursForDateProvider = FutureProvider.family<SpecialHours?, DateTime>((ref, date) {
  final service = ref.watch(hoursServiceProvider);
  return service.getSpecialHoursForDate(date);
});

String _getDayOfWeek(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return 'Monday';
    case DateTime.tuesday:
      return 'Tuesday';
    case DateTime.wednesday:
      return 'Wednesday';
    case DateTime.thursday:
      return 'Thursday';
    case DateTime.friday:
      return 'Friday';
    case DateTime.saturday:
      return 'Saturday';
    case DateTime.sunday:
      return 'Sunday';
    default:
      return 'Monday';
  }
}

// Provider to get effective hours for a specific date (combining regular and special hours)
final effectiveHoursProvider = Provider.family<OpeningHours?, DateTime>((ref, date) {
  final openingHours = ref.watch(openingHoursStreamProvider).value;
  final specialHours = ref.watch(specialHoursForDateProvider(date)).value;
  
  if (specialHours != null) {
    // If we have special hours for this date, create a modified OpeningHours
    return OpeningHours(
      id: specialHours.id,
      dayOfWeek: _getDayOfWeek(date.weekday),
      isClosed: specialHours.isClosed,
      openTime: specialHours.openTime ?? '',
      closeTime: specialHours.closeTime ?? '',
      order: date.weekday,
      note: specialHours.note,
    );
  }

  // Otherwise, return regular hours for this weekday
  if (openingHours == null) return null;
  
  return openingHours.firstWhere(
    (hours) => hours.dayOfWeek.toLowerCase() == _getDayOfWeek(date.weekday).toLowerCase(),
    orElse: () => OpeningHours(
      id: '',
      dayOfWeek: _getDayOfWeek(date.weekday),
      isClosed: true,
      openTime: '',
      closeTime: '',
      order: date.weekday,
    ),
  );
}); 