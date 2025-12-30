import 'package:formz/formz.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/infrastructure/inputs/categories/category_name.dart';
import 'package:pocket_guard/presentation/providers/category/categories_provider.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_form_provider.g.dart';

@riverpod
class CategoryForm extends _$CategoryForm {
  @override
  Future<CategoryFormState> build(String categoryId) async {
    final isCreating = categoryId == GlobalConstants.createId;

    if (!isCreating) {
      final category = await ref.watch(categoryProvider(categoryId).future);
      if (category != null) {
        return CategoryFormState(
          id: category.id,
          name: CategoryNameInput.dirty(category.label),
          type: category.type,
          isFormValid: true,
          isSystem: category.isSystem,
        );
      }
    }

    // Default to expense for new categories
    return CategoryFormState(
      type: TransactionType.expense,
      name: const CategoryNameInput.pure(),
      isFormValid: false,
    );
  }

  void nameChanged(String value) {
    final currentState = state.value;
    if (currentState == null) return;

    final name = CategoryNameInput.dirty(value);
    state = AsyncValue.data(
      currentState.copyWith(
        name: name,
        isFormValid: _isValid(name: name, type: currentState.type),
      ),
    );
  }

  Future<bool> onFormSubmit() async {
    final currentState = state.value;
    if (currentState == null || !currentState.isFormValid) return false;

    _touchAllFields();

    final validState = state.value;
    if (validState == null || !validState.isFormValid) return false;

    try {
      final category = CategoryEntity(
        id: validState.id,
        label: validState.name.value,
        type: validState.type,
        isSystem: false, // User-created
      );

      final isEditing = validState.id != GlobalConstants.createId;

      if (isEditing) {
        await ref
            .read(categoriesProvider.notifier)
            .updateCategory(validState.id, category);
      } else {
        await ref.read(categoriesProvider.notifier).createCategory(category);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  void typeChanged(TransactionType type) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(
        type: type,
        isFormValid: _isValid(name: currentState.name, type: type),
      ),
    );
  }

  bool _isValid({
    required CategoryNameInput name,
    required TransactionType type,
  }) {
    return Formz.validate([name]);
  }

  void _touchAllFields() {
    final currentState = state.value;
    if (currentState == null) return;

    final name = CategoryNameInput.dirty(currentState.name.value);
    state = AsyncValue.data(
      currentState.copyWith(
        name: name,
        isFormValid: _isValid(name: name, type: currentState.type),
      ),
    );
  }
}

class CategoryFormState {
  final bool isFormValid;
  final String id;
  final CategoryNameInput name;
  final TransactionType type;
  final bool isSystem;

  const CategoryFormState({
    this.isFormValid = false,
    this.id = GlobalConstants.createId,
    this.name = const CategoryNameInput.pure(),
    this.type = TransactionType.expense,
    this.isSystem = false,
  });

  CategoryFormState copyWith({
    bool? isFormValid,
    String? id,
    CategoryNameInput? name,
    TransactionType? type,
    bool? isSystem,
  }) {
    return CategoryFormState(
      isFormValid: isFormValid ?? this.isFormValid,
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isSystem: isSystem ?? this.isSystem,
    );
  }
}
