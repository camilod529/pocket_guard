import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

part 'database.g.dart';

const _uuid = Uuid();

final database = AppDatabase();

// Table definitions
class Accounts extends Table {
  TextColumn get currency => text()();
  TextColumn get id =>
      text().clientDefault(() => _uuid.v4())(); // UUID v4 as text
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

// Data classes (optional but useful)
@DriftDatabase(tables: [Accounts, Categories, Transactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await seedDefaultCategories();
      },
    );
  }

  @override
  int get schemaVersion => 1;

  Future<void> seedDefaultCategories() async {
    final defaultCategories = [
      CategoriesCompanion.insert(
        nameKey: Value('category_income_salary'),
        label: 'Salary',
        type: CategoryType.income,
        origin: CategoryOrigin.system,
      ),
      CategoriesCompanion.insert(
        nameKey: Value('category_income_freelance'),
        label: 'Freelance',
        type: CategoryType.income,
        origin: CategoryOrigin.system,
      ),
      CategoriesCompanion.insert(
        nameKey: Value('category_expense_food_dining'),
        label: 'Food & Dining',
        type: CategoryType.expense,
        origin: CategoryOrigin.system,
      ),
      CategoriesCompanion.insert(
        nameKey: Value('category_expense_transportation'),
        label: 'Transportation',
        type: CategoryType.expense,
        origin: CategoryOrigin.system,
      ),
      CategoriesCompanion.insert(
        nameKey: Value('category_expense_rent'),
        label: 'Rent',
        type: CategoryType.expense,
        origin: CategoryOrigin.system,
      ),
      CategoriesCompanion.insert(
        nameKey: Value('category_transfer'),
        label: 'Transfer',
        type: CategoryType.transfer,
        origin: CategoryOrigin.system,
      ),
    ];

    for (final category in defaultCategories) {
      await into(categories).insert(category, mode: InsertMode.insertOrIgnore);
    }
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'my_database',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}

class Categories extends Table {
  TextColumn get id =>
      text().clientDefault(() => _uuid.v4())(); // UUID v4 as text
  TextColumn get label => text()(); // actual display text
  TextColumn get nameKey => text().nullable()(); // for system categories
  TextColumn get origin =>
      text().map(CategoryOriginConverter())(); // 'system' or 'user'
  @override
  Set<Column> get primaryKey => {id};
  TextColumn get type => text().map(CategoryTypeConverter())();
}

enum CategoryOrigin { system, user }

class CategoryOriginConverter extends TypeConverter<CategoryOrigin, String> {
  @override
  CategoryOrigin fromSql(String fromDb) => CategoryOrigin.values.firstWhere(
    (e) => e.name == fromDb,
    orElse: () => CategoryOrigin.system,
  );

  @override
  String toSql(CategoryOrigin value) => value.name;
}

// Define enums for type safety
enum CategoryType { income, expense, transfer }

// Converters for enums
class CategoryTypeConverter extends TypeConverter<CategoryType, String> {
  @override
  CategoryType fromSql(String fromDb) {
    return CategoryType.values.firstWhere(
      (e) => e.name == fromDb,
      orElse: () => CategoryType.expense,
    );
  }

  @override
  String toSql(CategoryType value) {
    return value.name;
  }
}

@TableIndex(
  name: 'transactions_index',
  columns: {#accountId, #date, #categoryId},
)
class Transactions extends Table {
  TextColumn get accountId => text().references(Accounts, #id)();
  RealColumn get amount => real()();
  TextColumn get categoryId => text().references(Categories, #id)();
  IntColumn get date => integer()();
  TextColumn get description => text().nullable()();
  TextColumn get id =>
      text().clientDefault(() => _uuid.v4())(); // UUID v4 as text

  @override
  Set<Column> get primaryKey => {id};
}
