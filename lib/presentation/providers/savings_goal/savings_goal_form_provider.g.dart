// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_goal_form_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SavingsGoalForm)
const savingsGoalFormProvider = SavingsGoalFormFamily._();

final class SavingsGoalFormProvider
    extends $AsyncNotifierProvider<SavingsGoalForm, SavingsGoalFormState> {
  const SavingsGoalFormProvider._({
    required SavingsGoalFormFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'savingsGoalFormProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$savingsGoalFormHash();

  @override
  String toString() {
    return r'savingsGoalFormProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SavingsGoalForm create() => SavingsGoalForm();

  @override
  bool operator ==(Object other) {
    return other is SavingsGoalFormProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$savingsGoalFormHash() => r'91d0066af314b35a7ffd0bf25a218c3209cc569b';

final class SavingsGoalFormFamily extends $Family
    with
        $ClassFamilyOverride<
          SavingsGoalForm,
          AsyncValue<SavingsGoalFormState>,
          SavingsGoalFormState,
          FutureOr<SavingsGoalFormState>,
          String
        > {
  const SavingsGoalFormFamily._()
    : super(
        retry: null,
        name: r'savingsGoalFormProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SavingsGoalFormProvider call(String id) =>
      SavingsGoalFormProvider._(argument: id, from: this);

  @override
  String toString() => r'savingsGoalFormProvider';
}

abstract class _$SavingsGoalForm extends $AsyncNotifier<SavingsGoalFormState> {
  late final _$args = ref.$arg as String;
  String get id => _$args;

  FutureOr<SavingsGoalFormState> build(String id);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref
            as $Ref<AsyncValue<SavingsGoalFormState>, SavingsGoalFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<SavingsGoalFormState>,
                SavingsGoalFormState
              >,
              AsyncValue<SavingsGoalFormState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
