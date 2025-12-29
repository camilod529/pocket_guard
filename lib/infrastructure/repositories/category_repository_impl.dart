import 'package:pocket_guard/domain/data_sources/category_data_source.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/domain/repositories/category_repository.dart';
import 'package:pocket_guard/domain/services/logger_service.dart';
import 'package:pocket_guard/infrastructure/errors/data_exceptions.dart';
import 'package:pocket_guard/infrastructure/services/logger_service_impl.dart';

class CategoryRepositoryImpl extends CategoryRepository {
  final CategoryDataSource _dataSource;
  late final LoggerService _logger;

  CategoryRepositoryImpl({required CategoryDataSource dataSource})
    : _dataSource = dataSource {
    _logger = LoggerServiceImpl(runtimeType.toString());
  }

  @override
  Future<void> createCategory(CategoryEntity category) async {
    _logger.info('Creating category: ${category.label}');
    try {
      await _dataSource.createCategory(category);
      _logger.info('Category created successfully: ${category.label}');
    } on DataException catch (e, stackTrace) {
      _logger.error(
        'Failed to create category: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to create category: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    _logger.info('Deleting category with ID: $id');
    try {
      await _dataSource.deleteCategory(id);
      _logger.info('Category deleted successfully: $id');
    } on DataException catch (e, stackTrace) {
      _logger.error(
        'Failed to delete category: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to delete category: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<CategoryEntity>> getAllCategories() async {
    try {
      return await _dataSource.getAllCategories();
    } on DataException catch (e, stackTrace) {
      _logger.error(
        'Failed to fetch categories: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to fetch categories: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<CategoryEntity?> getCategoryById(String id) async {
    try {
      return await _dataSource.getCategoryById(id);
    } on DataException catch (e, stackTrace) {
      _logger.error(
        'Failed to fetch category by ID: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to fetch category by ID: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<List<CategoryEntity>> searchCategories(String query) async {
    try {
      return await _dataSource.searchCategories(query);
    } on DataException catch (e, stackTrace) {
      _logger.error(
        'Failed to search categories: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to search categories: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> updateCategory(String id, CategoryEntity category) async {
    _logger.info('Updating category: $id');
    try {
      await _dataSource.updateCategory(id, category);
      _logger.info('Category updated successfully: $id');
    } on DataException catch (e, stackTrace) {
      _logger.error(
        'Failed to update category: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to update category: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
