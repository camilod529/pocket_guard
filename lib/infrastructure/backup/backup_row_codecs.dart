import 'package:drift/drift.dart';
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/entities/account.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/domain/entities/recurring_transaction.dart';

/// Rows <-> the backup file's JSON shape, one pair per table.
///
/// Deliberately not Drift's generated toJson/fromJson: those serialize
/// enum columns as raw Dart objects (not encodable) and tie the file to
/// column getter names. Here every key is spelled out, dates are UTC
/// ISO-8601 strings, and enums are stored by *name* - so reordering an enum
/// or renaming a column later can't silently corrupt old backups. Changing
/// any key here means bumping BackupFileCodec.formatVersion.
///
/// Decoders throw [FormatException] on a missing or mistyped field; the
/// caller treats that as a corrupted backup before anything is written.
abstract final class BackupRowCodecs {
  // --- categories -------------------------------------------------------

  static Map<String, Object?> encodeCategory(Category row) => {
    'id': row.id,
    'label': row.label,
    'nameKey': row.nameKey,
    'origin': row.origin.name,
    'type': row.type.name,
  };

  static CategoriesCompanion decodeCategory(Map<String, Object?> json) {
    final r = _Reader(json, 'category');
    return CategoriesCompanion.insert(
      id: Value(r.string('id')),
      label: r.string('label'),
      nameKey: Value(r.stringOrNull('nameKey')),
      origin: r.enumByName('origin', CategoryOrigin.values),
      type: r.enumByName('type', TransactionType.values),
    );
  }

  // --- accounts ---------------------------------------------------------

  static Map<String, Object?> encodeAccount(Account row) => {
    'id': row.id,
    'name': row.name,
    'currency': row.currency,
    'balance': row.balance,
    'type': row.type.name,
    'sortOrder': row.sortOrder,
  };

  static AccountsCompanion decodeAccount(Map<String, Object?> json) {
    final r = _Reader(json, 'account');
    return AccountsCompanion.insert(
      id: Value(r.string('id')),
      name: r.string('name'),
      currency: r.string('currency'),
      balance: Value(r.number('balance')),
      type: Value(r.enumByName('type', AccountType.values)),
      sortOrder: Value(r.integer('sortOrder')),
    );
  }

  // --- transactions -----------------------------------------------------

  static Map<String, Object?> encodeTransaction(Transaction row) => {
    'id': row.id,
    'accountId': row.accountId,
    'toAccountId': row.toAccountId,
    'categoryId': row.categoryId,
    'amount': row.amount,
    'date': _date(row.date),
    'description': row.description,
  };

  static TransactionsCompanion decodeTransaction(Map<String, Object?> json) {
    final r = _Reader(json, 'transaction');
    return TransactionsCompanion.insert(
      id: Value(r.string('id')),
      accountId: r.string('accountId'),
      toAccountId: Value(r.stringOrNull('toAccountId')),
      categoryId: r.string('categoryId'),
      amount: r.number('amount'),
      date: r.date('date'),
      description: Value(r.stringOrNull('description')),
    );
  }

  // --- recurring transactions -------------------------------------------

  static Map<String, Object?> encodeRecurringTransaction(
    RecurringTransaction row,
  ) => {
    'id': row.id,
    'accountId': row.accountId,
    'toAccountId': row.toAccountId,
    'categoryId': row.categoryId,
    'amount': row.amount,
    'description': row.description,
    'frequency': row.frequency.name,
    'startDate': _date(row.startDate),
    'endDate': _dateOrNull(row.endDate),
    'nextDueDate': _date(row.nextDueDate),
    'lastGeneratedDate': _dateOrNull(row.lastGeneratedDate),
    'isActive': row.isActive,
  };

  static RecurringTransactionsCompanion decodeRecurringTransaction(
    Map<String, Object?> json,
  ) {
    final r = _Reader(json, 'recurring transaction');
    return RecurringTransactionsCompanion.insert(
      id: Value(r.string('id')),
      accountId: r.string('accountId'),
      toAccountId: Value(r.stringOrNull('toAccountId')),
      categoryId: r.string('categoryId'),
      amount: r.number('amount'),
      description: r.string('description'),
      frequency: Value(r.enumByName('frequency', RecurrenceFrequency.values)),
      startDate: r.date('startDate'),
      endDate: Value(r.dateOrNull('endDate')),
      nextDueDate: r.date('nextDueDate'),
      lastGeneratedDate: Value(r.dateOrNull('lastGeneratedDate')),
      isActive: Value(r.boolean('isActive')),
    );
  }

  // --- savings goals ----------------------------------------------------

