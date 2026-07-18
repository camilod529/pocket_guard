import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';

/// Shared category selector used by both the transaction and recurring
/// transaction forms - unified from two near-identical private
/// implementations. Both used to reach into their own feature's provider
/// directly inside onChanged; this takes a callback instead so the widget
/// itself has no dependency on either provider.
///
/// Keyed by category id (String) rather than CategoryEntity itself, for
/// the same reason as AccountSelectorField: CategoryEntity doesn't
/// override `==`/hashCode, which DropdownMenu relies on for selection
/// matching across rebuilds.
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
      data: (categories) => _buildDropdown(context, categories),
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildDropdown(BuildContext context, List<CategoryEntity> categories) {
    final filteredCategories = categories
        .where((cat) => cat.type == type)
        .toList();
    final showError = categoryId == null && !isFormPure;

    return LayoutBuilder(
      builder: (context, constraints) {
        return DropdownMenu<String>(
          width: constraints.maxWidth,
          initialSelection: filteredCategories.any((c) => c.id == categoryId)
              ? categoryId
              : null,
          label: Text(l10n.categoryLabel),
          hintText: l10n.selectCategoryHint,
          errorText: showError ? l10n.selectCategoryError : null,
          leadingIcon: Icon(prefixIcon),
          enableFilter: true,
          requestFocusOnTap: true,
          dropdownMenuEntries: filteredCategories
              .map(
                (category) => DropdownMenuEntry<String>(
                  value: category.id,
                  label: category.label,
                ),
              )
              .toList(),
          onSelected: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        );
      },
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
