import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/opening_hours.dart';
import '../models/special_hours.dart';
import '../providers/opening_hours_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart' hide TextDirection; 

class OpeningHoursDisplay extends ConsumerWidget {
  final List<OpeningHours> hours;
  final bool showTitle;
  final bool showToday;
  final bool useShortDayNames;

  const OpeningHoursDisplay({
    super.key,
    required this.hours,
    this.showTitle = true,
    this.showToday = false,
    this.useShortDayNames = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final today = DateTime.now();
    final todayHours = ref.watch(effectiveHoursProvider(today));
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Column(
      crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showTitle) ...[
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                l10n.openingHoursTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Center(
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...hours.asMap().entries.map((entry) {
                  final isLast = entry.key == hours.length - 1;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: _DayHoursDisplay(
                          hours: entry.value,
                          useShortDayName: useShortDayNames,
                        ),
                      ),
                      if (!isLast)
                        const Divider(
                          height: 1,
                          thickness: 1,
                        ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TodayHoursDisplay extends StatelessWidget {
  final OpeningHours hours;

  const _TodayHoursDisplay({required this.hours});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Column(
      crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.openingHoursToday,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        if (hours.isClosed)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                l10n.openingHoursClosed,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          )
        else
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                l10n.openingHoursTimeRange(
                  hours.openTime,
                  hours.closeTime,
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        if (hours.note != null) ...[
          const SizedBox(height: 4),
          Text(
            l10n.openingHoursNote(hours.note!),
            style: theme.textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: theme.hintColor,
            ),
          ),
        ],
      ],
    );
  }
}

class _DayHoursDisplay extends StatelessWidget {
  final OpeningHours hours;
  final bool useShortDayName;

  const _DayHoursDisplay({
    required this.hours,
    this.useShortDayName = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    final isToday = hours.dayOfWeek.toLowerCase() ==
        _getLocalizedDayOfWeek(context, DateTime.now().weekday, false).toLowerCase();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        children: [
          SizedBox(
            width: useShortDayName ? 40 : 100,
            child: Text(
              _getLocalizedDayOfWeek(
                context,
                _dayOfWeekToNumber(hours.dayOfWeek),
                useShortDayName,
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                color: isToday ? theme.primaryColor : null,
              ),
              textAlign: isRTL ? TextAlign.right : TextAlign.left,
            ),
          ),
          Expanded(
            child: hours.isClosed
                ? Text(
                    l10n.openingHoursClosed,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: isRTL ? TextAlign.right : TextAlign.left,
                  )
                : Text(
                    l10n.openingHoursTimeRange(
                      hours.openTime,
                      hours.closeTime,
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isToday ? theme.primaryColor : null,
                    ),
                    textAlign: isRTL ? TextAlign.right : TextAlign.left,
                  ),
          ),
          if (hours.note != null)
            Expanded(
              child: Text(
                hours.note!,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.hintColor,
                ),
                textAlign: isRTL ? TextAlign.left : TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }
}

String _getLocalizedDayOfWeek(BuildContext context, int weekday, bool useShortName) {
  final date = DateTime(2024, 1, weekday + (weekday == 7 ? 0 : 7)); // Ensure we get the right weekday
  return DateFormat(useShortName ? 'E' : 'EEEE').format(date);
}

int _dayOfWeekToNumber(String dayOfWeek) {
  switch (dayOfWeek.toLowerCase()) {
    case 'monday':
      return DateTime.monday;
    case 'tuesday':
      return DateTime.tuesday;
    case 'wednesday':
      return DateTime.wednesday;
    case 'thursday':
      return DateTime.thursday;
    case 'friday':
      return DateTime.friday;
    case 'saturday':
      return DateTime.saturday;
    case 'sunday':
      return DateTime.sunday;
    default:
      return DateTime.monday;
  }
} 