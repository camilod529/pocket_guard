// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_transactions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(recurringTransactionDataSource)
const recurringTransactionDataSourceProvider =
    RecurringTransactionDataSourceProvider._();

final class RecurringTransactionDataSourceProvider
    extends
        $FunctionalProvider<
          RecurringTransactionDataSource,
          RecurringTransactionDataSource,
          RecurringTransactionDataSource
        >
    with $Provider<RecurringTransactionDataSource> {
  const RecurringTransactionDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringTransactionDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringTransactionDataSourceHash();

  @$internal
  @override
  $ProviderElement<RecurringTransactionDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecurringTransactionDataSource create(Ref ref) {
    return recurringTransactionDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecurringTransactionDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecurringTransactionDataSource>(
        value,
      ),
    );
  }
}

String _$recurringTransactionDataSourceHash() =>
    r'08f5796dc1495f4c4813749775f3525f596757b3';

@ProviderFor(recurringTransactionRepository)
const recurringTransactionRepositoryProvider =
    RecurringTransactionRepositoryProvider._();

final class RecurringTransactionRepositoryProvider
    extends
        $FunctionalProvider<
          RecurringTransactionRepository,
          RecurringTransactionRepository,
          RecurringTransactionRepository
        >
    with $Provider<RecurringTransactionRepository> {
  const RecurringTransactionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringTransactionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringTransactionRepositoryHash();

  @$internal
  @override
  $ProviderElement<RecurringTransactionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecurringTransactionRepository create(Ref ref) {
    return recurringTransactionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecurringTransactionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecurringTransactionRepository>(
        value,
      ),
    );
  }
}

String _$recurringTransactionRepositoryHash() =>
    r'bf306494a5f81eb7c23d3b0f95617f0cf57dd673';

@ProviderFor(RecurringTransactionsNotifier)
const recurringTransactionsProvider = RecurringTransactionsNotifierProvider._();

final class RecurringTransactionsNotifierProvider
    extends
        $AsyncNotifierProvider<
          RecurringTransactionsNotifier,
          List<RecurringTransactionEntity>
        > {
  const RecurringTransactionsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringTransactionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringTransactionsNotifierHash();

  @$internal
  @override
  RecurringTransactionsNotifier create() => RecurringTransactionsNotifier();
}

String _$recurringTransactionsNotifierHash() =>
    r'5b4a19cabfdc7975ef253cfc1378ca82127b80c6';

abstract class _$RecurringTransactionsNotifier
    extends $AsyncNotifier<List<RecurringTransactionEntity>> {
  FutureOr<List<RecurringTransactionEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<RecurringTransactionEntity>>,
              List<RecurringTransactionEntity>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<RecurringTransactionEntity>>,
                List<RecurringTransactionEntity>
              >,
              AsyncValue<List<RecurringTransactionEntity>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
