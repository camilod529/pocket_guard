import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
    Locale('es')
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

  /// Add new account button
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get addAccount;

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Money Manager'**
  String get appTitle;

  /// Label for the calendar view
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// Cancel action/button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

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

  /// Delete action/button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

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

  /// A simple greeting message
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get helloWorld;

  /// Label for the more options view
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
