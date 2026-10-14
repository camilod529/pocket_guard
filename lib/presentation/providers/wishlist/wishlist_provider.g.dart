// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(wishlistDataSource)
const wishlistDataSourceProvider = WishlistDataSourceProvider._();

final class WishlistDataSourceProvider
    extends
        $FunctionalProvider<
          WishlistDataSource,
          WishlistDataSource,
          WishlistDataSource
        >
    with $Provider<WishlistDataSource> {
  const WishlistDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wishlistDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wishlistDataSourceHash();

  @$internal
  @override
  $ProviderElement<WishlistDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WishlistDataSource create(Ref ref) {
    return wishlistDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WishlistDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WishlistDataSource>(value),
    );
  }
}

String _$wishlistDataSourceHash() =>
    r'2b0e27f812356629b8d984107f2f370f2e386b1a';

@ProviderFor(wishlistRepository)
const wishlistRepositoryProvider = WishlistRepositoryProvider._();

final class WishlistRepositoryProvider
    extends
        $FunctionalProvider<
          WishlistRepository,
          WishlistRepository,
          WishlistRepository
        >
    with $Provider<WishlistRepository> {
  const WishlistRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wishlistRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wishlistRepositoryHash();

  @$internal
  @override
  $ProviderElement<WishlistRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WishlistRepository create(Ref ref) {
    return wishlistRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WishlistRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WishlistRepository>(value),
    );
  }
}

String _$wishlistRepositoryHash() =>
    r'2b47eaf1ddddc8459d32159447e7d13a51b17537';

/// The whole wishlist. There's deliberately no per-item keepAlive cache:
/// the form looks items up in this list, so there's no second cache to
/// fall out of sync (the accountProvider/budgetProvider cache-split bug).
///
/// Same error contract as BudgetsNotifier: mutating methods revert to the
/// prior state and rethrow instead of setting `AsyncValue.error`.

@ProviderFor(WishlistNotifier)
const wishlistProvider = WishlistNotifierProvider._();

/// The whole wishlist. There's deliberately no per-item keepAlive cache:
/// the form looks items up in this list, so there's no second cache to
/// fall out of sync (the accountProvider/budgetProvider cache-split bug).
///
/// Same error contract as BudgetsNotifier: mutating methods revert to the
/// prior state and rethrow instead of setting `AsyncValue.error`.
final class WishlistNotifierProvider
    extends $AsyncNotifierProvider<WishlistNotifier, List<WishlistItemEntity>> {
  /// The whole wishlist. There's deliberately no per-item keepAlive cache:
  /// the form looks items up in this list, so there's no second cache to
  /// fall out of sync (the accountProvider/budgetProvider cache-split bug).
  ///
  /// Same error contract as BudgetsNotifier: mutating methods revert to the
  /// prior state and rethrow instead of setting `AsyncValue.error`.
  const WishlistNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wishlistProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wishlistNotifierHash();

  @$internal
  @override
  WishlistNotifier create() => WishlistNotifier();
}

String _$wishlistNotifierHash() => r'586b22fe607bd7a73fe88ba5fc82539a45bf6f9f';

/// The whole wishlist. There's deliberately no per-item keepAlive cache:
/// the form looks items up in this list, so there's no second cache to
/// fall out of sync (the accountProvider/budgetProvider cache-split bug).
///
/// Same error contract as BudgetsNotifier: mutating methods revert to the
/// prior state and rethrow instead of setting `AsyncValue.error`.

abstract class _$WishlistNotifier
    extends $AsyncNotifier<List<WishlistItemEntity>> {
  FutureOr<List<WishlistItemEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<WishlistItemEntity>>,
              List<WishlistItemEntity>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<WishlistItemEntity>>,
                List<WishlistItemEntity>
              >,
              AsyncValue<List<WishlistItemEntity>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
