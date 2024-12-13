import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CalendarViewType {
  week,
  month,
}

final calendarViewTypeProvider = StateProvider.family<CalendarViewType, String>((ref, id) => CalendarViewType.week);

final weekOffsetProvider = StateProvider.family<int, String>((ref, id) => 0);

final currentMonthProvider = StateProvider.family<DateTime, String>((ref, id) => DateTime.now());

final selectedDateProvider = StateProvider.family<DateTime?, String>((ref, id) => null); 