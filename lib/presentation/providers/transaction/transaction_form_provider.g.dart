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
    required (String, {DateTime? selectedDate}) super.argument,
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
        '$argument';
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

String _$transactionFormHash() => r'871c41f9a6228e12f38c60155c6d0a4884e3106f';

final class TransactionFormFamily extends $Family
    with
        $ClassFamilyOverride<
          TransactionForm,
          AsyncValue<TransactionFormState>,
          TransactionFormState,
          FutureOr<TransactionFormState>,
          (String, {DateTime? selectedDate})
        > {
  const TransactionFormFamily._()
    : super(
        retry: null,
        name: r'transactionFormProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TransactionFormProvider call(
    String transactionId, {
    DateTime? selectedDate,
  }) => TransactionFormProvider._(
    argument: (transactionId, selectedDate: selectedDate),
    from: this,
  );

  @override
  String toString() => r'transactionFormProvider';
}

abstract class _$TransactionForm extends $AsyncNotifier<TransactionFormState> {
  late final _$args = ref.$arg as (String, {DateTime? selectedDate});
  String get transactionId => _$args.$1;
  DateTime? get selectedDate => _$args.selectedDate;

  FutureOr<TransactionFormState> build(
    String transactionId, {
    DateTime? selectedDate,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args.$1, selectedDate: _$args.selectedDate);
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
