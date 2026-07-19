import 'package:pocket_guard/domain/services/recurring_transaction_catch_up_service.dart';
import 'package:pocket_guard/infrastructure/services/logger_service_impl.dart';
import 'package:pocket_guard/presentation/providers/account/accounts_provider.dart';
import 'package:pocket_guard/presentation/providers/recurring_transaction/recurring_transactions_provider.dart';
import 'package:pocket_guard/presentation/providers/transaction/transactions_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recurring_transaction_catch_up_provider.g.dart';

/// Seam the tests override to simulate "the app hasn't been opened in a
/// while" without waiting on the real clock.
@Riverpod(keepAlive: true)
DateTime currentDateTime(Ref ref) => DateTime.now();

/// Runs once per app process (keepAlive - re-watching this from a rebuilt
/// widget is a cache hit, not a re-run) to catch up any recurring
/// transactions that are due. This is the *guaranteed* trigger; a periodic
/// background task (see lib/infrastructure/background/) is a best-effort
/// supplement for while the app is closed, not a replacement for this one.
@Riverpod(keepAlive: true)
Future<void> recurringTransactionCatchUp(Ref ref) async {
  final logger = LoggerServiceImpl('RecurringTransactionCatchUp');
  try {
    final service = RecurringTransactionCatchUpService(
      recurringTransactionRepository: ref.read(
        recurringTransactionRepositoryProvider,
      ),
      transactionRepository: ref.read(transactionRepositoryProvider),
    );
    final summary = await service.run(now: ref.read(currentDateTimeProvider));

    if (summary.generatedCount > 0) {
      ref.invalidate(transactionsProvider);
      ref.invalidate(accountsProvider);
      logger.info(
        'Generated ${summary.generatedCount} recurring transaction(s) '
        'from ${summary.touchedRuleIds.length} rule(s)',
      );
    }
  } catch (e, stackTrace) {
    // Must never block app render - log and move on.
    logger.error(
      'Recurring transaction catch-up failed',
      error: e,
      stackTrace: stackTrace,
    );
  }
}
