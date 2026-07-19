// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budgets_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(budgetDataSource)
const budgetDataSourceProvider = BudgetDataSourceProvider._();

final class BudgetDataSourceProvider
    extends
        $FunctionalProvider<
          BudgetDataSource,
          BudgetDataSource,
          BudgetDataSource
        >
    with $Provider<BudgetDataSource> {
  const BudgetDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetDataSourceHash();

  @$internal
  @override
  $ProviderElement<BudgetDataSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BudgetDataSource create(Ref ref) {
    return budgetDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BudgetDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BudgetDataSource>(value),
    );
  }
}

String _$budgetDataSourceHash() => r'a9a9325b9875a09832517b65dc41661706eb88a8';

@ProviderFor(budgetRepository)
const budgetRepositoryProvider = BudgetRepositoryProvider._();

final class BudgetRepositoryProvider
    extends
        $FunctionalProvider<
          BudgetRepository,
          BudgetRepository,
          BudgetRepository
        >
    with $Provider<BudgetRepository> {
  const BudgetRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetRepositoryHash();

  @$internal
  @override
  $ProviderElement<BudgetRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BudgetRepository create(Ref ref) {
    return budgetRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BudgetRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BudgetRepository>(value),
    );
  }
}

String _$budgetRepositoryHash() => r'b47357bb650e15b66040048694487292fa0d9004';

@ProviderFor(BudgetsNotifier)
const budgetsProvider = BudgetsNotifierProvider._();

final class BudgetsNotifierProvider
    extends $AsyncNotifierProvider<BudgetsNotifier, List<BudgetEntity>> {
  const BudgetsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetsNotifierHash();

  @$internal
  @override
  BudgetsNotifier create() => BudgetsNotifier();
}

String _$budgetsNotifierHash() => r'4d46a33200a5045dd998b0c819e040fb15d931e8';

abstract class _$BudgetsNotifier extends $AsyncNotifier<List<BudgetEntity>> {
  FutureOr<List<BudgetEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<BudgetEntity>>, List<BudgetEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<BudgetEntity>>, List<BudgetEntity>>,
              AsyncValue<List<BudgetEntity>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
