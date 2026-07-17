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

## Version 0.3.0: Insights & Refinement

Focus: Helping the user understand where their money goes.
- [x] Visual Analytics:
    - [x] Pie charts for category spending.
    - [x] Line charts for "Net Worth" or "Balance over time."
- [x] Search & Filters: Deep search for transactions by name, date range, or category.
- [ ] Recurring Transactions: Allow users to set "Subscriptions" or monthly rent that auto-generates a transaction.
- [x] Bug Fix (Priority): Full CRUD for transfers (the logic to revert old account balances and update new ones).
    - Balance revert/apply already used relative deltas, so it was correct for swapped/changed accounts; the actual gap was the UI blocking edits (`readonly` on the account fields) and a stale unverified TODO. Both fixed, with regression tests covering swap, amount-change, type-change, and delete-after-edit — see `test/infrastructure/data_sources/transaction_drift_data_source_impl_test.dart`.
    - Manual testing of the fix surfaced two more bugs, tracked below: the from/to dropdown deadlock, and a `copyWith` null-clearing bug (fixed same day).
- [x] Bug Fix: `TransactionFormState.copyWith` couldn't clear `accountId`/`categoryId`/`toAccountId` (it used `param ?? this.field`, so passing `null` was indistinguishable from "not passed" and silently kept the old value). Editing an existing transfer's type to expense/income left the stale transfer category in place, which crashed on save with "Transfer transaction requires toAccountId" and knocked the calendar/transaction list into an error state (both watch the same provider). Fixed with a sentinel-default pattern; regression test in `test/presentation/providers/transaction/transaction_form_state_test.dart`. Pre-existing since Dec 2025, just never reachable until transfers became editable.
- [x] Bug Fix: editing a transfer's From/To accounts was impossible with only 2 accounts. Each dropdown excluded whatever the *other* field currently held (`excludeAccountId`), so swapping From/To had nowhere to go without a 3rd account to use as a buffer. Fixed by dropping the live mutual-exclusion filtering (both dropdowns now show every currency-matching account, including whatever the other field holds) and instead validating "from ≠ to" as a real form error (`sameTransferAccountError`, localized in en/es/fr), which blocks submission the same way the amount/description errors do. Regression tests added to `transaction_form_provider_integration_test.dart` covering both the rejected same-account case and a same-account correction back into a valid 2-account swap.
- [x] Bug Fix: Accounts screen showed stale balances after saving a transaction. It renders from `accountsProvider` (a cached list), which is a completely separate provider from `accountProvider(id)` (a per-account cache) — nothing in the save/delete flow ever invalidated the list, only individual accounts that don't even feed the Accounts screen. Confirmed with a test that this affected *every* transaction, not just edits: it just wasn't noticeable when the balance change happened to be small or the screen got refreshed some other way. Separately, editing a transfer into a non-transfer type also skipped refreshing whichever account dropped out of the transaction (e.g. the old "to" account), even accounting for the above. Both fixed in `onFormSubmit`/`deleteTransaction` by invalidating `accountsProvider` and refreshing the union of old + new account ids. Regression test: `test/presentation/providers/transaction/transaction_form_provider_integration_test.dart`, which drives the real form provider through a full create → edit → edit → edit sequence and asserts against `accountsProvider` itself (not just the raw DB).

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

- **No automated test suite.** As of v0.3.0 there's a single data-source test file (added for the transfer CRUD fix); everything else — account CRUD, category CRUD, form validation — is untested. Worth expanding coverage before v0.4.0's budget engine, since it reads the same transaction/category data.
- **CI has no quality gate.** `.github/workflows/play_store_draft.yml` builds and uploads a Play Store draft on every push to `main` without running `flutter analyze` or `flutter test` first.

---

## Suggested Tech Stack for Growth

- **State Management:** Since you have complex CRUD across accounts/balances, ensure you are using **Riverpod** or **Bloc** to keep the logic clean. *(Already on Riverpod.)*
- **Local Database:** If you aren't already, **Isar** or **Drift** are much faster than standard Sqflite for financial apps with many relations. *(Already on Drift.)*
- **Charts:** Use the `fl_chart` package — it's the standard for Flutter and highly customizable. *(Already in use.)*

## Monetization Tip

Instead of intrusive banner ads, try a **"Freemium" model**:

- **Free:** Unlimited transactions, 3 accounts, 2 budgets.
- **Pro (One-time or Sub):** Unlimited accounts, PDF reports, and "Themes."
