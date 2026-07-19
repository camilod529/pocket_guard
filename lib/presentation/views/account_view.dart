import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_guard/config/router/routes.dart';
import 'package:pocket_guard/domain/entities/account.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/widgets/shared/delete_confirmation_modal.dart';
import 'package:pocket_guard/presentation/widgets/shared/refreshable_placeholder.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';
import 'package:pocket_guard/utils/types/general_types.dart';

class AccountView extends ConsumerWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: _buildAppBar(context, localizations),
      body: RefreshIndicator(
        onRefresh: () => ref.read(accountsProvider.notifier).refresh(),
        child: accountsAsync.when(
          data: (accounts) =>
              _buildAccountsList(context, accounts, ref, localizations),
          loading: () => const RefreshablePlaceholder(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) =>
              _buildErrorState(context, error, ref, localizations),
        ),
      ),
    );
  }

  Widget _buildAccountsList(
    BuildContext context,
    List<AccountEntity> accounts,
    WidgetRef ref,
    AppLocalizations localizations,
  ) {
    if (accounts.isEmpty) {
      return _buildEmptyState(context, ref, localizations);
    }

    final categories = AccountType.values;

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 80),
      itemCount: categories.length,
      itemBuilder: (context, catIndex) {
        final type = categories[catIndex];
        // Filter and Sort based on the sortOrder property in your DB
        final typeAccounts = accounts.where((a) => a.type == type).toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

        if (typeAccounts.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 4.0,
              ),
              child: Text(
                _getCategoryName(
                  type,
                  localizations,
                ), // Helper for localized names
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Card(
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.only(bottom: 24),
              child: ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: typeAccounts.length,
                onReorder: (oldIndex, newIndex) {
                  ref
                      .read(accountsProvider.notifier)
                      .reorderAccounts(oldIndex, newIndex, typeAccounts);
                },
                itemBuilder: (context, index) {
                  final account = typeAccounts[index];
                  return _buildAccountTile(
                    context,
                    account: account,
                    ref: ref,
                    localizations: localizations,
                    key: ValueKey(account.id),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAccountTile(
    BuildContext context, {
    required AccountEntity account,
    required WidgetRef ref,
    required AppLocalizations localizations,
    required Key key,
  }) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      key: key,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: colors.primaryContainer,
        foregroundColor: colors.onPrimaryContainer,
        child: Text(
          account.name.isNotEmpty ? account.name[0].toUpperCase() : '?',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        account.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(account.currency),
      trailing: PopupMenuButton<DropdownActionType>(
        icon: const Icon(Icons.more_vert),
        onSelected: (value) => _onAccountAction(
          context,
          value,
          account.id,
          account.name,
          ref,
          localizations,
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: DropdownActionType.edit,
            child: Row(
              children: [
                const Icon(Icons.edit, size: 20),
                const SizedBox(width: 8),
                Text(localizations.edit),
              ],
            ),
          ),
          PopupMenuItem(
            value: DropdownActionType.delete,
            child: Row(
              children: [
                const Icon(Icons.delete, size: 20, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  localizations.delete,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
      onTap: () {
        // Navigate to account details or edit screen
        context.push(Routes.accountFormPage(account.id));
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return AppBar(
      title: Text(localizations.accounts),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            // Navigate to create account screen
            context.push(Routes.accountFormPage(GlobalConstants.createId));
          },
          tooltip: localizations.accounts, // Reuse accounts as tooltip
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations localizations,
  ) {
    return RefreshablePlaceholder(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            localizations.accounts, // Reuse "Accounts" for empty state
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to create account screen
              context.push(Routes.accountFormPage(GlobalConstants.createId));
            },
            icon: const Icon(Icons.add),
            label: Text(localizations.accounts),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    Object error,
    WidgetRef ref,
    AppLocalizations localizations,
  ) {
    return RefreshablePlaceholder(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            localizations.error_unknown_data,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(accountsProvider),
            child: Text(localizations.error_db_operation_failed),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(AccountType type, AppLocalizations localizations) {
    switch (type) {
      case AccountType.cash:
        return localizations.accountTypeCash;
      case AccountType.asset:
        return localizations.accountTypeAsset;
      case AccountType.credit:
        return localizations.accountTypeCredit;
    }
  }

  void _onAccountAction(
    BuildContext context,
    DropdownActionType action,
    String accountId,
    String accountName,
    WidgetRef ref,
    AppLocalizations localizations,
  ) {
    switch (action) {
      case DropdownActionType.edit:
        // Navigate to edit account screen
        context.push(Routes.accountFormPage(accountId));
        break;
      case DropdownActionType.delete:
        _showDeleteConfirmation(
          context,
          accountId,
          accountName,
          ref,
          localizations,
        );
        break;
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    String accountId,
    String accountName,
    WidgetRef ref,
    AppLocalizations localizations,
  ) async {
    final entity = accountName.isEmpty
        ? localizations.thisAccount
        : accountName;
    await DeleteConfirmationModal.show(
      context: context,
      title: localizations.deleteAccountTitle,
      entity: entity,
      description: localizations.deleteAccountConfirmation(entity),
      onConfirm: () async {
        try {
          await ref.read(accountsProvider.notifier).deleteAccount(accountId);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(localizations.deleteAccountSuccess)),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(localizations.error_db_operation_failed)),
            );
          }
        }
      },
    );
  }
}
