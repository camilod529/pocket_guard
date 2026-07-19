import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr')
  ];

  /// Label for account currency input
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get accountCurrency;

  /// Hint text for account currency input
  ///
  /// In en, this message translates to:
  /// **'USD, EUR, GBP'**
  String get accountCurrencyHint;

  /// Label for account filter selector
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountFilterLabel;

  /// Label for account name in transaction list item
  ///
  /// In en, this message translates to:
  /// **'Account: {name}'**
  String accountLabel(String name);

  /// Label for account name input
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get accountName;

  /// Hint text for account name input
  ///
  /// In en, this message translates to:
  /// **'Enter account name'**
  String get accountNameHint;

  /// Label for the accounts view
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// Account type: Asset
  ///
  /// In en, this message translates to:
  /// **'Asset'**
  String get accountTypeAsset;

  /// Account type: Cash
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get accountTypeCash;

  /// Account type: Credit
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get accountTypeCredit;

  /// Label for account type selector
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get accountTypeLabel;

  /// Label/switch for whether a recurring transaction rule is active
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeLabel;

  /// Tooltip for the button that creates a new budget
  ///
  /// In en, this message translates to:
  /// **'Add Budget'**
  String get addBudget;

  /// Tooltip for the button that creates a new recurring transaction
  ///
  /// In en, this message translates to:
  /// **'Add Recurring Transaction'**
  String get addRecurringTransaction;

  /// Option to show data from all accounts
  ///
  /// In en, this message translates to:
  /// **'All Accounts'**
  String get allAccounts;

  /// Amount field hint text
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get amountHint;

  /// Amount field label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// Button to apply selected filters
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// Title for the balance trend line chart
  ///
  /// In en, this message translates to:
  /// **'Balance Trend'**
  String get balanceTrend;

  /// Color option: Blue
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get blue;

  /// Hint shown under the budget currency selector when no accounts exist yet to pick a currency from
  ///
  /// In en, this message translates to:
  /// **'Add an account first to set a budget currency'**
  String get budgetCurrencyNoAccountsHint;

  /// Success message after budget deletion
  ///
  /// In en, this message translates to:
  /// **'Budget deleted successfully'**
  String get budgetDeletedSuccess;

  /// Error shown when submitting a budget for a category/currency pair that already has one
  ///
  /// In en, this message translates to:
  /// **'You already have a budget for this category in this currency'**
  String get budgetDuplicateCategoryCurrencyError;

  /// Title for the Budgets list screen and its More-screen entry
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// Label for the calendar view
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// Tooltip for going to next month in the calendar
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get calendarNextMonth;

  /// Tooltip for going to previous month in the calendar
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get calendarPreviousMonth;

  /// Tooltip for jumping back to the current day/month
  ///
  /// In en, this message translates to:
  /// **'Go to today'**
  String get calendarToday;

  /// Cancel action/button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Label for the categories view
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// Category for expenses on food and dining
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get category_expense_food_dining;

  /// Category for expenses on rent
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get category_expense_rent;

  /// Category for expenses on transportation
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get category_expense_transportation;

  /// Category for income from freelance work
  ///
  /// In en, this message translates to:
  /// **'Freelance'**
  String get category_income_freelance;

  /// Category for income from salary
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get category_income_salary;

  /// Category for money transfers
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get category_transfer;

  /// Success message after category deletion
  ///
  /// In en, this message translates to:
  /// **'Category deleted successfully'**
  String get categoryDeletedSuccessfully;

  /// Error message after failed category deletion
  ///
  /// In en, this message translates to:
  /// **'Failed to delete category: {error}'**
  String categoryDeleteError(String error);

  /// Category selector label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// Label for category name input
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// Subtitle for the theme settings section
  ///
  /// In en, this message translates to:
  /// **'Choose your app color'**
  String get chooseYourAppColor;

  /// Button to clear all filters
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// Create action/button
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Button to create a new account
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Button to create a new budget
  ///
  /// In en, this message translates to:
  /// **'Create Budget'**
  String get createBudgetButton;

  /// Button to create a new category
  ///
  /// In en, this message translates to:
  /// **'Create Category'**
  String get createCategory;

  /// Button to create a new recurring transaction
  ///
  /// In en, this message translates to:
  /// **'Create Recurring Transaction'**
  String get createRecurringTransactionButton;

  /// Button to create a new transaction
  ///
  /// In en, this message translates to:
  /// **'Create Transaction'**
  String get createTransaction;

  /// Button to create new transaction
  ///
  /// In en, this message translates to:
  /// **'Create Transaction'**
  String get createTransactionButton;

  /// Label for currency selector
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currencyLabel;

  /// Label indicating that a category is a custom category
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// Color option: Cyan
  ///
  /// In en, this message translates to:
  /// **'Cyan'**
  String get cyan;

  /// Date field label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// Color option: Deep Purple
  ///
  /// In en, this message translates to:
  /// **'Deep Purple'**
  String get deepPurple;

  /// Delete action/button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Delete account confirmation message with account name, warning about cascading deletes
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the account \"{accountName}\"? This will also delete all associated transactions and recurring transactions.'**
  String deleteAccountConfirmation(String accountName);

  /// Success message after account deletion
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get deleteAccountSuccess;

  /// Title for delete account confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountTitle;

  /// Delete button tooltip
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// Delete confirmation description for a budget
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteBudgetDescription;

  /// Delete confirmation dialog title for a budget
  ///
  /// In en, this message translates to:
  /// **'Delete Budget'**
  String get deleteBudgetTitle;

  /// Delete category confirmation message with category name
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the category \"{categoryName}\"? This will also delete all associated transactions.'**
  String deleteCategoryConfirmation(String categoryName);

  /// Title for delete category confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategoryTitle;

  /// Generic delete confirmation question shown in the shared delete dialog, used for accounts/categories/transactions/recurring transactions
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{entity}\"?'**
  String deleteConfirmationQuestion(String entity);

  /// Delete confirmation description for a recurring transaction rule
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. Transactions already generated from this rule will not be affected.'**
  String get deleteRecurringTransactionDescription;

  /// Delete confirmation dialog title for a recurring transaction
  ///
  /// In en, this message translates to:
  /// **'Delete Recurring Transaction'**
  String get deleteRecurringTransactionTitle;

  /// Delete confirmation description
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteTransactionDescription;

  /// Delete confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get deleteTransactionTitle;

  /// Description field hint text
  ///
  /// In en, this message translates to:
  /// **'Enter transaction description'**
  String get descriptionHint;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// Edit action/button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// AppBar title for editing an existing budget
  ///
  /// In en, this message translates to:
  /// **'Edit Budget'**
  String get editBudgetTitle;

  /// AppBar title for editing existing category
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// AppBar title for editing an existing recurring transaction
  ///
  /// In en, this message translates to:
  /// **'Edit Recurring Transaction'**
  String get editRecurringTransactionTitle;

  /// AppBar title for editing existing transaction
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransactionTitle;

  /// Label for a recurring transaction's optional end date
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDateLabel;

  /// Language name for English
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Native language name for English
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishNative;

  /// Generic database operation failure message
  ///
  /// In en, this message translates to:
  /// **'Database operation failed. Please try again.'**
  String get error_db_operation_failed;

  /// Unknown or unexpected data-related error
  ///
  /// In en, this message translates to:
  /// **'Something went wrong with the data operation. Please try again.'**
  String get error_unknown_data;

  /// Error shown when the category name is empty
  ///
  /// In en, this message translates to:
  /// **'Category name cannot be empty'**
  String get errorCategoryNameEmpty;

  /// Error shown when the category name is longer than the maximum length
  ///
  /// In en, this message translates to:
  /// **'Category name is too long'**
  String get errorCategoryNameTooLong;

  /// Error shown when the category name is shorter than the minimum length
  ///
  /// In en, this message translates to:
  /// **'Category name is too short'**
  String get errorCategoryNameTooShort;

  /// Error shown when accounts fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading accounts: {error}'**
  String errorLoadingAccounts(String error);

  /// Error shown when the calendar data fails to load
  ///
  /// In en, this message translates to:
  /// **'Error loading calendar: {error}'**
  String errorLoadingCalendar(String error);

  /// Error shown when categories fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading categories: {error}'**
  String errorLoadingCategories(String error);

  /// Error loading transaction data
  ///
  /// In en, this message translates to:
  /// **'Error loading transaction: {error}'**
  String errorLoadingTransaction(String error);

  /// Error shown when transactions for the list fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading transactions: {error}'**
  String errorLoadingTransactions(String error);

  /// Expense transaction type
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// Title for the expenses by category pie chart section
  ///
  /// In en, this message translates to:
  /// **'Expenses by Category'**
  String get expensesByCategory;

  /// Expense transaction type
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expenseType;

  /// Title for the transaction filter dialog
  ///
  /// In en, this message translates to:
  /// **'Filter Transactions'**
  String get filterTitle;

  /// Language name for French
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// Native language name for French
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get frenchNative;

  /// Recurrence frequency: daily
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get frequencyDaily;

  /// Label for the recurrence frequency selector
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequencyLabel;

  /// Recurrence frequency: monthly
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get frequencyMonthly;

  /// Recurrence frequency: weekly
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get frequencyWeekly;

  /// Recurrence frequency: yearly
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get frequencyYearly;

  /// Label for 'from' account in transfer transaction form
  ///
  /// In en, this message translates to:
  /// **'From Account'**
  String get fromAccountLabel;

  /// Button to go back from error screen
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBackAction;

  /// Income transaction type
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// Income transaction type
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomeType;

  /// Color option: Indigo
  ///
  /// In en, this message translates to:
  /// **'Indigo'**
  String get indigo;

  /// Title for the language settings section
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Color option: Lime
  ///
  /// In en, this message translates to:
  /// **'Lime'**
  String get lime;

  /// Subtitle for the Budgets entry on the More screen
  ///
  /// In en, this message translates to:
  /// **'Set monthly spending limits per category'**
  String get manageBudgets;

  /// Subtitle for the Recurring Transactions entry on the More screen
  ///
  /// In en, this message translates to:
  /// **'Manage subscriptions and recurring bills'**
  String get manageRecurringTransactions;

  /// Title for the monthly insights screen
  ///
  /// In en, this message translates to:
  /// **'Monthly Insights'**
  String get monthlyInsights;

  /// Hint text for the budget monthly limit field
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get monthlyLimitHint;

  /// Label for the budget monthly limit field
  ///
  /// In en, this message translates to:
  /// **'Monthly Limit'**
  String get monthlyLimitLabel;

  /// Label for the more options view
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// AppBar title for creating a new budget
  ///
  /// In en, this message translates to:
  /// **'New Budget'**
  String get newBudgetTitle;

  /// AppBar title for creating a new recurring transaction
  ///
  /// In en, this message translates to:
  /// **'New Recurring Transaction'**
  String get newRecurringTransactionTitle;

  /// AppBar title for creating new transaction
  ///
  /// In en, this message translates to:
  /// **'New Transaction'**
  String get newTransactionTitle;

  /// Prefix label before a recurring transaction's next due date
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextOccurrenceLabel;

  /// Shown when a transaction has no account associated
  ///
  /// In en, this message translates to:
  /// **'No account info'**
  String get noAccountInfo;

  /// Empty state message on the Budgets list screen
  ///
  /// In en, this message translates to:
  /// **'No budgets yet'**
  String get noBudgetsMessage;

  /// Message when there is no transaction data for the selected period
  ///
  /// In en, this message translates to:
  /// **'No data for this period'**
  String get noDataForPeriod;

  /// Shown when a transaction has no description
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// Label/toggle indicating a recurring transaction has no end date
  ///
  /// In en, this message translates to:
  /// **'No end date'**
  String get noEndDateLabel;

  /// Message when there are no expenses to display
  ///
  /// In en, this message translates to:
  /// **'No expenses found'**
  String get noExpensesFound;

  /// Empty state message on the Recurring Transactions list screen
  ///
  /// In en, this message translates to:
  /// **'No recurring transactions yet'**
  String get noRecurringTransactionsMessage;

  /// Message when there are no transactions on the selected day
  ///
  /// In en, this message translates to:
  /// **'No transactions on {date}'**
  String noTransactionsOnDate(String date);

  /// Label for the primary color selection in theme settings
  ///
  /// In en, this message translates to:
  /// **'Primary Color'**
  String get primaryColor;

  /// Color option: Purple
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get purple;

  /// Success message after deleting a recurring transaction
  ///
  /// In en, this message translates to:
  /// **'Recurring transaction deleted successfully'**
  String get recurringTransactionDeletedSuccess;

  /// Hint text for the recurring transaction name field
  ///
  /// In en, this message translates to:
  /// **'e.g. Netflix, Rent'**
  String get recurringTransactionNameHint;

  /// Label for the recurring transaction name field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get recurringTransactionNameLabel;

  /// Title for the Recurring Transactions list screen and its More-screen entry
  ///
  /// In en, this message translates to:
  /// **'Recurring Transactions'**
  String get recurringTransactions;

  /// Label for a budget's remaining (unspent) amount this month
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remainingLabel;

  /// Validation error when a transfer's from and to accounts are the same
  ///
  /// In en, this message translates to:
  /// **'From and To accounts must be different'**
  String get sameTransferAccountError;

  /// Account validation error
  ///
  /// In en, this message translates to:
  /// **'Please select an account'**
  String get selectAccountError;

  /// Account dropdown hint
  ///
  /// In en, this message translates to:
  /// **'Select an account'**
  String get selectAccountHint;

  /// Subtitle for the language settings section
  ///
  /// In en, this message translates to:
  /// **'Select app language'**
  String get selectAppLanguage;

  /// Category validation error
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get selectCategoryError;

  /// Category dropdown hint
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get selectCategoryHint;

  /// Date field hint text
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDateHint;

  /// Time field hint text
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get selectTimeHint;

  /// Title for the settings view
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language name for Spanish
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// Native language name for Spanish
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get spanishNative;

  /// Label for a budget's amount spent so far this month
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spentLabel;

  /// Label for a recurring transaction's start date
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDateLabel;

  /// Label indicating that a category is a system category
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// Color option: Teal
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get teal;

  /// Title for the theme settings section
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Fallback entity name for delete confirmation
  ///
  /// In en, this message translates to:
  /// **'this account'**
  String get thisAccount;

  /// Fallback entity name for delete confirmation
  ///
  /// In en, this message translates to:
  /// **'this budget'**
  String get thisBudget;

  /// Fallback entity name for delete confirmation
  ///
  /// In en, this message translates to:
  /// **'this category'**
  String get thisCategory;

  /// Fallback entity name for delete confirmation
  ///
  /// In en, this message translates to:
  /// **'this recurring transaction'**
  String get thisRecurringTransaction;

  /// Fallback entity name for delete confirmation
  ///
  /// In en, this message translates to:
  /// **'this transaction'**
  String get thisTransaction;

  /// Time field label
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// Label for 'to' account in transfer transaction form
  ///
  /// In en, this message translates to:
  /// **'To Account'**
  String get toAccountLabel;

  /// Label for total expense stat card
  ///
  /// In en, this message translates to:
  /// **'Total Expense'**
  String get totalExpense;

  /// Label for total income stat card
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get totalIncome;

  /// Success message after creation
  ///
  /// In en, this message translates to:
  /// **'Transaction created successfully!'**
  String get transactionCreatedSuccess;

  /// Success message after deletion
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted successfully'**
  String get transactionDeletedSuccess;

  /// Error message after failed deletion
  ///
  /// In en, this message translates to:
  /// **'Failed to delete transaction: {error}'**
  String transactionDeleteError(String error);

  /// Generic save error message
  ///
  /// In en, this message translates to:
  /// **'Failed to save transaction'**
  String get transactionSaveError;

  /// Generic transaction title
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transactionTitle;

  /// Transaction type selector label
  ///
  /// In en, this message translates to:
  /// **'Transaction Type'**
  String get transactionTypeLabel;

  /// Success message after update
  ///
  /// In en, this message translates to:
  /// **'Transaction updated successfully!'**
  String get transactionUpdatedSuccess;

  /// Info banner summarizing a transfer before it's saved
  ///
  /// In en, this message translates to:
  /// **'This will move {amount} from {fromAccount} to {toAccount}.'**
  String transferSummary(String amount, String fromAccount, String toAccount);

  /// Transfer transaction type
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transferType;

  /// Fallback label when a category is missing or unknown
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownCategory;

  /// Update action/button
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Button to update an existing budget
  ///
  /// In en, this message translates to:
  /// **'Update Budget'**
  String get updateBudgetButton;

  /// Button to update an existing recurring transaction
  ///
  /// In en, this message translates to:
  /// **'Update Recurring Transaction'**
  String get updateRecurringTransactionButton;

  /// Button to update existing transaction
  ///
  /// In en, this message translates to:
  /// **'Update Transaction'**
  String get updateTransactionButton;

  /// Short label for Friday in calendar header
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayFri;

  /// Short label for Monday in calendar header
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayMon;

  /// Short label for Saturday in calendar header
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdaySat;

  /// Short label for Sunday in calendar header
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdaySun;

  /// Short label for Thursday in calendar header
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayThu;

  /// Short label for Tuesday in calendar header
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayTue;

  /// Short label for Wednesday in calendar header
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayWed;

  /// Color option: Yellow
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get yellow;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
