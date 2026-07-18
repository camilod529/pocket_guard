import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/transaction/transaction_form_provider.dart';
import 'package:pocket_guard/presentation/widgets/shared/forms/custom_form_field.dart';

class DescriptionField extends ConsumerWidget {
  final TransactionFormState formState;
  final AppLocalizations l10n;
  final String transactionId;
  final DateTime? selectedDate;

  const DescriptionField({
    super.key,
    required this.formState,
    required this.l10n,
    required this.transactionId,
    this.selectedDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomFormField(
      initialValue: formState.description.value,
      label: l10n.descriptionLabel,
      hintText: l10n.descriptionHint,
      errorText: formState.isFormPure ? null : formState.descriptionError,
      prefixIcon: const Icon(Icons.notes_outlined),
      keyboardType: TextInputType.text,
      maxLines: 2,
      onChanged: (value) => ref
          .read(
            transactionFormProvider(
              transactionId,
              selectedDate: selectedDate,
            ).notifier,
          )
          .descriptionChanged(value),
    );
  }
}
