import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_guard/domain/data_sources/backup_data_source.dart';
import 'package:pocket_guard/domain/repositories/backup_repository.dart';
import 'package:pocket_guard/infrastructure/data_sources/backup_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/platform/incoming_backup_file_channel.dart';
import 'package:pocket_guard/infrastructure/repositories/backup_repository_impl.dart';
import 'package:pocket_guard/presentation/providers/account/account_provider.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/budget/budget_provider.dart';
import 'package:pocket_guard/presentation/providers/budget/budgets_provider.dart';
import 'package:pocket_guard/presentation/providers/category/categories_provider.dart';
import 'package:pocket_guard/presentation/providers/recurring_transaction/recurring_transaction_provider.dart';
import 'package:pocket_guard/presentation/providers/recurring_transaction/recurring_transactions_provider.dart';
import 'package:pocket_guard/presentation/providers/savings_goal/savings_goal_provider.dart';
import 'package:pocket_guard/presentation/providers/savings_goal/savings_goals_provider.dart';
import 'package:pocket_guard/presentation/providers/settings_providers.dart';
import 'package:pocket_guard/presentation/providers/transaction/transaction_provider.dart';
import 'package:pocket_guard/presentation/providers/transaction/transactions_provider.dart';
import 'package:pocket_guard/presentation/providers/wishlist/wishlist_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'backup_provider.g.dart';

@Riverpod(keepAlive: true)
BackupDataSource backupDataSource(Ref ref) {
  return BackupDriftDataSourceImpl();
}

@Riverpod(keepAlive: true)
IncomingBackupFileChannel incomingBackupFileChannel(Ref ref) {
  return IncomingBackupFileChannel();
}

@Riverpod(keepAlive: true)
BackupRepository backupRepository(Ref ref) {
  return BackupRepositoryImpl(
    dataSource: ref.watch(backupDataSourceProvider),
    settings: ref.watch(settingsDataSourceProvider),
  );
}

/// After a restore every cached list and single-item cache may be stale -
/// drop them all so each screen reloads from the database. Families
/// (accountProvider(id), ...) are invalidated for every id at once.
void invalidateAfterRestore(WidgetRef ref) {
  ref
    ..invalidate(accountsProvider)
    ..invalidate(accountProvider)
    ..invalidate(transactionsProvider)
    ..invalidate(transactionProvider)
    ..invalidate(categoriesProvider)
    ..invalidate(categoryProvider)
    ..invalidate(recurringTransactionsProvider)
    ..invalidate(recurringTransactionProvider)
    ..invalidate(budgetsProvider)
    ..invalidate(budgetProvider)
    ..invalidate(savingsGoalsProvider)
    ..invalidate(savingsGoalProvider)
    ..invalidate(wishlistProvider)
    ..invalidate(localeProvider)
    ..invalidate(themeIndexProvider);
}
