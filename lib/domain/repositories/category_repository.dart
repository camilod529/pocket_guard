import 'package:money_manager_flutter/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<void> createCategory(CategoryEntity category);
  Future<void> deleteCategory(String id);
  Future<List<CategoryEntity>> getAllCategories();
  Future<CategoryEntity?> getCategoryById(String id);
  Future<List<CategoryEntity>> searchCategories(String query);
  Future<void> updateCategory(String id, CategoryEntity category);
}