  static Map<String, Object?> encodeSavingsGoal(SavingsGoal row) => {
    'id': row.id,
    'name': row.name,
    'targetAmount': row.targetAmount,
    'currency': row.currency,
    'targetDate': _dateOrNull(row.targetDate),
    'isArchived': row.isArchived,
    'createdAt': _date(row.createdAt),
  };

  static SavingsGoalsCompanion decodeSavingsGoal(Map<String, Object?> json) {
    final r = _Reader(json, 'savings goal');
    return SavingsGoalsCompanion.insert(
      id: Value(r.string('id')),
      name: r.string('name'),
      targetAmount: r.number('targetAmount'),
      currency: r.string('currency'),
      targetDate: Value(r.dateOrNull('targetDate')),
      isArchived: Value(r.boolean('isArchived')),
      createdAt: Value(r.date('createdAt')),
    );
  }

  static Map<String, Object?> encodeGoalContribution(GoalContribution row) => {
    'id': row.id,
    'goalId': row.goalId,
    'accountId': row.accountId,
    'amount': row.amount,
    'date': _date(row.date),
    'note': row.note,
  };

  static GoalContributionsCompanion decodeGoalContribution(
    Map<String, Object?> json,
  ) {
    final r = _Reader(json, 'goal contribution');
    return GoalContributionsCompanion.insert(
      id: Value(r.string('id')),
      goalId: r.string('goalId'),
      accountId: Value(r.stringOrNull('accountId')),
      amount: r.number('amount'),
      date: r.date('date'),
      note: Value(r.stringOrNull('note')),
    );
  }

  // --- budgets ----------------------------------------------------------

  static Map<String, Object?> encodeBudget(Budget row) => {
    'id': row.id,
    'categoryId': row.categoryId,
    'monthlyLimit': row.monthlyLimit,
    'currency': row.currency,
    'isActive': row.isActive,
  };

  static BudgetsCompanion decodeBudget(Map<String, Object?> json) {
    final r = _Reader(json, 'budget');
    return BudgetsCompanion.insert(
      id: Value(r.string('id')),
      categoryId: r.string('categoryId'),
      monthlyLimit: r.number('monthlyLimit'),
      currency: r.string('currency'),
      isActive: Value(r.boolean('isActive')),
    );
  }

  // --- wishlist ---------------------------------------------------------

  static Map<String, Object?> encodeWishlistItem(WishlistItem row) => {
    'id': row.id,
    'name': row.name,
    'price': row.price,
    'currency': row.currency,
    'categoryId': row.categoryId,
    'goalId': row.goalId,
    'purchasedAt': _dateOrNull(row.purchasedAt),
    'createdAt': _date(row.createdAt),
  };

  static WishlistItemsCompanion decodeWishlistItem(Map<String, Object?> json) {
    final r = _Reader(json, 'wishlist item');
    return WishlistItemsCompanion.insert(
      id: Value(r.string('id')),
      name: r.string('name'),
      price: r.number('price'),
      currency: r.string('currency'),
      categoryId: Value(r.stringOrNull('categoryId')),
      goalId: Value(r.stringOrNull('goalId')),
      purchasedAt: Value(r.dateOrNull('purchasedAt')),
      createdAt: Value(r.date('createdAt')),
    );
  }

  static String _date(DateTime value) => value.toUtc().toIso8601String();

  static String? _dateOrNull(DateTime? value) =>
      value == null ? null : _date(value);
}

/// Typed field access that fails with a [FormatException] naming the
/// record and field, instead of a bare cast error.
class _Reader {
  _Reader(this.json, this.record);

  final Map<String, Object?> json;
  final String record;

  bool boolean(String key) => _required<bool>(key);

  DateTime date(String key) => _parseDate(key, _required<String>(key));

  DateTime? dateOrNull(String key) {
    final value = _optional<String>(key);
    return value == null ? null : _parseDate(key, value);
  }

  T enumByName<T extends Enum>(String key, List<T> values) {
    final name = _required<String>(key);
    for (final value in values) {
      if (value.name == name) return value;
    }
    throw FormatException('Unknown $record.$key value: $name');
  }

  int integer(String key) => _required<num>(key).toInt();

  double number(String key) => _required<num>(key).toDouble();

  String string(String key) => _required<String>(key);

  String? stringOrNull(String key) => _optional<String>(key);

  T? _optional<T>(String key) {
    final value = json[key];
    if (value == null || value is T) return value as T?;
    throw FormatException('$record.$key should be $T, got $value');
  }

  DateTime _parseDate(String key, String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      throw FormatException('$record.$key is not a date: $value');
    }
    return parsed.toLocal();
  }

  T _required<T>(String key) {
    final value = json[key];
    if (value is T) return value;
    throw FormatException('$record.$key should be $T, got $value');
  }
}
