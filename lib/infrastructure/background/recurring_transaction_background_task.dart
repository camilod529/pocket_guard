import 'package:workmanager/workmanager.dart';
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/services/recurring_transaction_catch_up_service.dart';
import 'package:pocket_guard/infrastructure/data_sources/recurring_transaction_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/data_sources/transaction_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/repositories/recurring_transaction_repository_impl.dart';
import 'package:pocket_guard/infrastructure/repositories/transaction_repository_impl.dart';

const String recurringTransactionsTaskName = 'recurring-transactions-catchup';

/// Best-effort periodic catch-up while the app is closed. Android's
/// WorkManager honors the requested frequency reasonably reliably; iOS's
/// BGTaskScheduler is opportunistic and the OS decides when (or whether) to
/// actually invoke it. The foreground trigger
/// (recurringTransactionCatchUpProvider, watched once from MainApp on every
/// launch) is the *guaranteed* path - this is a supplement, not a
/// replacement, which is fine because the catch-up logic already tolerates
/// arbitrarily long gaps between runs by design (see
/// RecurringTransactionScheduler's backfill behavior).
///
/// Registered from main.dart before runApp(). Android needs no extra
/// manifest entries as of workmanager 0.9.x (auto-merged by its Gradle
/// plugin). iOS needs three native pieces, all in place: Info.plist declares
/// UIBackgroundModes (fetch, processing) and this task's identifier under
/// BGTaskSchedulerPermittedIdentifiers, and AppDelegate.swift calls
/// WorkmanagerPlugin.registerPeriodicTask(withIdentifier:frequency:) during
/// didFinishLaunchingWithOptions - BGTaskScheduler requires that
/// registration to happen natively before the app finishes launching, which
/// Dart's Workmanager().registerPeriodicTask() call below can't do by
/// itself. All three identifiers (Info.plist, AppDelegate.swift, and
/// recurringTransactionsTaskName here) must stay in sync.
@pragma('vm:entry-point')
void recurringTransactionCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName != recurringTransactionsTaskName) return true;

    // Runs in a separate isolate with no access to the app's
    // ProviderScope, so repositories are constructed directly rather than
    // read from Riverpod - this only works cleanly because the data
    // sources take an injectable AppDatabase constructor param and
    // RecurringTransactionCatchUpService has no Riverpod dependency.
    final appDatabase = AppDatabase();
    final service = RecurringTransactionCatchUpService(
      recurringTransactionRepository: RecurringTransactionRepositoryImpl(
        dataSource: RecurringTransactionDriftDataSourceImpl(
          database: appDatabase,
        ),
      ),
      transactionRepository: TransactionRepositoryImpl(
        dataSource: TransactionDriftDataSourceImpl(database: appDatabase),
      ),
    );

    await service.run(now: DateTime.now());
    return true;
  });
}
