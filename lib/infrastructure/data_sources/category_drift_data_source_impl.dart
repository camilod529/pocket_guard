import 'package:drift/drift.dart';
import 'package:pocket_guard/config/database/database.dart' as db;
import 'package:pocket_guard/config/database/database.dart';
import 'package:pocket_guard/domain/data_sources/category_data_source.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/infrastructure/errors/data_exceptions.dart';
import 'package:pocket_guard/infrastructure/errors/drift_exception_handler.dart';

class CategoryDriftDataSourceImpl extends CategoryDataSource {
  CategoryDriftDataSourceImpl({AppDatabase? database})
    : database = database ?? db.database;

  final AppDatabase database;
  final DriftExceptionHandler _exceptionHandler = DriftExceptionHandler();

  @override
  Future<void> createCategory(CategoryEntity category) async {
    try {
      await database
          .into(database.categories)
          .insert(
            CategoriesCompanion(
              label: Value(category.label),
              origin: Value(CategoryOrigin.user),
              type: Value(category.type),
            ),
          );
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'create category',
        entityName: 'category',
      );
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      final deleted = await (database.delete(
        database.categories,
      )..where((tbl) => tbl.id.equals(id))).go();

      if (deleted == 0) {
        throw DataNotFoundException(entityName: 'category');
      }
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'delete category',
        entityName: 'category',
      );
    }
  }

  @override
  Future<List<CategoryEntity>> getAllCategories() async {
    try {
      final categories = await database.select(database.categories).get();

      return categories
          .map(
            (cat) => CategoryEntity(
              id: cat.id,
              label: cat.label,
              type: cat.type,
              isSystem: cat.origin == CategoryOrigin.system,
            ),
          )
          .toList();
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'get all categories',
        entityName: 'category',
      );
    }
  }

  @override
  Future<CategoryEntity?> getCategoryById(String id) async {
    try {
      final category = await (database.select(
        database.categories,
      )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

      if (category == null) return null;

      return CategoryEntity(
        id: category.id,
        label: category.label,
        type: category.type,
        isSystem: category.origin == CategoryOrigin.system,
      );
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'get category',
        entityName: 'category',
      );
    }
  }

  @override
  Future<List<CategoryEntity>> searchCategories(String query) async {
    try {
      final categories = await (database.select(
        database.categories,
      )..where((tbl) => tbl.label.contains(query))).get();

      return categories
          .map(
            (cat) => CategoryEntity(
              id: cat.id,
              label: cat.label,
              type: cat.type,
              isSystem: cat.origin == CategoryOrigin.system,
            ),
          )
          .toList();
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'search categories',
        entityName: 'category',
      );
    }
  }

  @override
  Future<void> updateCategory(String id, CategoryEntity category) async {
    try {
      final updated =
          await (database.update(
            database.categories,
          )..where((tbl) => tbl.id.equals(id))).write(
            CategoriesCompanion(
              label: Value(category.label),
              type: Value(category.type),
            ),
          );

      if (updated == 0) {
        throw DataNotFoundException(entityName: 'category');
      }
    } catch (e, stackTrace) {
      throw _exceptionHandler.handleDriftException(
        e,
        stackTrace,
        operation: 'update category',
        entityName: 'category',
      );
    }
  }
}
