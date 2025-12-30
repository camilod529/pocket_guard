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
  String get accountDeletedSuccessfully => 'Account deleted successfully';

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
  String get addAccount => 'Add Account';

  @override
  String get amountHint => '0.00';

  @override
  String get amountLabel => 'Amount';

  @override
  String get appTitle => 'Money Manager';

  @override
  String get blue => 'Blue';

  @override
  String get calendar => 'Calendar';

  @override
  String get calendarGoToToday => 'Go to today';

  @override
  String get calendarNextMonth => 'Next month';

  @override
  String get calendarPreviousMonth => 'Previous month';

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
  String get categoryLabel => 'Category';

  @override
  String get categoryName => 'Category Name';

  @override
  String get chooseYourAppColor => 'Choose your app color';

  @override
  String get create => 'Create';

  @override
  String get createAccount => 'Create Account';

  @override
  String get createCategory => 'Create Category';

  @override
  String get createTransaction => 'Create Transaction';

  @override
  String get createTransactionButton => 'Create Transaction';

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
  String get deleteAccount => 'Delete Account';

  @override
  String deleteAccountConfirmation(String accountName) {
    return 'Are you sure you want to delete the account \"$accountName\"? This will also delete all associated transactions.';
  }

  @override
  String get deleteAccountSuccess => 'Account deleted successfully';

  @override
  String get deleteAction => 'Delete';

  @override
  String deleteCategoryConfirmation(String categoryName) {
    return 'Are you sure you want to delete the category \"$categoryName\"? This will also delete all associated transactions.';
  }

  @override
  String get deleteCategoryTitle => 'Delete Category';

  @override
  String get deleteTransactionDescription => 'This action cannot be undone.';

  @override
  String get deleteTransactionTitle => 'Delete Transaction';

  @override
  String get descriptionHint => 'Enter transaction description';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get edit => 'Edit';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get editTransactionTitle => 'Edit Transaction';

  @override
  String get english => 'English';

  @override
  String get englishNative => 'English';

  @override
  String get error_data_not_found => 'The requested data was not found.';

  @override
  String error_data_not_found_entity(String entity) {
    return 'The requested $entity was not found.';
  }

  @override
  String get error_db_closed => 'Database connection is not available. Please restart the app.';

  @override
  String get error_db_constraint_violation => 'A database constraint was violated. This might be a duplicate entry or invalid reference.';

  @override
  String get error_db_operation_failed => 'Database operation failed. Please try again.';

  @override
  String error_db_operation_failed_operation(String operation) {
    return 'Failed to $operation. Please try again.';
  }

  @override
  String get error_foreign_key_violation => 'Cannot complete operation because it references data that no longer exists.';

  @override
  String error_foreign_key_violation_table(String table) {
    return 'Cannot complete operation because it references a $table that no longer exists.';
  }

  @override
  String get error_storage_full => 'Device storage is full. Please free up space and try again.';

  @override
  String get error_unique_constraint_violation => 'This record already exists.';

  @override
  String error_unique_constraint_violation_field(String field) {
    return 'A record with this $field already exists.';
  }

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
  String get expenseType => 'Expense';

  @override
  String get fabAddTransactionTooltip => 'Add transaction';

  @override
  String get fromAccountLabel => 'From Account';

  @override
  String get goBackAction => 'Go Back';

  @override
  String get helloWorld => 'Hello World!';

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
  String get more => 'More';

  @override
  String get newTransactionTitle => 'New Transaction';

  @override
  String get noAccountInfo => 'No account info';

  @override
  String get noDescription => 'No description';

  @override
  String noTransactionsOnDate(String date) {
    return 'No transactions on $date';
  }

  @override
  String get primaryColor => 'Primary Color';

  @override
  String get purple => 'Purple';

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
  String get system => 'System';

  @override
  String get teal => 'Teal';

  @override
  String get theme => 'Theme';

  @override
  String get thisCategory => 'this category';

  @override
  String get thisTransaction => 'this transaction';

  @override
  String get timeLabel => 'Time';

  @override
  String get toAccountLabel => 'To Account';

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
  String get transferType => 'Transfer';

  @override
  String get unknownCategory => 'Unknown';

  @override
  String get update => 'Update';

  @override
  String get updateTransactionButton => 'Update Transaction';

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
  String get yellow => 'Yellow';
}
