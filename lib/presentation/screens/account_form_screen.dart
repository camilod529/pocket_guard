import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_manager_flutter/l10n/app_localizations.dart';
import 'package:money_manager_flutter/presentation/providers/account/account_form_provider.dart';
import 'package:money_manager_flutter/presentation/providers/account/account_providers.dart';
import 'package:money_manager_flutter/presentation/widgets/shared/forms/custom_form_field.dart';

class AccountFormScreen extends ConsumerStatefulWidget {
  final String accountId; // Always has ID: "create" or real UUID

  const AccountFormScreen({super.key, required this.accountId});

  @override
  ConsumerState<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends ConsumerState<AccountFormScreen> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final formState = ref.watch(accountFormProvider);

    // 🚀 SUCCESS NAVIGATION LISTENER
    ref.listen<AccountFormState>(accountFormProvider, (previous, next) {
      // Detect successful submission: was submitting → now not submitting
      if (previous?.isSubmitting == true &&
          next.isSubmitting == false &&
          next.isValid == true &&
          mounted &&
          context.mounted) {
        final message = widget.accountId == 'create'
            ? 'Account created successfully!'
            : 'Account updated successfully!';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate back to accounts list
        context.pop();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.accountId == 'create'
              ? localizations.accountName
              : localizations.accounts,
        ),
        actions: [
          TextButton(
            onPressed: formState.isValid && !formState.isSubmitting
                ? () => ref.read(accountFormProvider.notifier).submit()
                : null,
            child: formState.isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.accountId == 'create' ? 'Create' : 'Update'),
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
                errorText: (formState.name.error != null)
                    ? 'Name is required and must be 2-50 characters'
                    : null,
                showError:
                    !formState.name.isPure && formState.name.error != null,
                prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                keyboardType: TextInputType.name,
                onChanged: ref.read(accountFormProvider.notifier).nameChanged,
              ),
              const SizedBox(height: 16),
              CustomFormField(
                initialValue: formState.currency.value,
                label: localizations.accountCurrency,
                hintText: localizations.accountCurrencyHint,
                errorText: (formState.currency.error != null)
                    ? 'Enter 3-letter currency code (USD, EUR, GBP)'
                    : null,
                showError:
                    !formState.currency.isPure &&
                    formState.currency.error != null,
                prefixIcon: const Icon(Icons.currency_exchange_outlined),
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                onChanged: ref
                    .read(accountFormProvider.notifier)
                    .currencyChanged,
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: formState.isValid && !formState.isSubmitting
                    ? () => ref.read(accountFormProvider.notifier).submit()
                    : null,
                icon: const Icon(Icons.save),
                label: Text(
                  widget.accountId == 'create'
                      ? 'Create Account'
                      : 'Update Account',
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
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isEditing = widget.accountId != 'create';
      if (isEditing) {
        // Load existing account
        _loadAccount(widget.accountId);
        ref.read(accountFormProvider.notifier).setEditing(widget.accountId);
      }
    });
  }

  Future<void> _loadAccount(String accountId) async {
    try {
      final account = await ref
          .read(accountProvider.notifier)
          .getAccountById(accountId);
      if (account != null && mounted) {
        ref.read(accountFormProvider.notifier).nameChanged(account.name);
        ref
            .read(accountFormProvider.notifier)
            .currencyChanged(account.currency);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load account')));
      }
    }
  }
}
