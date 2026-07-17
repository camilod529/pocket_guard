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

flutter analyze                 # static analysis (flutter_lints + riverpod_lint)
flutter run                     # run on a connected device/simulator
flutter build appbundle --release   # Android release build (used by CI)
```

There is currently no `test/` directory in this repo — no automated tests exist yet.

## Architecture

Strict layered/clean architecture under `lib/`:

- **`domain/`** — framework-free contracts: `entities/` (plain Dart classes: `TransactionEntity`, `AccountEntity`, `CategoryEntity`, `TransactionFilter`, ...), `repositories/` (abstract repository interfaces), `data_sources/` (abstract data source interfaces), `services/` (e.g. `LoggerService` interface).
- **`infrastructure/`** — concrete implementations: `data_sources/*_drift_data_source_impl.dart` talk directly to Drift/SQLite; `repositories/*_repository_impl.dart` wrap a data source, add logging, and translate raw errors into typed `DataException`s (see `infrastructure/errors/drift_exception_handler.dart` and `data_exceptions.dart`); `inputs/` holds Formz input validators per feature (`accounts/`, `categories/`, `transactions/`); `services/logger_service_impl.dart` implements the domain logger interface.
- **`presentation/`** — `providers/` (Riverpod, code-generated with `@riverpod`/`@Riverpod(keepAlive: ...)`, one subdirectory per feature), `screens/`, `views/`, `widgets/`, `helpers/`, `mixins/`.
- **`config/`** — `database/database.dart` (Drift schema + migrations), `router/` (go_router config), `theme/`.

Each feature (account, category, transaction, settings) is wired the same way, e.g. for transactions:
`transaction_data_source` provider → `transaction_repository` provider (wraps the data source) → `TransactionsNotifier`/`TransactionForm` providers (business logic + state) → screens/widgets that watch those providers. When adding a feature, follow this same chain rather than calling Drift directly from presentation code.

### Database (Drift/SQLite)

- Single global `AppDatabase` instance in `config/database/database.dart`, tables `Accounts`, `Categories`, `Transactions`.
- `schemaVersion` is currently 4; every schema change needs a new `if (from < N)` branch inside `onUpgrade` in `MigrationStrategy` — never edit past migration branches, only append.
- `beforeOpen` sets `PRAGMA foreign_keys = ON`, WAL journal mode, and a busy timeout — preserve these when touching database setup.
- Account balances are **not** derived/recomputed from the transaction list; they're maintained incrementally via relative SQL updates (`balance = balance + ?` / `- ?`) whenever a transaction is created, updated, or deleted. `TransactionDriftDataSourceImpl._applyTransactionEffect` / `_reverseTransactionEffect` apply/undo that delta based on transaction type (income/expense/transfer). Any change to transaction create/update/delete logic must keep apply and reverse symmetric, or account balances will drift from reality over time. `updateTransaction` runs reverse-old → write-new-row → apply-new inside a single `database.transaction()` for atomicity.

### Forms

Form screens (`transaction_form_screen.dart`, `account_form_screen.dart`, `category_form_screen.dart`) are backed by per-form Riverpod providers (`transaction_form_provider.dart`, etc.) built on `formz`. Convention: a `GlobalConstants.createId` sentinel (`'create'`) is used as the form's `id` to distinguish "creating a new record" from "editing an existing one" — check against this constant rather than nullability when branching create-vs-edit logic.

### Error handling

Data-layer exceptions flow through `DriftExceptionHandler.handleDriftException`, which inspects SQLite error codes / message text and maps them to typed `DataException` subclasses (`UniqueConstraintViolation`, `ForeignKeyViolation`, `DatabaseClosedException`, `StorageFullException`, etc. in `infrastructure/errors/data_exceptions.dart`). Repository implementations catch, log via `LoggerService`, and rethrow (or wrap unknown errors in `UnknownDataException`) rather than swallowing errors — follow this pattern for new data source/repository methods.

### Localization

All user-facing strings go through `AppLocalizations` (`lib/l10n/app_localizations.dart`, generated from `lib/l10n/app_en.arb`/`app_es.arb`/`app_fr.arb`). Every key in `app_en.arb` must have a matching entry in the other two `.arb` files — add new strings to all three before running `flutter gen-l10n`. Do not hardcode user-facing English strings in widgets or providers.

## CI

`.github/workflows/play_store_draft.yml` builds a release App Bundle and uploads it as a Play Store draft on every push to `main`. It does not run `flutter analyze` or tests before building — treat that as a manual step, not a safety net.
