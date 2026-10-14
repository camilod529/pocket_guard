# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

PocketGuard (`pocket_guard`) — a personal finance manager Flutter app: accounts, categorized income/expense/transfer transactions, monthly insights, multi-currency support, theming and localization (en/es/fr).

## Commands

```bash
flutter pub get                 # install dependencies

# Code generation (required after editing @riverpod classes, Drift tables,
# or anything with a part '*.g.dart' directive)
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs   # while iterating

flutter gen-l10n                # regenerate lib/l10n/app_localizations*.dart after editing the .arb files

flutter analyze                 # static analysis (flutter_lints)
flutter run                     # run on a connected device/simulator
flutter build appbundle --release   # Android release build (used by CI)

flutter test                    # unit + widget tests under test/ (CI runs this)

# End-to-end runs of the real app on a simulator (they write to the app's
# real database), with a screenshot per step in build/goal_screenshots/.
# Not run by CI. iOS needs CocoaPods. Targets: savings_goals_test.dart,
# wishlist_test.dart, backup_test.dart.
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/<name>_test.dart -d <device-id>
```

## Architecture

Strict layered/clean architecture under `lib/`:

- **`domain/`** — framework-free contracts: `entities/` (plain Dart classes: `TransactionEntity`, `AccountEntity`, `CategoryEntity`, `TransactionFilter`, ...), `repositories/` (abstract repository interfaces), `data_sources/` (abstract data source interfaces), `services/` (e.g. `LoggerService` interface).
- **`infrastructure/`** — concrete implementations: `data_sources/*_drift_data_source_impl.dart` talk directly to Drift/SQLite; `repositories/*_repository_impl.dart` wrap a data source, add logging, and translate raw errors into typed `DataException`s (see `infrastructure/errors/drift_exception_handler.dart` and `data_exceptions.dart`); `inputs/` holds Formz input validators per feature (`accounts/`, `categories/`, `transactions/`); `services/logger_service_impl.dart` implements the domain logger interface.
- **`presentation/`** — `providers/` (Riverpod, code-generated with `@riverpod`/`@Riverpod(keepAlive: ...)`, one subdirectory per feature), `screens/`, `views/`, `widgets/`, `helpers/`, `mixins/`.
- **`config/`** — `database/database.dart` (Drift schema + migrations), `router/` (go_router config), `theme/`.

Each feature (account, category, transaction, recurring transaction, budget, savings goal, wishlist, settings) is wired the same way, e.g. for transactions:
`transaction_data_source` provider → `transaction_repository` provider (wraps the data source) → `TransactionsNotifier`/`TransactionForm` providers (business logic + state) → screens/widgets that watch those providers. When adding a feature, follow this same chain rather than calling Drift directly from presentation code.

### Database (Drift/SQLite)

- Single global `AppDatabase` instance in `config/database/database.dart`, tables `Accounts`, `Categories`, `Transactions`, `RecurringTransactions`, `Budgets`, `SavingsGoals`, `GoalContributions`, `WishlistItems`.
- `schemaVersion` is currently 9; every schema change needs a new `if (from < N)` branch inside `onUpgrade` in `MigrationStrategy` — never edit past migration branches, only append.
- `beforeOpen` sets `PRAGMA foreign_keys = ON`, WAL journal mode, and a busy timeout — preserve these when touching database setup.
- Account balances are **not** derived/recomputed from the transaction list; they're maintained incrementally via relative SQL updates (`balance = balance + ?` / `- ?`) whenever a transaction is created, updated, or deleted. `TransactionDriftDataSourceImpl._applyTransactionEffect` / `_reverseTransactionEffect` apply/undo that delta based on transaction type (income/expense/transfer). Any change to transaction create/update/delete logic must keep apply and reverse symmetric, or account balances will drift from reality over time. `updateTransaction` runs reverse-old → write-new-row → apply-new inside a single `database.transaction()` for atomicity.
- **Savings goal contributions also move account balances.** A contribution is signed (+ deposit takes money out of the account, − withdrawal puts it back), applied/undone by `SavingsGoalDriftDataSourceImpl._applyContributionEffect` / `_reverseContributionEffect` with the same symmetry rule and the same reverse → write → apply order, and every rule check runs inside the same `database.transaction()` as the write it guards. A goal's saved amount is always `SUM(amount)`, never stored. Contributions are deliberately *not* transactions, so saving doesn't count as spending in budgets or insights. Deleting a funded goal must refund it (`deleteGoal(refundAccountId:)`), never cascade.
- Budgets, savings goals and wishlist items are currency-scoped: they only ever compare against accounts in their own currency, nothing is converted.

### Forms

Form screens (`transaction_form_screen.dart`, `account_form_screen.dart`, `category_form_screen.dart`) are backed by per-form Riverpod providers (`transaction_form_provider.dart`, etc.) built on `formz`. Convention: a `GlobalConstants.createId` sentinel (`'create'`) is used as the form's `id` to distinguish "creating a new record" from "editing an existing one" — check against this constant rather than nullability when branching create-vs-edit logic.

To open the transaction form with starting values (e.g. buying a wishlist item), push its route with a `TransactionPrefill` as `extra`; the form applies it through its normal change handlers and pops `true` when a transaction is actually saved.

### Error handling

Data-layer exceptions flow through `DriftExceptionHandler.handleDriftException`, which inspects SQLite error codes / message text and maps them to typed `DataException` subclasses (`UniqueConstraintViolation`, `ForeignKeyViolation`, `DatabaseClosedException`, `StorageFullException`, etc. in `infrastructure/errors/data_exceptions.dart`). Repository implementations catch, log via `LoggerService`, and rethrow (or wrap unknown errors in `UnknownDataException`) rather than swallowing errors — follow this pattern for new data source/repository methods.

### Localization

All user-facing strings go through `AppLocalizations` (`lib/l10n/app_localizations.dart`, generated from `lib/l10n/app_en.arb`/`app_es.arb`/`app_fr.arb`). Every key in `app_en.arb` must have a matching entry in the other two `.arb` files — add new strings to all three before running `flutter gen-l10n`. Do not hardcode user-facing English strings in widgets or providers.

## CI

- `.github/workflows/pr_checks.yml` runs `flutter analyze --no-fatal-infos` and `flutter test` on every pull request into `main`.
- `.github/workflows/play_store_draft.yml` runs the same two checks, then builds a release App Bundle and uploads it as a Play Store draft, on every push to `main`. Each upload needs a higher build number (`version: x.y.z+N` in `pubspec.yaml`) than the last, or Play rejects it.
- Both pin Flutter to an exact version (currently `3.47.7`); upgrading Flutter means bumping it in both workflows, matching what you run locally. Warnings fail the analyze step; infos don't. The `integration_test/` simulator tests are not run by CI.
