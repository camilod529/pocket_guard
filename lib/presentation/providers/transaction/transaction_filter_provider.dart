import 'package:pocket_guard/domain/entities/transaction_filter.dart';
import 'package:pocket_guard/presentation/providers/selected_date_range_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_filter_provider.g.dart';

@riverpod
class TransactionSearchFilter extends _$TransactionSearchFilter {
  @override
  TransactionFilter build() {
    // Initial state: Use the global date range but no text search
    final dateRange = ref.watch(selectedDateRangeProvider);
    return TransactionFilter(
      startDate: dateRange.start,
      endDate: dateRange.end,
    );
  }

  void clearFilters() {
    final dateRange = ref.read(selectedDateRangeProvider);
    state = TransactionFilter(
      startDate: dateRange.start,
      endDate: dateRange.end,
    );
  }

  void updateSearchQuery(String query) {
    state = TransactionFilter(
      searchQuery: query,
      startDate: state.startDate,
      endDate: state.endDate,
      categoryIds: state.categoryIds,
    );
  }
}
