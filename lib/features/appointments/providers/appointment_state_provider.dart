import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/models/business_service.dart';

// Appointment state providers
final selectedTimeSlotProvider = StateProvider<String?>((ref) => null);
final selectedServiceProvider = StateProvider<BusinessService?>((ref) => null);

// Date helper providers
final isDateTodayProvider = Provider.family<bool, DateTime>((ref, date) {
  final now = DateTime.now();
  return date.year == now.year && date.month == now.month && date.day == now.day;
});

final isPastDateProvider = Provider.family<bool, DateTime>((ref, date) {
  final now = DateTime.now();
  return date.isBefore(DateTime(now.year, now.month, now.day));
}); 