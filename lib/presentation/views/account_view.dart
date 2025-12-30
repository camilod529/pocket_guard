import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_guard/config/router/routes.dart';
import 'package:pocket_guard/domain/entities/account.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/widgets/shared/delete_confirmation_modal.dart';
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
      body: accountsAsync.when(
        data: (accounts) =>
            _buildAccountsList(context, accounts, ref, localizations),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            _buildErrorState(context, error, ref, localizations),
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

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: accounts.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final account = accounts[index];
        return _buildAccountTile(context, account, ref, localizations);
      },
    );
  }

  Widget _buildAccountTile(
    BuildContext context,
    AccountEntity account,
    WidgetRef ref,
    AppLocalizations localizations,
  ) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
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
        onSelected: (value) =>
            _onAccountAction(context, value, account.id, ref, localizations),
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
    return Center(
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
    return Center(
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

  void _onAccountAction(
    BuildContext context,
    DropdownActionType action,
    String accountId,
    WidgetRef ref,
    AppLocalizations localizations,
  ) {
    switch (action) {
      case DropdownActionType.edit:
        // Navigate to edit account screen
        context.push(Routes.accountFormPage(accountId));
        break;
      case DropdownActionType.delete:
        _showDeleteConfirmation(context, accountId, ref, localizations);
        break;
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    String accountId,
    WidgetRef ref,
    AppLocalizations localizations,
  ) async {
    await DeleteConfirmationModal.show(
      context: context,
      title: localizations.deleteAccount,
      entity: localizations.accountName,
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
