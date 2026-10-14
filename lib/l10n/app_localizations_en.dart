// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get accountCurrency => 'Currency';

  @override
  String get accountCurrencyHint => 'USD, EUR, GBP';

  @override
  String get accountFilterLabel => 'Account';

  @override
  String accountLabel(String name) {
    return 'Account: $name';
  }

  @override
  String get accountName => 'Account Name';

  @override
  String get accountNameHint => 'Enter account name';

  @override
  String get accounts => 'Accounts';

  @override
  String get accountTypeAsset => 'Asset';

  @override
  String get accountTypeCash => 'Cash';

  @override
  String get accountTypeCredit => 'Credit';

  @override
  String get accountTypeLabel => 'Account Type';

  @override
  String get activeLabel => 'Active';

  @override
  String get addBudget => 'Add Budget';

  @override
  String get addGoal => 'Add Goal';

  @override
  String get addRecurringTransaction => 'Add Recurring Transaction';

  @override
  String get addWishlistItem => 'Add Item';

  @override
  String get allAccounts => 'All Accounts';

  @override
  String get amountHint => '0.00';

  @override
  String get amountLabel => 'Amount';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get archivedGoalsSection => 'Archived';

  @override
  String get balanceTrend => 'Balance Trend';

  @override
  String get blue => 'Blue';

  @override
  String get budgetCurrencyNoAccountsHint => 'Add an account first to set a budget currency';

  @override
  String get budgetDeletedSuccess => 'Budget deleted successfully';

  @override
  String get budgetDuplicateCategoryCurrencyError => 'You already have a budget for this category in this currency';

  @override
  String get budgets => 'Budgets';

  @override
  String get buyWishlistItem => 'Buy';

  @override
  String get calendar => 'Calendar';

  @override
  String get calendarNextMonth => 'Next month';

  @override
  String get calendarPreviousMonth => 'Previous month';

  @override
  String get calendarToday => 'Go to today';

  @override
  String get cancel => 'Cancel';

  @override
  String get categories => 'Categories';

  @override
  String get category_expense_food_dining => 'Food';

  @override
  String get category_expense_rent => 'Rent';

  @override
  String get category_expense_transportation => 'Transportation';

  @override
  String get category_income_freelance => 'Freelance';

  @override
  String get category_income_salary => 'Salary';

  @override
  String get category_transfer => 'Transfer';

  @override
  String get categoryDeletedSuccessfully => 'Category deleted successfully';

  @override
  String categoryDeleteError(String error) {
    return 'Failed to delete category: $error';
  }

  @override
  String get categoryInUseError => 'This category is still used by transactions, recurring transactions or budgets, so it can\'t be deleted.';

  @override
  String get categoryLabel => 'Category';

  @override
  String get categoryName => 'Category Name';

  @override
  String get chooseYourAppColor => 'Choose your app color';

  @override
  String get clearAll => 'Clear All';

  @override
  String get contributionAmountLabel => 'Amount';

  @override
  String get contributionFromAccountLabel => 'From account';

  @override
  String get contributionNoteLabel => 'Note (optional)';

  @override
  String get contributionToAccountLabel => 'To account';

  @override
  String get create => 'Create';

  @override
  String get createAccount => 'Create Account';

  @override
  String get createBudgetButton => 'Create Budget';

  @override
  String get createCategory => 'Create Category';

  @override
  String get createGoalButton => 'Create Goal';

  @override
  String get createRecurringTransactionButton => 'Create Recurring Transaction';

  @override
  String get createTransaction => 'Create Transaction';

  @override
  String get createTransactionButton => 'Create Transaction';

  @override
  String get createWishlistItemButton => 'Add to Wishlist';

  @override
  String get currencyLabel => 'Currency';

  @override
  String get custom => 'Custom';

  @override
  String get cyan => 'Cyan';

  @override
  String get dateLabel => 'Date';

  @override
  String get deepPurple => 'Deep Purple';

  @override
  String get delete => 'Delete';

  @override
  String deleteAccountConfirmation(String accountName) {
    return 'Are you sure you want to delete the account \"$accountName\"? This will also delete all associated transactions and recurring transactions.';
  }

  @override
  String get deleteAccountSuccess => 'Account deleted successfully';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String get deleteAction => 'Delete';

  @override
  String get deleteBudgetDescription => 'This action cannot be undone.';

  @override
  String get deleteBudgetTitle => 'Delete Budget';

  @override
  String deleteCategoryConfirmation(String categoryName) {
    return 'Are you sure you want to delete the category \"$categoryName\"? This will also delete all associated transactions.';
  }

  @override
  String get deleteCategoryTitle => 'Delete Category';

  @override
  String deleteConfirmationQuestion(String entity) {
    return 'Are you sure you want to delete \"$entity\"?';
  }

  @override
  String get deleteContributionDescription => 'The money goes back to the account it came from.';

  @override
  String get deleteContributionTitle => 'Delete Movement';

  @override
  String get deletedAccountLabel => 'Deleted account';

  @override
  String get deleteGoalDescription => 'The goal and its history will be deleted.';

  @override
  String deleteGoalRefundPrompt(String amount) {
    return 'This goal holds $amount. Choose the account that gets it back.';
  }

  @override
  String get deleteGoalTitle => 'Delete Goal';

  @override
  String get deleteRecurringTransactionDescription => 'This action cannot be undone. Transactions already generated from this rule will not be affected.';

  @override
  String get deleteRecurringTransactionTitle => 'Delete Recurring Transaction';

  @override
  String get deleteTransactionDescription => 'This action cannot be undone.';

  @override
  String get deleteTransactionTitle => 'Delete Transaction';

  @override
  String get deleteWishlistItemTitle => 'Delete Item';

  @override
  String get depositToGoal => 'Add Money';

  @override
  String get descriptionHint => 'Enter transaction description';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get edit => 'Edit';

  @override
  String get editBudgetTitle => 'Edit Budget';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get editGoalTitle => 'Edit Goal';

  @override
  String get editRecurringTransactionTitle => 'Edit Recurring Transaction';

  @override
  String get editTransactionTitle => 'Edit Transaction';

  @override
  String get editWishlistItemTitle => 'Edit Item';

  @override
  String get endDateLabel => 'End Date';

  @override
  String get english => 'English';

  @override
  String get englishNative => 'English';

  @override
  String get error_db_operation_failed => 'Database operation failed. Please try again.';

  @override
  String get error_unknown_data => 'Something went wrong with the data operation. Please try again.';

  @override
  String get errorCategoryNameEmpty => 'Category name cannot be empty';

  @override
  String get errorCategoryNameTooLong => 'Category name is too long';

  @override
  String get errorCategoryNameTooShort => 'Category name is too short';

  @override
  String errorLoadingAccounts(String error) {
    return 'Error loading accounts: $error';
  }

  @override
  String errorLoadingCalendar(String error) {
    return 'Error loading calendar: $error';
  }

  @override
  String errorLoadingCategories(String error) {
    return 'Error loading categories: $error';
  }

  @override
  String errorLoadingTransaction(String error) {
    return 'Error loading transaction: $error';
  }

  @override
  String errorLoadingTransactions(String error) {
    return 'Error loading transactions: $error';
  }

  @override
  String get expense => 'Expense';

  @override
  String get expensesByCategory => 'Expenses by Category';

  @override
  String get expenseType => 'Expense';

  @override
  String get filterTitle => 'Filter Transactions';

  @override
  String get french => 'French';

  @override
  String get frenchNative => 'Français';

  @override
  String get frequencyDaily => 'Daily';

  @override
  String get frequencyLabel => 'Frequency';

  @override
  String get frequencyMonthly => 'Monthly';

  @override
  String get frequencyWeekly => 'Weekly';

  @override
  String get frequencyYearly => 'Yearly';

  @override
  String get fromAccountLabel => 'From Account';

  @override
  String get goalAmountError => 'Amount must be greater than 0';

  @override
  String get goalArchivedLabel => 'Archived';

  @override
  String get goalArchivedSubtitle => 'Hide it from the active goals';

  @override
  String get goalCompleted => 'Goal reached!';

  @override
  String get goalCurrencyLockedHint => 'Locked: the goal already has money';

  @override
  String get goalCurrencyNoAccountsHint => 'Add an account first to set the goal\'s currency';

  @override
  String get goalDeletedSuccess => 'Goal deleted';

  @override
  String get goalDepositSuccess => 'Money added to the goal';

  @override
  String get goalErrorAccountMissing => 'This movement\'s account was deleted, so it can\'t be changed';

  @override
  String get goalErrorCurrencyLocked => 'You can\'t change the currency of a goal that already has money';

  @override
  String get goalErrorCurrencyMismatch => 'The account\'s currency doesn\'t match the goal\'s';

  @override
  String get goalErrorInsufficientAccountBalance => 'The account doesn\'t have enough money';

  @override
  String get goalErrorInsufficientGoalBalance => 'The goal doesn\'t have that much saved';

  @override
  String get goalErrorRefundAccountRequired => 'Choose an account to receive the saved money';

  @override
  String get goalHistory => 'History';

  @override
  String goalMonthlyNeeded(String amount, String date) {
    return 'Save $amount/month to reach it by $date';
  }

  @override
  String get goalNameHint => 'e.g. New car';

  @override
  String get goalNameLabel => 'Goal name';

  @override
  String get goalNameRequired => 'Enter a name';

  @override
  String get goalOverdue => 'Target date passed';

  @override
  String get goals => 'Savings Goals';

  @override
  String goalSavedOf(String saved, String target) {
    return '$saved of $target';
  }

  @override
  String get goalTargetAmountLabel => 'Target amount';

  @override
  String get goalTargetDateLabel => 'Target date (optional)';

  @override
  String get goalWithdrawSuccess => 'Money withdrawn from the goal';

  @override
  String get goBackAction => 'Go Back';

  @override
  String get income => 'Income';

  @override
  String get incomeType => 'Income';

  @override
  String get indigo => 'Indigo';

  @override
  String get language => 'Language';

  @override
  String get lime => 'Lime';

  @override
  String get manageBudgets => 'Set monthly spending limits per category';

  @override
  String get manageGoals => 'Save money toward something you want';

  @override
  String get manageRecurringTransactions => 'Manage subscriptions and recurring bills';

  @override
  String get manageWishlist => 'See whether you can afford what you want';

  @override
  String get monthlyInsights => 'Monthly Insights';

  @override
  String get monthlyLimitHint => '0.00';

  @override
  String get monthlyLimitLabel => 'Monthly Limit';

  @override
  String get more => 'More';

  @override
  String get newBudgetTitle => 'New Budget';

  @override
  String get newGoalTitle => 'New Goal';

  @override
  String get newRecurringTransactionTitle => 'New Recurring Transaction';

  @override
  String get newTransactionTitle => 'New Transaction';

  @override
  String get newWishlistItemTitle => 'New Item';

  @override
  String get nextOccurrenceLabel => 'Next';

  @override
  String get noAccountInfo => 'No account info';

  @override
  String get noBudgetsMessage => 'No budgets yet';

  @override
  String get noContributionsMessage => 'No money added yet';

  @override
  String get noDataForPeriod => 'No data for this period';

  @override
  String get noDescription => 'No description';

  @override
  String get noEndDateLabel => 'No end date';

  @override
  String get noExpensesFound => 'No expenses found';

  @override
  String get noGoalsMessage => 'No savings goals yet';

  @override
  String get noRecurringTransactionsMessage => 'No recurring transactions yet';

  @override
  String noTransactionsOnDate(String date) {
    return 'No transactions on $date';
  }

  @override
  String get noWishlistItemsMessage => 'Your wishlist is empty';

  @override
  String get primaryColor => 'Primary Color';

  @override
  String get purple => 'Purple';

  @override
  String get recurringTransactionDeletedSuccess => 'Recurring transaction deleted successfully';

  @override
  String get recurringTransactionNameHint => 'e.g. Netflix, Rent';

  @override
  String get recurringTransactionNameLabel => 'Name';

  @override
  String get recurringTransactions => 'Recurring Transactions';

  @override
  String get remainingLabel => 'Remaining';

  @override
  String get sameTransferAccountError => 'From and To accounts must be different';

  @override
  String get selectAccountError => 'Please select an account';

  @override
  String get selectAccountHint => 'Select an account';

  @override
  String get selectAppLanguage => 'Select app language';

  @override
  String get selectCategoryError => 'Please select a category';

  @override
  String get selectCategoryHint => 'Select a category';

  @override
  String get selectDateHint => 'Select date';

  @override
  String get selectTimeHint => 'Select time';

  @override
  String get settings => 'Settings';

  @override
  String get spanish => 'Spanish';

  @override
  String get spanishNative => 'Español';

  @override
  String get spentLabel => 'Spent';

  @override
  String get startDateLabel => 'Start Date';

  @override
  String get system => 'System';

  @override
  String get teal => 'Teal';

  @override
  String get theme => 'Theme';

  @override
  String get thisAccount => 'this account';

  @override
  String get thisBudget => 'this budget';

  @override
  String get thisCategory => 'this category';

  @override
  String get thisContribution => 'this movement';

  @override
  String get thisGoal => 'this goal';

  @override
  String get thisRecurringTransaction => 'this recurring transaction';

  @override
  String get thisTransaction => 'this transaction';

  @override
  String get thisWishlistItem => 'this item';

  @override
  String get timeLabel => 'Time';

  @override
  String get toAccountLabel => 'To Account';

  @override
  String get totalExpense => 'Total Expense';

  @override
  String get totalIncome => 'Total Income';

  @override
  String get transactionCreatedSuccess => 'Transaction created successfully!';

  @override
  String get transactionDeletedSuccess => 'Transaction deleted successfully';

  @override
  String transactionDeleteError(String error) {
    return 'Failed to delete transaction: $error';
  }

  @override
  String get transactionSaveError => 'Failed to save transaction';

  @override
  String get transactionTitle => 'Transaction';

  @override
  String get transactionTypeLabel => 'Transaction Type';

  @override
  String get transactionUpdatedSuccess => 'Transaction updated successfully!';

  @override
  String transferSummary(String amount, String fromAccount, String toAccount) {
    return 'This will move $amount from $fromAccount to $toAccount.';
  }

  @override
  String get transferType => 'Transfer';

  @override
  String get unknownCategory => 'Unknown';

  @override
  String get update => 'Update';

  @override
  String get updateBudgetButton => 'Update Budget';

  @override
  String get updateGoalButton => 'Update Goal';

  @override
  String get updateRecurringTransactionButton => 'Update Recurring Transaction';

  @override
  String get updateTransactionButton => 'Update Transaction';

  @override
  String get updateWishlistItemButton => 'Update Item';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get weekdaySun => 'Sun';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get wishlist => 'Wishlist';

  @override
  String get wishlistAffordable => 'You can afford it';

  @override
  String get wishlistCategoryLabel => 'Category (optional)';

  @override
  String wishlistCoveredByGoal(String goal) {
    return 'Covered by your \"$goal\" savings';
  }

  @override
  String get wishlistCurrencyNoAccountsHint => 'Add an account first to set the currency';

  @override
  String get wishlistDeletedSuccess => 'Item deleted';

  @override
  String get wishlistGoalLabel => 'Pay with savings goal (optional)';

  @override
  String wishlistInsufficientFunds(String amount) {
    return 'You\'re missing $amount';
  }

  @override
  String get wishlistItemNameHint => 'e.g. Headphones';

  @override
  String get wishlistItemNameLabel => 'What do you want?';

  @override
  String get wishlistNone => 'None';

  @override
  String wishlistOverBudget(String amount) {
    return '$amount over this month\'s budget';
  }

  @override
  String get wishlistPriceLabel => 'Price';

  @override
  String wishlistPurchasedOn(String date) {
    return 'Bought on $date';
  }

  @override
  String get wishlistPurchasedSection => 'Bought';

  @override
  String get wishlistPurchasedSuccess => 'Marked as bought';

  @override
  String get wishlistUseGoalConfirm => 'Use Savings';

  @override
  String wishlistUseGoalPrompt(String amount, String goal) {
    return 'Move $amount from \"$goal\" into this account to pay for it:';
  }

  @override
  String get wishlistUseGoalSkip => 'Don\'t Use';

  @override
  String get wishlistUseGoalTitle => 'Use Your Savings?';

  @override
  String get withdrawFromGoal => 'Withdraw';

  @override
  String get yellow => 'Yellow';
}
