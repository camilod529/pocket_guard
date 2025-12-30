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

  /// Hint text for account currency in`put
  ///
  /// In en, this message translates to:
  /// **'USD, EUR, GBP'**
  String get accountCurrencyHint;

  /// Success message after account deletion
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get accountDeletedSuccessfully;

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

  /// Add new account button
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get addAccount;

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

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Money Manager'**
  String get appTitle;

  /// Color option: Blue
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get blue;

  /// Label for the calendar view
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// Tooltip for jumping back to the current day/month
  ///
  /// In en, this message translates to:
  /// **'Go to today'**
  String get calendarGoToToday;

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

  /// Button to create a new category
  ///
  /// In en, this message translates to:
  /// **'Create Category'**
  String get createCategory;

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

  /// Delete account button
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Delete account confirmation message with account name
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the account \"{accountName}\"? This will also delete all associated transactions.'**
  String deleteAccountConfirmation(String accountName);

  /// Success message after account deletion
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get deleteAccountSuccess;

  /// Delete button tooltip
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

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

  /// AppBar title for editing existing category
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// AppBar title for editing existing transaction
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransactionTitle;

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

  /// Generic data not found error
  ///
  /// In en, this message translates to:
  /// **'The requested data was not found.'**
  String get error_data_not_found;

  /// Data not found error with the entity name
  ///
  /// In en, this message translates to:
  /// **'The requested {entity} was not found.'**
  String error_data_not_found_entity(String entity);

  /// Shown when the database is closed or not available
  ///
  /// In en, this message translates to:
  /// **'Database connection is not available. Please restart the app.'**
  String get error_db_closed;

  /// Generic database constraint violation message
  ///
  /// In en, this message translates to:
  /// **'A database constraint was violated. This might be a duplicate entry or invalid reference.'**
  String get error_db_constraint_violation;

  /// Generic database operation failure message
  ///
  /// In en, this message translates to:
  /// **'Database operation failed. Please try again.'**
  String get error_db_operation_failed;

  /// Database operation failure message with the operation name
  ///
  /// In en, this message translates to:
  /// **'Failed to {operation}. Please try again.'**
  String error_db_operation_failed_operation(String operation);

  /// Foreign key violation without specifying the table
  ///
  /// In en, this message translates to:
  /// **'Cannot complete operation because it references data that no longer exists.'**
  String get error_foreign_key_violation;

  /// Foreign key violation specifying the referenced table
  ///
  /// In en, this message translates to:
  /// **'Cannot complete operation because it references a {table} that no longer exists.'**
  String error_foreign_key_violation_table(String table);

  /// Device storage is full
  ///
  /// In en, this message translates to:
  /// **'Device storage is full. Please free up space and try again.'**
  String get error_storage_full;

  /// Unique constraint violation without specifying the field
  ///
  /// In en, this message translates to:
  /// **'This record already exists.'**
  String get error_unique_constraint_violation;

  /// Unique constraint violation for a specific field
  ///
  /// In en, this message translates to:
  /// **'A record with this {field} already exists.'**
  String error_unique_constraint_violation_field(String field);

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

  /// Expense transaction type
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expenseType;

  /// Tooltip for FAB that creates a new transaction from the calendar view
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get fabAddTransactionTooltip;

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

  /// A simple greeting message
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get helloWorld;

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

  /// Label for the more options view
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// AppBar title for creating new transaction
  ///
  /// In en, this message translates to:
  /// **'New Transaction'**
  String get newTransactionTitle;

  /// Shown when a transaction has no account associated
  ///
  /// In en, this message translates to:
  /// **'No account info'**
  String get noAccountInfo;

  /// Shown when a transaction has no description
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

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
  /// **'this category'**
  String get thisCategory;

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
