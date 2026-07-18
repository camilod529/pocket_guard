import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/infrastructure/inputs/categories/category_name.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/category/categories_provider.dart';
import 'package:pocket_guard/presentation/providers/category/category_form_provider.dart';
import 'package:pocket_guard/presentation/widgets/shared/delete_confirmation_modal.dart';
import 'package:pocket_guard/presentation/widgets/shared/forms/custom_form_field.dart';
import 'package:pocket_guard/utils/constants/global_constants.dart';
import 'package:pocket_guard/utils/shared/transaction_icons.dart';

class CategoryFormScreen extends ConsumerWidget {
  final String categoryId;
  const CategoryFormScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final formAsync = ref.watch(categoryFormProvider(categoryId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          categoryId == GlobalConstants.createId
              ? localizations.createCategory
              : localizations.editCategory,
        ),
        actions: [
          formAsync.when(
            data: (data) {
              return IconButton(
                icon: const Icon(Icons.delete),
                onPressed:
                    categoryId == GlobalConstants.createId || data.isSystem
                    ? null
                    : () {
                        _handleDelete(
                          context,
                          data,
                          localizations,
                          () => ref
                              .read(categoriesProvider.notifier)
                              .deleteCategory(categoryId),
                        );
                      },
              );
            },
            error: (_, _) => SizedBox(),
            loading: () => const SizedBox(),
          ),
        ],
      ),
      body: formAsync.when(
        data: (state) => _buildForm(context, ref, state),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    WidgetRef ref,
    CategoryFormState state,
  ) {
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomFormField(
            initialValue: state.name.value,
            label: localizations.categoryName,
            errorText: state.name.displayError != null
                ? _getErrorTranslation(context, state.name.error)
                : null,
            onChanged: (value) => ref
                .read(categoryFormProvider(categoryId).notifier)
                .nameChanged(value),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              return DropdownMenu<TransactionType>(
                width: constraints.maxWidth,
                initialSelection: state.type,
                label: Text(localizations.transactionTypeLabel),
                selectOnly: true,
                leadingIcon: Icon(TransactionIcons.getIconByType(state.type)),
                dropdownMenuEntries: [
                  DropdownMenuEntry(
                    value: TransactionType.income,
                    label: localizations.income,
                    leadingIcon: Icon(
                      TransactionIcons.getIconByType(TransactionType.income),
                    ),
                  ),
                  DropdownMenuEntry(
                    value: TransactionType.expense,
                    label: localizations.expense,
                    leadingIcon: Icon(
                      TransactionIcons.getIconByType(TransactionType.expense),
                    ),
                  ),
                ],
                onSelected: (type) {
                  if (type != null) {
                    ref
                        .read(categoryFormProvider(categoryId).notifier)
                        .typeChanged(type);
                  }
                },
              );
            },
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: state.isFormValid
                ? () async {
                    final success = await ref
                        .read(categoryFormProvider(categoryId).notifier)
                        .onFormSubmit();
                    if (success) {
                      if (context.mounted) {
                        context.pop();
                      }
                    }
                  }
                : null,
            child: Text(
              categoryId == GlobalConstants.createId
                  ? localizations.create
                  : localizations.update,
            ),
          ),
        ],
      ),
    );
  }

  String? _getErrorTranslation(BuildContext context, CategoryError? error) {
    final localizations = AppLocalizations.of(context)!;
    switch (error) {
      case CategoryError.empty:
        return localizations.errorCategoryNameEmpty;
      case CategoryError.tooLong:
        return localizations.errorCategoryNameTooLong;
      case CategoryError.tooShort:
        return localizations.errorCategoryNameTooShort;
      case null:
        return null;
    }
  }

  Future<void> _handleDelete(
    BuildContext context,
    CategoryFormState formState,
    AppLocalizations l10n,
    Future<void> Function() onSubmit,
  ) async {
    await DeleteConfirmationModal.show(
      context: context,
      title: l10n.deleteCategoryTitle,
      entity: formState.name.value.isEmpty
          ? l10n.thisCategory
          : formState.name.value,
      description: l10n.deleteCategoryConfirmation(
        formState.name.value.isEmpty ? l10n.thisCategory : formState.name.value,
      ),
      onConfirm: () async {
        try {
          await onSubmit();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.categoryDeletedSuccessfully),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            context.pop();
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.categoryDeleteError(e.toString())),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    );
  }
}
