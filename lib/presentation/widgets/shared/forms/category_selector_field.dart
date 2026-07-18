import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/widgets/shared/forms/common_drop_down.dart';

/// Shared category dropdown used by both the transaction and recurring
/// transaction forms - unified from two near-identical private
/// implementations. Both used to reach into their own feature's provider
/// directly inside onChanged; this takes a callback instead so the widget
/// itself has no dependency on either provider.
class CategorySelectorField extends StatelessWidget {
  final AsyncValue<List<CategoryEntity>> categoriesAsync;
  final AppLocalizations l10n;
  final IconData prefixIcon;
  final TransactionType type;
  final String? categoryId;
  final bool isFormPure;
  final void Function(String) onChanged;

  const CategorySelectorField({
    super.key,
    required this.categoriesAsync,
    required this.l10n,
    required this.prefixIcon,
    required this.type,
    required this.categoryId,
    required this.isFormPure,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return categoriesAsync.when(
      data: (categories) => _buildCategoryDropdown(context, categories),
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildCategoryDropdown(
    BuildContext context,
    List<CategoryEntity> categories,
  ) {
    final filteredCategories = categories
        .where((cat) => cat.type == type)
        .toList();
    final validCategoryId =
        filteredCategories.any((cat) => cat.id == categoryId)
        ? categoryId
        : null;
    final showError = categoryId == null && !isFormPure;

    return IntrinsicHeight(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.categoryLabel,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 72,
            child: DropdownButtonFormField<String>(
              key: ValueKey(filteredCategories.map((c) => c.id).join(',')),
              initialValue: validCategoryId,
              decoration: DropdownDecorationHelper.getDecoration(
                hintText: l10n.selectCategoryHint,
                prefixIcon: Icon(prefixIcon),
              ),
              isExpanded: true,
              items: filteredCategories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category.id,
                      child: Text(category.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                }
              },
            ),
          ),
          if (showError)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 8),
              child: Text(
                l10n.selectCategoryError,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.categoryLabel, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Text(l10n.errorLoadingCategories(error.toString())),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.categoryLabel, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        const LinearProgressIndicator(),
      ],
    );
  }
}
