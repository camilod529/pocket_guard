import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/savings_goal/goal_progress_provider.dart';
import 'package:pocket_guard/presentation/providers/savings_goal/savings_goal_form_provider.dart';
import 'package:pocket_guard/presentation/widgets/recurring_transactions/date_row.dart';
import 'package:pocket_guard/presentation/widgets/shared/forms/custom_form_field.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';
import 'package:pocket_guard/utils/shared/number_formatting.dart';

class SavingsGoalFormScreen extends ConsumerWidget {
  final String goalId;

  const SavingsGoalFormScreen({super.key, required this.goalId});

  bool get _isCreating => goalId == GlobalConstants.createId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final formStateAsync = ref.watch(savingsGoalFormProvider(goalId));
    final notifier = ref.read(savingsGoalFormProvider(goalId).notifier);
    final availableCurrencies =
        ref
            .watch(accountsProvider)
            .value
            ?.map((a) => a.currency)
            .toSet()
            .toList() ??
        const <String>[];
    // The data source refuses a currency change once money is in the jar;
    // lock the field up front instead of letting the submit fail.
    final hasMoney =
        !_isCreating &&
        (ref
                .watch(goalProgressProvider)
                .value
                ?.where((p) => p.goal.id == goalId)
                .any((p) => p.saved != 0) ??
            false);

    return formStateAsync.when(
      data: (formState) => Scaffold(
        appBar: AppBar(
          title: Text(_isCreating ? l10n.newGoalTitle : l10n.editGoalTitle),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomFormField(
                  initialValue: formState.name.value,
                  label: l10n.goalNameLabel,
                  hintText: l10n.goalNameHint,
                  errorText: !formState.isFormPure && formState.name.isNotValid
                      ? l10n.goalNameRequired
                      : null,
                  prefixIcon: const Icon(Icons.flag_outlined),
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: notifier.nameChanged,
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return DropdownMenu<String>(
                      width: constraints.maxWidth,
                      initialSelection: formState.currency,
                      label: Text(l10n.currencyLabel),
                      selectOnly: true,
                      enabled: availableCurrencies.isNotEmpty && !hasMoney,
                      helperText: availableCurrencies.isEmpty
                          ? l10n.goalCurrencyNoAccountsHint
                          : hasMoney
                          ? l10n.goalCurrencyLockedHint
                          : null,
                      dropdownMenuEntries: [
                        for (final currency in availableCurrencies)
                          DropdownMenuEntry(value: currency, label: currency),
                      ],
                      onSelected: notifier.currencyChanged,
                    );
                  },
                ),
                const SizedBox(height: 16),
                CustomFormField(
                  initialValue: NumberFormatting.formatNumber(
                    formState.targetAmount.value,
                  ),
                  label: l10n.goalTargetAmountLabel,
                  hintText: l10n.amountHint,
                  errorText:
                      !formState.isFormPure && formState.targetAmount.isNotValid
                      ? l10n.goalAmountError
                      : null,
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      widthFactor: 1,
                      child: Text(formState.currency ?? ''),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  selectAllOnFocus: true,
                  onChanged: (value) {
                    final parsed = NumberFormatting.parseUserInput(
                      value,
                      formState.currency ?? 'USD',
                    );
                    if (parsed != null || value.isEmpty) {
                      notifier.targetAmountChanged(parsed ?? 0);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DateRow(
                  label: l10n.goalTargetDateLabel,
                  date: formState.targetDate,
                  noneLabel: '—',
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: formState.targetDate ?? now,
                      firstDate: DateTime(now.year - 1),
                      lastDate: DateTime(now.year + 50),
                    );
                    if (picked != null) notifier.targetDateChanged(picked);
                  },
                  onClear: formState.targetDate == null
                      ? null
                      : () => notifier.targetDateChanged(null),
                ),
                if (!_isCreating) ...[
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.goalArchivedLabel),
                    subtitle: Text(l10n.goalArchivedSubtitle),
                    value: formState.isArchived,
                    onChanged: notifier.archivedChanged,
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => _handleSubmit(context, ref, l10n),
                  icon: const Icon(Icons.save),
                  label: Text(
                    _isCreating ? l10n.createGoalButton : l10n.updateGoalButton,
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.goals)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: Text(l10n.goals)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(l10n.error_unknown_data),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: Text(l10n.goBackAction),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final success = await ref
        .read(savingsGoalFormProvider(goalId).notifier)
        .onFormSubmit();

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isCreating ? l10n.createGoalButton : l10n.updateGoalButton,
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      context.pop();
      return;
    }

    final submitError = ref
        .read(savingsGoalFormProvider(goalId))
        .value
        ?.submitError;
    // Field validation failures already show inline errors.
    if (submitError == null || submitError == SavingsGoalSubmitError.none) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          submitError == SavingsGoalSubmitError.currencyLocked
              ? l10n.goalErrorCurrencyLocked
              : l10n.error_db_operation_failed,
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}
