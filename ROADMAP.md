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
