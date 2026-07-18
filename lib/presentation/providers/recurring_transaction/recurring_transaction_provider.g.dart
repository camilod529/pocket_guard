// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_transaction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RecurringTransactionNotifier)
const recurringTransactionProvider = RecurringTransactionNotifierFamily._();

final class RecurringTransactionNotifierProvider
    extends
        $AsyncNotifierProvider<
          RecurringTransactionNotifier,
          RecurringTransactionEntity?
        > {
  const RecurringTransactionNotifierProvider._({
    required RecurringTransactionNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'recurringTransactionProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recurringTransactionNotifierHash();

  @override
  String toString() {
    return r'recurringTransactionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RecurringTransactionNotifier create() => RecurringTransactionNotifier();

  @override
  bool operator ==(Object other) {
    return other is RecurringTransactionNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recurringTransactionNotifierHash() =>
    r'6de301a422fb9e214fe76b1a03bf0945b438f502';

final class RecurringTransactionNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          RecurringTransactionNotifier,
          AsyncValue<RecurringTransactionEntity?>,
          RecurringTransactionEntity?,
          FutureOr<RecurringTransactionEntity?>,
          String
        > {
  const RecurringTransactionNotifierFamily._()
    : super(
        retry: null,
        name: r'recurringTransactionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  RecurringTransactionNotifierProvider call(String id) =>
      RecurringTransactionNotifierProvider._(argument: id, from: this);

  @override
  String toString() => r'recurringTransactionProvider';
}

abstract class _$RecurringTransactionNotifier
    extends $AsyncNotifier<RecurringTransactionEntity?> {
  late final _$args = ref.$arg as String;
  String get id => _$args;

  FutureOr<RecurringTransactionEntity?> build(String id);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref
            as $Ref<
              AsyncValue<RecurringTransactionEntity?>,
              RecurringTransactionEntity?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<RecurringTransactionEntity?>,
                RecurringTransactionEntity?
              >,
              AsyncValue<RecurringTransactionEntity?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
