import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'calendar_types.dart';
import 'package:intl/intl.dart';

class CalendarHeader extends ConsumerWidget {
  final String id;
  final DateTime currentDate;
  final CalendarViewType viewType;
  final bool isAdmin;
  final Function(CalendarViewType) onViewTypeChanged;
  final Function(int) onNavigateMonth;

  const CalendarHeader({
    super.key,
    required this.id,
    required this.currentDate,
    required this.viewType,
    required this.isAdmin,
    required this.onViewTypeChanged,
    required this.onNavigateMonth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 32,
            child: SegmentedButton<CalendarViewType>(
              segments: [
                ButtonSegment(
                  value: CalendarViewType.week,
                  icon: const Icon(Icons.view_week, size: 16),
                  tooltip: l10n.weekView,
                ),
                ButtonSegment(
                  value: CalendarViewType.month,
                  icon: const Icon(Icons.calendar_view_month, size: 16),
                  tooltip: l10n.monthView,
                ),
              ],
              selected: {viewType},
              onSelectionChanged: (value) => onViewTypeChanged(value.first),
              showSelectedIcon: false,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 8)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              isAdmin ? l10n.appointmentsOverview : l10n.availableDates,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            _formatDate(context, currentDate, viewType),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date, CalendarViewType viewType) {
    final locale = Localizations.localeOf(context).languageCode;
    
    if (viewType == CalendarViewType.week) {
      final endDate = date.add(const Duration(days: 6));
      final startFormatter = DateFormat.MMMd(locale);
      final endFormatter = DateFormat.MMMd(locale);
      return '${startFormatter.format(date)} - ${endFormatter.format(endDate)}';
    } else {
      return DateFormat.yMMMM(locale).format(date);
    }
  }
} 