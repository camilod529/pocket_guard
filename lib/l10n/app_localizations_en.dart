// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Money Manager';

  @override
  String get helloWorld => 'Hello World!';

  @override
  String get calendar => 'Calendar';

  @override
  String get more => 'More';

  @override
  String get category_income_salary => 'Salary';

  @override
  String get category_income_freelance => 'Freelance';

  @override
  String get category_expense_food_dining => 'Food';

  @override
  String get category_expense_transportation => 'Transportation';

  @override
  String get category_expense_rent => 'Rent';

  @override
  String get category_transfer => 'Transfer';

  @override
  String get error_db_constraint_violation => 'A database constraint was violated. This might be a duplicate entry or invalid reference.';

  @override
  String get error_db_closed => 'Database connection is not available. Please restart the app.';

  @override
  String get error_db_operation_failed => 'Database operation failed. Please try again.';

  @override
  String error_db_operation_failed_operation(String operation) {
    return 'Failed to $operation. Please try again.';
  }

  @override
  String get error_data_not_found => 'The requested data was not found.';

  @override
  String error_data_not_found_entity(String entity) {
    return 'The requested $entity was not found.';
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
}
