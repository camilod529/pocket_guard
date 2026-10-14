// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_goal_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SavingsGoalNotifier)
const savingsGoalProvider = SavingsGoalNotifierFamily._();

final class SavingsGoalNotifierProvider
    extends $AsyncNotifierProvider<SavingsGoalNotifier, SavingsGoalEntity?> {
  const SavingsGoalNotifierProvider._({
    required SavingsGoalNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'savingsGoalProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$savingsGoalNotifierHash();

  @override
  String toString() {
    return r'savingsGoalProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SavingsGoalNotifier create() => SavingsGoalNotifier();

  @override
  bool operator ==(Object other) {
    return other is SavingsGoalNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$savingsGoalNotifierHash() =>
    r'94e818e7af08a44f156d75d4dbe56a50e0f56f45';

final class SavingsGoalNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          SavingsGoalNotifier,
          AsyncValue<SavingsGoalEntity?>,
          SavingsGoalEntity?,
          FutureOr<SavingsGoalEntity?>,
          String
        > {
  const SavingsGoalNotifierFamily._()
    : super(
        retry: null,
        name: r'savingsGoalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  SavingsGoalNotifierProvider call(String id) =>
      SavingsGoalNotifierProvider._(argument: id, from: this);

  @override
  String toString() => r'savingsGoalProvider';
}

abstract class _$SavingsGoalNotifier
    extends $AsyncNotifier<SavingsGoalEntity?> {
  late final _$args = ref.$arg as String;
  String get id => _$args;

  FutureOr<SavingsGoalEntity?> build(String id);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref as $Ref<AsyncValue<SavingsGoalEntity?>, SavingsGoalEntity?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SavingsGoalEntity?>, SavingsGoalEntity?>,
              AsyncValue<SavingsGoalEntity?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
