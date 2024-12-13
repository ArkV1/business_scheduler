class TimeSlotSection {
  final String hour;
  final List<String> slots;

  const TimeSlotSection({
    required this.hour,
    required this.slots,
  });

  String get displayHour {
    final hourInt = int.parse(hour);
    final period = hourInt >= 12 ? 'PM' : 'AM';
    final displayHour = hourInt > 12 ? hourInt - 12 : hourInt;
    return '$displayHour $period';
  }
} 