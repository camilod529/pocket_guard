import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_guard/domain/entities/account.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/transaction/transaction_form_provider.dart';
import 'package:pocket_guard/presentation/widgets/shared/forms/account_selector_field.dart';
import 'package:pocket_guard/presentation/widgets/shared/forms/category_selector_field.dart';
import 'package:pocket_guard/presentation/widgets/transactions/amount_field.dart';
import 'package:pocket_guard/presentation/widgets/transactions/date_time_fields.dart';
import 'package:pocket_guard/presentation/widgets/transactions/description_field.dart';
import 'package:pocket_guard/utils/shared/transaction_icons.dart';

class IncomeExpenseForm extends ConsumerWidget {
  final TransactionFormState formState;
  final AsyncValue<List<AccountEntity>> accountsAsync;
  final AppLocalizations l10n;
  final AsyncValue<List<CategoryEntity>> categoriesAsync;
  final String transactionId;
  final DateTime? selectedDate;
  final TextEditingController dateController;
  final VoidCallback selectDate;
  final TextEditingController timeController;
  final VoidCallback selectTime;

  const IncomeExpenseForm({
    super.key,
    required this.formState,
    required this.accountsAsync,
    required this.l10n,
    required this.categoriesAsync,
    required this.transactionId,
    required this.dateController,
    this.selectedDate,
    required this.selectDate,
    required this.timeController,
    required this.selectTime,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        AccountSelectorField(
          accountsAsync: accountsAsync,
          l10n: l10n,
          accountId: formState.accountId,
          isFormPure: formState.isFormPure,
          onChanged: (value) {
            ref
                .read(
                  transactionFormProvider(
                    transactionId,
                    selectedDate: selectedDate,
                  ).notifier,
                )
                .accountChanged(value);
          },
        ),
        const SizedBox(height: 16),
        AmountField(
          formState: formState,
          l10n: l10n,
          accountsAsync: accountsAsync,
          transactionId: transactionId,
          selectedDate: selectedDate,
        ),
        const SizedBox(height: 16),
        DescriptionField(
          formState: formState,
          l10n: l10n,
          transactionId: transactionId,
          selectedDate: selectedDate,
        ),
        const SizedBox(height: 24),
        CategorySelectorField(
          categoriesAsync: categoriesAsync,
          l10n: l10n,
          prefixIcon: TransactionIcons.getIconByType(formState.type),
          type: formState.type,
          categoryId: formState.categoryId,
          isFormPure: formState.isFormPure,
          onChanged: (value) => ref
              .read(
                transactionFormProvider(
                  transactionId,
                  selectedDate: selectedDate,
                ).notifier,
              )
              .categoryChanged(value),
        ),
        const SizedBox(height: 16),
        DateTimeFields(
          l10n: l10n,
          dateController: dateController,
          selectDate: selectDate,
          timeController: timeController,
          selectTime: selectTime,
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
