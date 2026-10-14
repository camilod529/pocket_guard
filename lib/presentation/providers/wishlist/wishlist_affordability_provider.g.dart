// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_affordability_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every wishlist item with a can-I-buy-it verdict. Recomputes whenever
/// the wishlist, account balances, this month's budgets or savings jars
/// change - all four are watched.

@ProviderFor(wishlistAffordability)
const wishlistAffordabilityProvider = WishlistAffordabilityProvider._();

/// Every wishlist item with a can-I-buy-it verdict. Recomputes whenever
/// the wishlist, account balances, this month's budgets or savings jars
/// change - all four are watched.

final class WishlistAffordabilityProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Affordability>>,
          List<Affordability>,
          FutureOr<List<Affordability>>
        >
    with
        $FutureModifier<List<Affordability>>,
        $FutureProvider<List<Affordability>> {
  /// Every wishlist item with a can-I-buy-it verdict. Recomputes whenever
  /// the wishlist, account balances, this month's budgets or savings jars
  /// change - all four are watched.
  const WishlistAffordabilityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wishlistAffordabilityProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wishlistAffordabilityHash();

  @$internal
  @override
  $FutureProviderElement<List<Affordability>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Affordability>> create(Ref ref) {
    return wishlistAffordability(ref);
  }
}

String _$wishlistAffordabilityHash() =>
    r'86ad47911c4fba19a43d94764c0b73c8b72c528d';
