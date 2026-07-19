import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_guard/config/router/routes.dart';
import 'package:pocket_guard/domain/entities/category.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/category/categories_provider.dart';

class CategoryView extends ConsumerWidget {
  const CategoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.categories)),
      body: categoriesAsync.when(
        data: (categories) => _buildCategoriesList(
          context,
          categories: categories,
          localizations: localizations,
          ref: ref,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              ElevatedButton(
                onPressed: () =>
                    ref.read(categoriesProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesList(
    BuildContext context, {
    required List<CategoryEntity> categories,
    required AppLocalizations localizations,
    required WidgetRef ref,
  }) {
    final incomeCats = categories
        .where((c) => c.type == TransactionType.income)
        .toList();
    final expenseCats = categories
        .where((c) => c.type == TransactionType.expense)
        .toList();

    return ListView(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 80),
      children: [
        if (incomeCats.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            localizations.incomeType,
            Icons.trending_up,
          ),
          ...incomeCats.map((cat) => _buildCategoryTile(context, cat, ref)),
        ],
        const SizedBox(height: 24),
        if (expenseCats.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            localizations.expenseType,
            Icons.trending_down,
          ),
          ...expenseCats.map((cat) => _buildCategoryTile(context, cat, ref)),
        ],
      ],
    );
  }

  Widget _buildCategoryTile(
    BuildContext context,
    CategoryEntity category,
    WidgetRef ref,
  ) {
    final localizations = AppLocalizations.of(context)!;
    final isSystem = category.isSystem;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(context, category.type),
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          child: Icon(_getTypeIcon(category.type)),
        ),
        title: Text(category.label),
        subtitle: Text(isSystem ? localizations.system : localizations.custom),
        onTap: () => context.push(Routes.categoryFormPage(category.id)),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(BuildContext context, TransactionType type) {
    final colors = Theme.of(context).colorScheme;
    switch (type) {
      case TransactionType.income:
        return colors.primaryContainer;
      case TransactionType.expense:
        return colors.tertiaryContainer;
      case TransactionType.transfer:
        return colors.secondaryContainer;
    }
  }

  IconData _getTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return Icons.arrow_upward;
      case TransactionType.expense:
        return Icons.arrow_downward;
      case TransactionType.transfer:
        return Icons.swap_horiz;
    }
  }
}
