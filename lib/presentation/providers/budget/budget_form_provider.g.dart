// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BudgetForm)
const budgetFormProvider = BudgetFormFamily._();

final class BudgetFormProvider
    extends $AsyncNotifierProvider<BudgetForm, BudgetFormState> {
  const BudgetFormProvider._({
    required BudgetFormFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'budgetFormProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$budgetFormHash();

  @override
  String toString() {
    return r'budgetFormProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  BudgetForm create() => BudgetForm();

  @override
  bool operator ==(Object other) {
    return other is BudgetFormProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$budgetFormHash() => r'dca377c285a605069c3fdfd9767b6584e0cc709b';

final class BudgetFormFamily extends $Family
    with
        $ClassFamilyOverride<
          BudgetForm,
          AsyncValue<BudgetFormState>,
          BudgetFormState,
          FutureOr<BudgetFormState>,
          String
        > {
  const BudgetFormFamily._()
    : super(
        retry: null,
        name: r'budgetFormProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BudgetFormProvider call(String id) =>
      BudgetFormProvider._(argument: id, from: this);

  @override
  String toString() => r'budgetFormProvider';
}

abstract class _$BudgetForm extends $AsyncNotifier<BudgetFormState> {
  late final _$args = ref.$arg as String;
  String get id => _$args;

  FutureOr<BudgetFormState> build(String id);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<BudgetFormState>, BudgetFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<BudgetFormState>, BudgetFormState>,
              AsyncValue<BudgetFormState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
