import 'package:pocket_guard/domain/data_sources/wishlist_data_source.dart';
import 'package:pocket_guard/domain/entities/wishlist_item.dart';
import 'package:pocket_guard/domain/repositories/wishlist_repository.dart';
import 'package:pocket_guard/infrastructure/data_sources/wishlist_drift_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/repositories/wishlist_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wishlist_provider.g.dart';

@Riverpod(keepAlive: true)
WishlistDataSource wishlistDataSource(Ref ref) {
  return WishlistDriftDataSourceImpl();
}

@Riverpod(keepAlive: true)
WishlistRepository wishlistRepository(Ref ref) {
  final dataSource = ref.watch(wishlistDataSourceProvider);
  return WishlistRepositoryImpl(dataSource: dataSource);
}

/// The whole wishlist. There's deliberately no per-item keepAlive cache:
/// the form looks items up in this list, so there's no second cache to
/// fall out of sync (the accountProvider/budgetProvider cache-split bug).
///
/// Same error contract as BudgetsNotifier: mutating methods revert to the
/// prior state and rethrow instead of setting `AsyncValue.error`.
@riverpod
class WishlistNotifier extends _$WishlistNotifier {
  @override
  Future<List<WishlistItemEntity>> build() async {
    final repository = ref.read(wishlistRepositoryProvider);
    return repository.getAllItems();
  }

  Future<void> createItem(WishlistItemEntity item) =>
      _mutate((repository) => repository.createItem(item));

  Future<void> deleteItem(String id) =>
      _mutate((repository) => repository.deleteItem(id));

  /// Called once the purchase transaction has been saved.
  Future<void> markPurchased(WishlistItemEntity item) => _mutate(
    (repository) => repository.updateItem(
      item.id,
      item.copyWith(purchasedAt: DateTime.now()),
    ),
  );

  Future<void> refresh() => _mutate((_) async {});

  Future<void> updateItem(String id, WishlistItemEntity item) =>
      _mutate((repository) => repository.updateItem(id, item));

  Future<void> _mutate(
    Future<void> Function(WishlistRepository repository) action,
  ) async {
    if (!ref.mounted) return;
    final previousState = state;
    state = const AsyncLoading();
    try {
      final repository = ref.read(wishlistRepositoryProvider);
      await action(repository);
      if (!ref.mounted) return;
      state = AsyncValue.data(await repository.getAllItems());
    } catch (e) {
      if (ref.mounted) state = previousState;
      rethrow;
    }
  }
}
