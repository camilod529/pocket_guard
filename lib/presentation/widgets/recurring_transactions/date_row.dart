import 'package:flutter/material.dart';
import 'package:pocket_guard/utils/shared/dates/calendar_date_formatter.dart';

class DateRow extends StatelessWidget {
  final String label;
  final DateTime? date;
  final String? noneLabel;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const DateRow({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
    this.noneLabel,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = CalendarDateFormatter(Localizations.localeOf(context));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    date != null
                        ? formatter.formatFullDate(date!)
                        : (noneLabel ?? ''),
                  ),
                ),
                if (onClear != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: onClear,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
