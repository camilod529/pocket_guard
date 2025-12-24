// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TransactionNotifier)
const transactionProvider = TransactionNotifierFamily._();

final class TransactionNotifierProvider
    extends $AsyncNotifierProvider<TransactionNotifier, TransactionEntity?> {
  const TransactionNotifierProvider._({
    required TransactionNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'transactionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transactionNotifierHash();

  @override
  String toString() {
    return r'transactionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TransactionNotifier create() => TransactionNotifier();

  @override
  bool operator ==(Object other) {
    return other is TransactionNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transactionNotifierHash() =>
    r'c2cf42ff245a9d295b7614b7aa1b2e13e4d73c04';

final class TransactionNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          TransactionNotifier,
          AsyncValue<TransactionEntity?>,
          TransactionEntity?,
          FutureOr<TransactionEntity?>,
          String
        > {
  const TransactionNotifierFamily._()
    : super(
        retry: null,
        name: r'transactionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TransactionNotifierProvider call(String transactionId) =>
      TransactionNotifierProvider._(argument: transactionId, from: this);

  @override
  String toString() => r'transactionProvider';
}

abstract class _$TransactionNotifier
    extends $AsyncNotifier<TransactionEntity?> {
  late final _$args = ref.$arg as String;
  String get transactionId => _$args;

  FutureOr<TransactionEntity?> build(String transactionId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref as $Ref<AsyncValue<TransactionEntity?>, TransactionEntity?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TransactionEntity?>, TransactionEntity?>,
              AsyncValue<TransactionEntity?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
