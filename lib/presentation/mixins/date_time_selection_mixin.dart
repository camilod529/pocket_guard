import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager_flutter/presentation/providers/transaction/transaction_form_provider.dart';

mixin DateTimeSelectionMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  DateTime? get selectedDate;
  String get transactionId;

  Future<void> selectDate(BuildContext context, DateTime currentDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && mounted) {
      final newDateTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        currentDate.hour,
        currentDate.minute,
      );
      _updateDateTime(newDateTime);
    }
  }

  Future<void> selectTime(BuildContext context, DateTime currentDate) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentDate),
    );
    if (picked != null && mounted) {
      final newDateTime = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        picked.hour,
        picked.minute,
      );
      _updateDateTime(newDateTime);
    }
  }

  void _updateDateTime(DateTime newDateTime) {
    ref
        .read(
          transactionFormProvider(
            transactionId,
            selectedDate: selectedDate,
          ).notifier,
        )
        .dateChanged(newDateTime);
  }
}
