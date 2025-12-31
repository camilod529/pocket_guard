// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transactions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(transactionDataSource)
const transactionDataSourceProvider = TransactionDataSourceProvider._();

final class TransactionDataSourceProvider
    extends
        $FunctionalProvider<
          TransactionDataSource,
          TransactionDataSource,
          TransactionDataSource
        >
    with $Provider<TransactionDataSource> {
  const TransactionDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionDataSourceHash();

  @$internal
  @override
  $ProviderElement<TransactionDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TransactionDataSource create(Ref ref) {
    return transactionDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionDataSource>(value),
    );
  }
}

String _$transactionDataSourceHash() =>
    r'f6fec728165fbf904086f101ca7b1563a7c5182f';

@ProviderFor(transactionRepository)
const transactionRepositoryProvider = TransactionRepositoryProvider._();

final class TransactionRepositoryProvider
    extends
        $FunctionalProvider<
          TransactionRepository,
          TransactionRepository,
          TransactionRepository
        >
    with $Provider<TransactionRepository> {
  const TransactionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionRepositoryHash();

  @$internal
  @override
  $ProviderElement<TransactionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TransactionRepository create(Ref ref) {
    return transactionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionRepository>(value),
    );
  }
}

String _$transactionRepositoryHash() =>
    r'24b9b23b44ec713050fcb60beb494fdb4375652a';

@ProviderFor(TransactionsNotifier)
const transactionsProvider = TransactionsNotifierProvider._();

final class TransactionsNotifierProvider
    extends
        $AsyncNotifierProvider<TransactionsNotifier, List<TransactionEntity>> {
  const TransactionsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionsNotifierHash();

  @$internal
  @override
  TransactionsNotifier create() => TransactionsNotifier();
}

String _$transactionsNotifierHash() =>
    r'0c1a7af5bf1caa780ecc27c1466781ea597b9627';

abstract class _$TransactionsNotifier
    extends $AsyncNotifier<List<TransactionEntity>> {
  FutureOr<List<TransactionEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<TransactionEntity>>,
              List<TransactionEntity>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<TransactionEntity>>,
                List<TransactionEntity>
              >,
              AsyncValue<List<TransactionEntity>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
