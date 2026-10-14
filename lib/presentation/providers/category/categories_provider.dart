import 'package:pocket_guard/domain/data_sources/category_data_source.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/domain/repositories/category_repository.dart';
import 'package:pocket_guard/infrastructure/data_sources/category_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/repositories/category_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'categories_provider.g.dart';

// Helper provider to get categories filtered by type
@riverpod
Future<List<CategoryEntity>> categoriesByType(
  Ref ref,
  TransactionType type,
) async {
  final allCategories = await ref.watch(categoriesProvider.future);
  return allCategories.where((cat) => cat.type == type).toList();
}

@Riverpod(keepAlive: true)
CategoryDataSource categoryDataSource(Ref ref) {
  return CategoryDriftDataSourceImpl();
}

@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(Ref ref) {
  final dataSource = ref.watch(categoryDataSourceProvider);
  return CategoryRepositoryImpl(dataSource: dataSource);
}

// Same error contract as BudgetsNotifier: mutating methods revert to the
// previous state and rethrow instead of setting `AsyncValue.error`. Setting
// the error swallowed failures - deleting a category still used by
// transactions showed "deleted successfully" - and replaced the whole list
// with an error screen.
@riverpod
class CategoriesNotifier extends _$CategoriesNotifier {
  @override
  Future<List<CategoryEntity>> build() async {
    final repository = ref.read(categoryRepositoryProvider);
    return await repository.getAllCategories();
  }

  Future<void> createCategory(CategoryEntity category) =>
      _mutate((repository) => repository.createCategory(category));

  Future<void> deleteCategory(String id) =>
      _mutate((repository) => repository.deleteCategory(id));

  // Filter categories by type
  List<CategoryEntity> getCategoriesByType(TransactionType type) {
    final categoriesData = state.value;
    if (categoriesData == null) return [];

    return categoriesData.where((cat) => cat.type == type).toList();
  }

  Future<void> refresh() => _mutate((_) async {});

  Future<void> updateCategory(String id, CategoryEntity category) =>
      _mutate((repository) => repository.updateCategory(id, category));

  Future<void> _mutate(
    Future<void> Function(CategoryRepository repository) action,
  ) async {
    if (!ref.mounted) return;
    final previousState = state;
    state = const AsyncLoading();
    try {
      final repository = ref.read(categoryRepositoryProvider);
      await action(repository);
      if (!ref.mounted) return;
      state = AsyncValue.data(await repository.getAllCategories());
    } catch (e) {
      if (ref.mounted) state = previousState;
      rethrow;
    }
  }
}

// Single category provider for editing
@riverpod
class CategoryNotifier extends _$CategoryNotifier {
  @override
  Future<CategoryEntity?> build(String categoryId) async {
    if (categoryId == 'create' || categoryId.isEmpty) {
      return null;
    }

    final repository = ref.read(categoryRepositoryProvider);
    return await repository.getCategoryById(categoryId);
  }

  Future<void> updateCategory(CategoryEntity category) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(categoryRepositoryProvider);
      await repository.updateCategory(category.id, category);

      // Refresh the categories list
      ref.invalidate(categoriesProvider);

      state = AsyncValue.data(category);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
