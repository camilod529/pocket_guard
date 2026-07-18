import 'package:flutter/material.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/widgets/shared/forms/custom_form_field.dart';

class DateTimeFields extends StatelessWidget {
  final AppLocalizations l10n;
  final TextEditingController dateController;
  final VoidCallback selectDate;
  final TextEditingController timeController;
  final VoidCallback selectTime;

  const DateTimeFields({
    super.key,
    required this.l10n,
    required this.dateController,
    required this.selectDate,
    required this.timeController,
    required this.selectTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDateField(),
        const SizedBox(height: 12),
        _buildTimeField(),
      ],
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: selectDate,
      child: AbsorbPointer(
        child: SizedBox(
          height: 72,
          child: CustomFormField(
            controller: dateController,
            label: l10n.dateLabel,
            hintText: l10n.selectDateHint,
            prefixIcon: const Icon(Icons.calendar_today),
            readOnly: true,
            onChanged: (_) {},
          ),
        ),
      ),
    );
  }

  Widget _buildTimeField() {
    return GestureDetector(
      onTap: selectTime,
      child: AbsorbPointer(
        child: SizedBox(
          height: 72,
          child: CustomFormField(
            controller: timeController,
            label: l10n.timeLabel,
            hintText: l10n.selectTimeHint,
            prefixIcon: const Icon(Icons.access_time),
            readOnly: true,
            onChanged: (_) {},
          ),
        ),
      ),
    );
  }
}
