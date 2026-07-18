// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_transaction_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RecurringTransactionForm)
const recurringTransactionFormProvider = RecurringTransactionFormFamily._();

final class RecurringTransactionFormProvider
    extends
        $AsyncNotifierProvider<
          RecurringTransactionForm,
          RecurringTransactionFormState
        > {
  const RecurringTransactionFormProvider._({
    required RecurringTransactionFormFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'recurringTransactionFormProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recurringTransactionFormHash();

  @override
  String toString() {
    return r'recurringTransactionFormProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RecurringTransactionForm create() => RecurringTransactionForm();

  @override
  bool operator ==(Object other) {
    return other is RecurringTransactionFormProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recurringTransactionFormHash() =>
    r'1201de0e77418866d7d99d0eb64a8b3f6526356d';

final class RecurringTransactionFormFamily extends $Family
    with
        $ClassFamilyOverride<
          RecurringTransactionForm,
          AsyncValue<RecurringTransactionFormState>,
          RecurringTransactionFormState,
          FutureOr<RecurringTransactionFormState>,
          String
        > {
  const RecurringTransactionFormFamily._()
    : super(
        retry: null,
        name: r'recurringTransactionFormProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RecurringTransactionFormProvider call(String id) =>
      RecurringTransactionFormProvider._(argument: id, from: this);

  @override
  String toString() => r'recurringTransactionFormProvider';
}

abstract class _$RecurringTransactionForm
    extends $AsyncNotifier<RecurringTransactionFormState> {
  late final _$args = ref.$arg as String;
  String get id => _$args;

  FutureOr<RecurringTransactionFormState> build(String id);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref
            as $Ref<
              AsyncValue<RecurringTransactionFormState>,
              RecurringTransactionFormState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<RecurringTransactionFormState>,
                RecurringTransactionFormState
              >,
              AsyncValue<RecurringTransactionFormState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
