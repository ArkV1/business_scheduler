import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'calendar_types.dart';

class CalendarLegend extends StatelessWidget {
  final bool isAdmin;

  const CalendarLegend({
    super.key,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = isAdmin
        ? <LegendItem>[
            LegendItem(l10n.available, Colors.green),
            LegendItem(l10n.fullyBooked, Colors.orange),
            LegendItem(l10n.pastDate, Colors.grey),
          ]
        : <LegendItem>[
            LegendItem(l10n.calendarAvailable, Colors.green),
            LegendItem(l10n.calendarUnavailable, Colors.red),
            LegendItem(l10n.calendarClosed, Colors.grey),
          ];

    return SizedBox(
      height: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: items.map((item) => _buildLegendItem(context, item)).toList(),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, LegendItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: item.color.withAlpha(51),
              border: Border.all(color: item.color, width: 1),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
} 