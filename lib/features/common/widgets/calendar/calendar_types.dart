import 'package:flutter/material.dart';

enum CalendarViewType {
  week,
  month,
}

class LegendItem {
  final String label;
  final Color color;

  const LegendItem(this.label, this.color);
} 