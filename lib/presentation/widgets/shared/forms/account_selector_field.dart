import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_guard/domain/entities/account.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/widgets/shared/forms/common_drop_down.dart';

/// Shared account dropdown used by both the transaction and recurring
/// transaction forms - unified from two near-identical private
/// implementations that only differed in which concrete form state type
/// they carried, even though both only ever read `isFormPure` off it.
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
      data: (accounts) => _buildAccountDropdown(context, accounts),
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildAccountDropdown(
    BuildContext context,
    List<AccountEntity> accounts,
  ) {
    final showError = accountId == null && !isFormPure;

    final filteredAccounts = accounts.where((account) {
      return targetCurrency == null || account.currency == targetCurrency;
    }).toList();

    return IntrinsicHeight(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            labelOverride ?? l10n.accountLabel(''),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 72,
            child: DropdownButtonFormField<String>(
              key: ValueKey(filteredAccounts.map((a) => a.id).join(',')),
              initialValue: filteredAccounts.any((a) => a.id == accountId)
                  ? accountId
                  : null,
              decoration: DropdownDecorationHelper.getDecoration(
                hintText: l10n.selectAccountHint,
                prefixIcon: const Icon(Icons.account_balance_wallet),
              ),
              isExpanded: true,
              items: filteredAccounts
                  .map(
                    (account) => DropdownMenuItem(
                      value: account.id,
                      child: Text('${account.name} (${account.currency})'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                }
              },
            ),
          ),
          if (showError)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 8),
              child: Text(
                l10n.selectAccountError,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
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
