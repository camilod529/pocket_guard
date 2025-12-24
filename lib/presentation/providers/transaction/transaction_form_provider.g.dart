// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TransactionForm)
const transactionFormProvider = TransactionFormFamily._();

final class TransactionFormProvider
    extends $AsyncNotifierProvider<TransactionForm, TransactionFormState> {
  const TransactionFormProvider._({
    required TransactionFormFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'transactionFormProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transactionFormHash();

  @override
  String toString() {
    return r'transactionFormProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TransactionForm create() => TransactionForm();

  @override
  bool operator ==(Object other) {
    return other is TransactionFormProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transactionFormHash() => r'636df368153ab6b077c675bf02861dea3c0525be';

final class TransactionFormFamily extends $Family
    with
        $ClassFamilyOverride<
          TransactionForm,
          AsyncValue<TransactionFormState>,
          TransactionFormState,
          FutureOr<TransactionFormState>,
          String
        > {
  const TransactionFormFamily._()
    : super(
        retry: null,
        name: r'transactionFormProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TransactionFormProvider call(String transactionId) =>
      TransactionFormProvider._(argument: transactionId, from: this);

  @override
  String toString() => r'transactionFormProvider';
}

abstract class _$TransactionForm extends $AsyncNotifier<TransactionFormState> {
  late final _$args = ref.$arg as String;
  String get transactionId => _$args;

  FutureOr<TransactionFormState> build(String transactionId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref
            as $Ref<AsyncValue<TransactionFormState>, TransactionFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<TransactionFormState>,
                TransactionFormState
              >,
              AsyncValue<TransactionFormState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
