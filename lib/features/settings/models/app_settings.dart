import 'package:cloud_firestore/cloud_firestore.dart';

class AppSettings {
  final bool startWeekWithSunday;

  AppSettings({
    this.startWeekWithSunday = true,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      startWeekWithSunday: json['startWeekWithSunday'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startWeekWithSunday': startWeekWithSunday,
    };
  }

  AppSettings copyWith({
    bool? startWeekWithSunday,
  }) {
    return AppSettings(
      startWeekWithSunday: startWeekWithSunday ?? this.startWeekWithSunday,
    );
  }
} 