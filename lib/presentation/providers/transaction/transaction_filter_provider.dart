import 'package:pocket_guard/domain/entities/transaction_filter.dart';
import 'package:pocket_guard/presentation/providers/selected_date_range_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_filter_provider.g.dart';

@riverpod
class TransactionSearchFilter extends _$TransactionSearchFilter {
  @override
  TransactionFilter build() {
    // 1. Use ref.read for the initial state so it doesn't re-run build()
    // every time the selected day changes.
    final dateRange = ref.read(selectedDateRangeProvider);

    // 2. Listen to changes in the date range to update ONLY the dates
    // without touching search queries or categories.
    ref.listen(selectedDateRangeProvider, (previous, next) {
      if (previous?.start != next.start || previous?.end != next.end) {
        state = TransactionFilter(
          searchQuery: state.searchQuery,
          categoryIds: state.categoryIds,
          minAmount: state.minAmount,
          maxAmount: state.maxAmount,
          startDate: next.start,
          endDate: next.end,
        );
      }
    });

    return TransactionFilter(
      startDate: dateRange.start,
      endDate: dateRange.end,
      categoryIds: [],
    );
  }

  void clearFilters() {
    final dateRange = ref.read(selectedDateRangeProvider);
    state = TransactionFilter(
      startDate: dateRange.start,
      endDate: dateRange.end,
      categoryIds: [],
    );
  }

  void toggleCategory(String categoryId) {
    final currentIds = List<String>.from(state.categoryIds ?? []);
    if (currentIds.contains(categoryId)) {
      currentIds.remove(categoryId);
    } else {
      currentIds.add(categoryId);
    }

    _updateState(
      TransactionFilter(
        searchQuery: state.searchQuery,
        startDate: state.startDate,
        endDate: state.endDate,
        categoryIds: currentIds,
        minAmount: state.minAmount,
        maxAmount: state.maxAmount,
      ),
    );
  }

  void updateSearchQuery(String query) {
    _updateState(
      TransactionFilter(
        searchQuery: query,
        startDate: state.startDate,
        endDate: state.endDate,
        categoryIds: state.categoryIds,
        minAmount: state.minAmount,
        maxAmount: state.maxAmount,
      ),
    );
  }

  void _updateState(TransactionFilter newFilter) => state = newFilter;
}
