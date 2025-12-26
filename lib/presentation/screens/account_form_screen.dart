import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_manager_flutter/l10n/app_localizations.dart';
import 'package:money_manager_flutter/presentation/providers/account/account_form_provider.dart';
import 'package:money_manager_flutter/presentation/providers/account/accounts_provider.dart';
import 'package:money_manager_flutter/presentation/widgets/shared/delete_confirmation_modal.dart';
import 'package:money_manager_flutter/presentation/widgets/shared/forms/custom_form_field.dart';
import 'package:money_manager_flutter/utils/constants/global_constants.dart';
import 'package:money_manager_flutter/utils/shared/number_formatting.dart';

class AccountFormScreen extends ConsumerWidget {
  final String accountId; // "create" or real UUID

  const AccountFormScreen({super.key, required this.accountId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final isCreating = accountId == GlobalConstants.createId;

    final formStateAsync = ref.watch(accountFormProvider(accountId));

    return formStateAsync.when(
      data: (formState) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              isCreating ? localizations.accountName : localizations.accounts,
            ),
            actions: [
              if (!isCreating)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _handleDelete(
                    context,
                    formState,
                    localizations,
                    () => ref
                        .read(accountsProvider.notifier)
                        .deleteAccount(accountId),
                  ),
                ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomFormField(
                    initialValue: formState.name.value,
                    label: localizations.accountName,
                    hintText: localizations.accountNameHint,
                    errorText:
                        formState.name.error != null && !formState.isFormPure
                        ? 'Name is required and must be 2-50 characters'
                        : null,
                    prefixIcon: const Icon(
                      Icons.account_balance_wallet_outlined,
                    ),
                    keyboardType: TextInputType.name,
                    onChanged: (value) {
                      ref
                          .read(accountFormProvider(accountId).notifier)
                          .nameChanged(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomFormField(
                    initialValue: formState.currency.value,
                    label: localizations.accountCurrency,
                    hintText: localizations.accountCurrencyHint,
                    errorText:
                        formState.currency.error != null &&
                            !formState.isFormPure
                        ? 'Enter 3-letter currency code (USD, EUR, GBP)'
                        : null,
                    prefixIcon: const Icon(Icons.currency_exchange_outlined),
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (value) => ref
                        .read(accountFormProvider(accountId).notifier)
                        .currencyChanged(value),
                  ),
                  const SizedBox(height: 16),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: CustomFormField(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                            initialValue: NumberFormatting.formatNumber(
                              formState.balance.value,
                            ),
                            label: localizations.amountLabel,
                            hintText: localizations.amountHint,
                            prefixIcon: const Icon(Icons.attach_money_outlined),
                            keyboardType: const TextInputType.numberWithOptions(
                              signed: true,
                              decimal: true,
                            ),
                            onChanged: (value) {
                              final parsedValue =
                                  NumberFormatting.parseUserInput(
                                    value,
                                    formState.currency.value.isEmpty
                                        ? 'USD'
                                        : formState.currency.value,
                                  );
                              if (parsedValue != null || value.isEmpty) {
                                ref
                                    .read(
                                      accountFormProvider(accountId).notifier,
                                    )
                                    .balanceChanged(
                                      parsedValue ?? formState.balance.value,
                                    );
                              }
                            },
                          ),
                        ),
                        Container(
                          width: 64, // Fixed width for consistency
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Center(
                            // Center vertically within the full height
                            child: Text(
                              formState.currency.value.isEmpty
                                  ? 'USD'
                                  : formState.currency.value,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: formState.isFormValid
                        ? () => _handleSubmit(context, ref)
                        : null,
                    icon: const Icon(Icons.save),
                    label: Text(
                      isCreating ? 'Create Account' : 'Update Account',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(localizations.accountName)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: Text(localizations.accountName)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading account: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    AccountFormState formState,
    AppLocalizations l10n,
    Future<void> Function() onSubmit,
  ) async {
    await DeleteConfirmationModal.show(
      context: context,
      title: l10n.deleteTransactionTitle,
      entity: formState.name.value.isEmpty
          ? l10n.thisTransaction
          : formState.name.value,
      description: l10n.deleteTransactionDescription,
      onConfirm: () async {
        try {
          await onSubmit();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.accountDeletedSuccessfully),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            context.pop();
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.transactionDeleteError(e.toString())),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    );
  }

  Future<void> _handleSubmit(BuildContext context, WidgetRef ref) async {
    final success = await ref
        .read(accountFormProvider(accountId).notifier)
        .onFormSubmit();

    if (success && context.mounted) {
      final message = accountId == GlobalConstants.createId
          ? 'Account created successfully!'
          : 'Account updated successfully!';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      context.pop();
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save account'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
