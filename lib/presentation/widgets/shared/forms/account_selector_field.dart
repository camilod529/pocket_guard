import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_guard/domain/entities/account.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';

/// Shared account selector used by both the transaction and recurring
/// transaction forms - unified from two near-identical private
/// implementations that only differed in which concrete form state type
/// they carried, even though both only ever read `isFormPure` off it.
///
/// Keyed by account id (String) rather than AccountEntity itself:
/// DropdownMenu matches/highlights entries by `==` on its value type, and
/// AccountEntity doesn't override `==`/hashCode (default identity
/// equality), which would make selection matching fragile across rebuilds
/// with freshly-fetched entity instances.
class AccountSelectorField extends StatelessWidget {
  final AsyncValue<List<AccountEntity>> accountsAsync;
  final AppLocalizations l10n;
  final String? accountId;
  final bool isFormPure;
  final void Function(String) onChanged;
  final String? targetCurrency;
  final String? labelOverride;

  const AccountSelectorField({
    super.key,
    required this.accountsAsync,
    required this.l10n,
    required this.accountId,
    required this.isFormPure,
    required this.onChanged,
    this.targetCurrency,
    this.labelOverride,
  });

  @override
  Widget build(BuildContext context) {
    return accountsAsync.when(
      data: (accounts) => _buildDropdown(context, accounts),
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildDropdown(BuildContext context, List<AccountEntity> accounts) {
    final filteredAccounts = accounts.where((account) {
      return targetCurrency == null || account.currency == targetCurrency;
    }).toList();
    final showError = accountId == null && !isFormPure;

    return LayoutBuilder(
      builder: (context, constraints) {
        return DropdownMenu<String>(
          width: constraints.maxWidth,
          initialSelection: filteredAccounts.any((a) => a.id == accountId)
              ? accountId
              : null,
          label: Text(labelOverride ?? l10n.accountLabel('')),
          hintText: l10n.selectAccountHint,
          errorText: showError ? l10n.selectAccountError : null,
          leadingIcon: const Icon(Icons.account_balance_wallet),
          enableFilter: true,
          requestFocusOnTap: true,
          dropdownMenuEntries: filteredAccounts
              .map(
                (account) => DropdownMenuEntry<String>(
                  value: account.id,
                  label: '${account.name} (${account.currency})',
                ),
              )
              .toList(),
          onSelected: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        );
      },
    );
  }

  Widget _buildErrorState(Object error) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelOverride ?? l10n.accountLabel(''),
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(l10n.errorLoadingAccounts(error.toString())),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelOverride ?? l10n.accountLabel(''),
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        const LinearProgressIndicator(),
      ],
    );
  }
}
