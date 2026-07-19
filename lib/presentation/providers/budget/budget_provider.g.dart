// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BudgetNotifier)
const budgetProvider = BudgetNotifierFamily._();

final class BudgetNotifierProvider
    extends $AsyncNotifierProvider<BudgetNotifier, BudgetEntity?> {
  const BudgetNotifierProvider._({
    required BudgetNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'budgetProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$budgetNotifierHash();

  @override
  String toString() {
    return r'budgetProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  BudgetNotifier create() => BudgetNotifier();

  @override
  bool operator ==(Object other) {
    return other is BudgetNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$budgetNotifierHash() => r'8ca01b3e39f5cc2abd32c79c3cf489c4fa5cc061';

final class BudgetNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          BudgetNotifier,
          AsyncValue<BudgetEntity?>,
          BudgetEntity?,
          FutureOr<BudgetEntity?>,
          String
        > {
  const BudgetNotifierFamily._()
    : super(
        retry: null,
        name: r'budgetProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  BudgetNotifierProvider call(String id) =>
      BudgetNotifierProvider._(argument: id, from: this);

  @override
  String toString() => r'budgetProvider';
}

abstract class _$BudgetNotifier extends $AsyncNotifier<BudgetEntity?> {
  late final _$args = ref.$arg as String;
  String get id => _$args;

  FutureOr<BudgetEntity?> build(String id);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<BudgetEntity?>, BudgetEntity?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<BudgetEntity?>, BudgetEntity?>,
              AsyncValue<BudgetEntity?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
