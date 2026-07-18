# Roadmap

## Version 0.1.0
- [x] Account with balance (Full CRUD)
- [x] Calendar view
- [x] Accounts view
- [x] Account form
- [x] Transaction form
- [x] Spanish and English
- [x] Settings to change theme color and language
- [x] Transactions edit the balance of the account (also Full CRUD)
- [x] Transfer between accounts of the same currency (can't edit them)

---

## Version 0.2.0
- [x] French
- [x] Custom account sort
- [x] Finish CRUD for income/expense categories
- [x] Categories to accounts

---

## Version 0.3.0: Insights & Refinement — complete

Focus: Helping the user understand where their money goes.
- [x] Visual Analytics:
    - [x] Pie charts for category spending.
    - [x] Line charts for "Net Worth" or "Balance over time."
- [x] Search & Filters: Deep search for transactions by name, date range, or category.
- [x] Recurring Transactions: Allow users to set "Subscriptions" or monthly rent that auto-generates a transaction.
    - New `RecurringTransactions` table (weekly/monthly/yearly frequency, optional end date, active/paused, supports transfers between accounts) with its own domain/data source/repository layer following the account feature's shape exactly, plus a full list + form screen under a new "Recurring Transactions" entry on the More screen.
    - Generation is a catch-up model, not a scheduler: `RecurringTransactionScheduler` (pure date math, handles month-end clamping e.g. Jan 31 monthly → Feb 28/29, and backfills every missed occurrence up to a 24-per-run cap rather than silently skipping ahead) plus `RecurringTransactionCatchUpService` (shared core: given a "now", generates due transactions and advances each rule). Two triggers call the same service: a `keepAlive` Riverpod provider that runs once per app launch (guaranteed), and a new periodic `workmanager` background task (best-effort — Android's WorkManager is reasonably reliable, iOS's BGTaskScheduler is opportunistic and OS-controlled, so this is a supplement to the foreground trigger, not a replacement). This is the app's first background-execution infrastructure, laid down here so future notification work (e.g. "your rent was just charged") can hook into the same background task without re-architecting it.
    - Bumped iOS deployment target 13.0 → 14.0 (`workmanager_apple` requires it); verified with real `flutter build ios --simulator` and `flutter build apk --debug` builds, not just `flutter analyze`, since native plugin code isn't caught by Dart analysis alone. No Android manifest changes were needed.
    - iOS native wiring: `Info.plist` declares `UIBackgroundModes` (`fetch`, `processing`) and the task identifier under `BGTaskSchedulerPermittedIdentifiers`; `AppDelegate.swift` calls `WorkmanagerPlugin.registerPeriodicTask(withIdentifier:frequency:)` during `didFinishLaunchingWithOptions`, since BGTaskScheduler requires that registration to happen natively before the app finishes launching - the Dart-side `Workmanager().registerPeriodicTask()` call can't do it. Confirmed the built simulator app's `Info.plist` actually carries both keys post-build. All three identifiers (Info.plist, AppDelegate.swift, `recurringTransactionsTaskName`) are plain string literals that must be kept in sync by hand.
    - Reused the transfer-CRUD fixes from earlier in this same version: the two account selectors have no mutual-exclusion filtering (just currency matching) with a "from ≠ to" validation error shown unconditionally, and `RecurringTransactionFormState.copyWith` uses the sentinel pattern for nullable fields from the start rather than repeating the `TransactionFormState.copyWith` bug.
    - Tests: `recurring_transaction_scheduler_test.dart` (date math incl. month-end clamping, backfill cap, end-date deactivation), `recurring_transaction_catch_up_service_test.dart` (income/expense/transfer generation, idempotency, paused rules), `recurring_transaction_drift_data_source_impl_test.dart` (CRUD), `recurring_transaction_form_provider_integration_test.dart` (create/edit, same-account transfer rejection). No background-task test - OS scheduling isn't something `flutter test` can exercise; verified manually instead.
- [x] Bug Fix (Priority): Full CRUD for transfers (the logic to revert old account balances and update new ones).
    - Balance revert/apply already used relative deltas, so it was correct for swapped/changed accounts; the actual gap was the UI blocking edits (`readonly` on the account fields) and a stale unverified TODO. Both fixed, with regression tests covering swap, amount-change, type-change, and delete-after-edit — see `test/infrastructure/data_sources/transaction_drift_data_source_impl_test.dart`.
    - Manual testing of the fix surfaced two more bugs, tracked below: the from/to dropdown deadlock, and a `copyWith` null-clearing bug (fixed same day).
- [x] Bug Fix: `TransactionFormState.copyWith` couldn't clear `accountId`/`categoryId`/`toAccountId` (it used `param ?? this.field`, so passing `null` was indistinguishable from "not passed" and silently kept the old value). Editing an existing transfer's type to expense/income left the stale transfer category in place, which crashed on save with "Transfer transaction requires toAccountId" and knocked the calendar/transaction list into an error state (both watch the same provider). Fixed with a sentinel-default pattern; regression test in `test/presentation/providers/transaction/transaction_form_state_test.dart`. Pre-existing since Dec 2025, just never reachable until transfers became editable.
- [x] Bug Fix: editing a transfer's From/To accounts was impossible with only 2 accounts. Each dropdown excluded whatever the *other* field currently held (`excludeAccountId`), so swapping From/To had nowhere to go without a 3rd account to use as a buffer. Fixed by dropping the live mutual-exclusion filtering (both dropdowns now show every currency-matching account, including whatever the other field holds) and instead validating "from ≠ to" as a real form error (`sameTransferAccountError`, localized in en/es/fr), which blocks submission the same way the amount/description errors do. Regression tests added to `transaction_form_provider_integration_test.dart` covering both the rejected same-account case and a same-account correction back into a valid 2-account swap.
- [x] Bug Fix: Accounts screen showed stale balances after saving a transaction. It renders from `accountsProvider` (a cached list), which is a completely separate provider from `accountProvider(id)` (a per-account cache) — nothing in the save/delete flow ever invalidated the list, only individual accounts that don't even feed the Accounts screen. Confirmed with a test that this affected *every* transaction, not just edits: it just wasn't noticeable when the balance change happened to be small or the screen got refreshed some other way. Separately, editing a transfer into a non-transfer type also skipped refreshing whichever account dropped out of the transaction (e.g. the old "to" account), even accounting for the above. Both fixed in `onFormSubmit`/`deleteTransaction` by invalidating `accountsProvider` and refreshing the union of old + new account ids. Regression test: `test/presentation/providers/transaction/transaction_form_provider_integration_test.dart`, which drives the real form provider through a full create → edit → edit → edit sequence and asserts against `accountsProvider` itself (not just the raw DB).
- [x] Bug Fix: editing an existing transfer to the same From/To account disabled the Save button (correctly - the `sameTransferAccountError` validation from the fix above worked) but showed no error explaining why. The error text was gated on `!formState.isFormPure`, which is only ever set by `_touchAllFields()` inside `onFormSubmit()` - but the disabled button can't be tapped, so that submit attempt could never happen, so the flag never flipped, so the error never rendered. Unlike "you haven't filled this in yet" errors (which should wait for a submit attempt before nagging), this one is a direct, immediate consequence of the selection just made, so it's shown unconditionally now instead of behind the `isFormPure` gate. First widget test in the repo: `test/presentation/screens/transaction_form_screen_test.dart`, which pumps the real screen and asserts the error text and button state directly (a pure state/logic test can't catch a "the state is right but nothing renders it" bug like this one).

---

## Version 0.4.0: Budgeting & Goals

Focus: Discipline and future planning.
- [ ] Budget Engine:
    - [ ] Set monthly limits per category.
    - [ ] Progress bars (Green → Yellow → Red) to show remaining funds.
- [ ] Financial Goals: A "Savings Jar" feature where users can allocate money toward a specific goal (e.g., "New Car").
- [ ] Planned Expenses: A "Wishlist" that tells the user if they can afford an item based on their current budget.

---

## Version 0.5.0: Security & Data

Focus: Trust and portability.
- [ ] Local Backups (JSON/SQLite): Manual export/import to Google Drive or local storage.
- [ ] Biometric Lock: Integrate `local_auth` for Fingerprint/FaceID access.
- [ ] CSV/PDF Export: Generate monthly reports for users who want to see their data in Excel.
- [ ] Home Screen Widgets: Quick-add buttons for transactions and a "Quick Balance" view.

---

## Future "Rich" Features (v1.0+)

To make the app stand out, consider these advanced Flutter-specific features:

| Feature | Description |
|---|---|
| **Multi-Currency** | Support accounts in different currencies with an API to fetch live exchange rates. |
| **Receipt Scanning** | Use `google_ml_kit` to extract the total amount from a photo of a receipt. |
| **Debt Tracker** | A specific module to track money owed to/by friends (integrated with contacts). |
| **Gamification** | Small "Streaks" or badges for staying under budget for 3 consecutive months. |

---

## Technical Debt / Known Gaps

Not user-facing features, but worth tracking alongside the roadmap since v0.4.0+ keeps adding more balance-affecting logic (budgets, goals) on top of the same account/transaction core:

- **No automated test suite.** As of the end of v0.3.0 there are 9 test files (added for the transfer CRUD fix, its follow-up bugs, and Recurring Transactions), covering transaction/transfer/account/recurring-transaction balance logic and one screen; everything else — account CRUD, category CRUD, most other screens — is untested. Worth expanding coverage before v0.4.0's budget engine, since it reads the same transaction/category data.
- ~~**CI has no quality gate.**~~ Fixed: `.github/workflows/play_store_draft.yml` now runs `flutter analyze --no-fatal-infos` and `flutter test` right after `flutter pub get`, before signing/building - either failing stops the workflow before it touches keystore secrets or produces a release artifact.
- **Background execution (`workmanager`) has no automated coverage and can't get any** — OS-level scheduling isn't something `flutter test` can exercise. If notification work builds on this later, budget for manual on-device verification (Android: force-trigger via `adb shell cmd jobscheduler`; iOS: Xcode's simulate-background-fetch debug command) as part of that work too, not just this one.
- **`Transactions.date` stores epoch milliseconds in a plain `IntColumn`, with manual `.millisecondsSinceEpoch`/`.fromMillisecondsSinceEpoch` conversion at every read/write site, instead of Drift's typed `dateTime()` column.** Noticed while designing Recurring Transactions' date columns (which use `dateTime()` directly, since Drift already supports it and it removes a unit/timezone-mixup bug class the manual approach is exposed to). Migrating `Transactions.date` to match would need a schema migration plus updating every existing read/write site — not urgent, but worth doing before the column count grows further.

---

## Suggested Tech Stack for Growth

- **State Management:** Since you have complex CRUD across accounts/balances, ensure you are using **Riverpod** or **Bloc** to keep the logic clean. *(Already on Riverpod.)*
- **Local Database:** If you aren't already, **Isar** or **Drift** are much faster than standard Sqflite for financial apps with many relations. *(Already on Drift.)*
- **Charts:** Use the `fl_chart` package — it's the standard for Flutter and highly customizable. *(Already in use.)*

## Monetization Tip

Instead of intrusive banner ads, try a **"Freemium" model**:

- **Free:** Unlimited transactions, 3 accounts, 2 budgets.
- **Pro (One-time or Sub):** Unlimited accounts, PDF reports, and "Themes."
