import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/category/categories_provider.dart';
import 'package:pocket_guard/presentation/providers/transaction/transaction_filter_provider.dart';

class TransactionFilterSheet extends ConsumerWidget {
  const TransactionFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(transactionSearchFilterProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.filterTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () => ref
                    .read(transactionSearchFilterProvider.notifier)
                    .clearFilters(),
                child: Text(l10n.clearAll),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(l10n.categories, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          categoriesAsync.maybeWhen(
            data: (categories) => Wrap(
              spacing: 8,
              children: categories.map((cat) {
                final isSelected =
                    filter.categoryIds?.contains(cat.id) ?? false;
                return FilterChip(
                  label: Text(cat.label),
                  selected: isSelected,
                  onSelected: (_) => ref
                      .read(transactionSearchFilterProvider.notifier)
                      .toggleCategory(cat.id),
                );
              }).toList(),
            ),
            orElse: () => const CircularProgressIndicator(),
          ),
          const SizedBox(height: 24),
          // You could add RangeSliders here for minAmount/maxAmount
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.applyFilters),
            ),
          ),
        ],
      ),
    );
  }
}
