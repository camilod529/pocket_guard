// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_progress_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every goal paired with its saved amount (SUM of its contributions,
/// computed at read time - never stored). Recomputes whenever
/// savingsGoalsProvider re-emits, which every goal or contribution write
/// does.

@ProviderFor(goalProgress)
const goalProgressProvider = GoalProgressProvider._();

/// Every goal paired with its saved amount (SUM of its contributions,
/// computed at read time - never stored). Recomputes whenever
/// savingsGoalsProvider re-emits, which every goal or contribution write
/// does.

final class GoalProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GoalProgress>>,
          List<GoalProgress>,
          FutureOr<List<GoalProgress>>
        >
    with
        $FutureModifier<List<GoalProgress>>,
        $FutureProvider<List<GoalProgress>> {
  /// Every goal paired with its saved amount (SUM of its contributions,
  /// computed at read time - never stored). Recomputes whenever
  /// savingsGoalsProvider re-emits, which every goal or contribution write
  /// does.
  const GoalProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalProgressHash();

  @$internal
  @override
  $FutureProviderElement<List<GoalProgress>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<GoalProgress>> create(Ref ref) {
    return goalProgress(ref);
  }
}

String _$goalProgressHash() => r'86b9f3120f5aaf3a99ce6e680d1856cf6aa3d18e';

/// Newest first.

@ProviderFor(goalContributions)
const goalContributionsProvider = GoalContributionsFamily._();

/// Newest first.

final class GoalContributionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GoalContributionEntity>>,
          List<GoalContributionEntity>,
          FutureOr<List<GoalContributionEntity>>
        >
    with
        $FutureModifier<List<GoalContributionEntity>>,
        $FutureProvider<List<GoalContributionEntity>> {
  /// Newest first.
  const GoalContributionsProvider._({
    required GoalContributionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'goalContributionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$goalContributionsHash();

  @override
  String toString() {
    return r'goalContributionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<GoalContributionEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<GoalContributionEntity>> create(Ref ref) {
    final argument = this.argument as String;
    return goalContributions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GoalContributionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$goalContributionsHash() => r'0314c9dc9a8877a4f55f1eab93b80cf2f032dd3b';

/// Newest first.

final class GoalContributionsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<GoalContributionEntity>>,
          String
        > {
  const GoalContributionsFamily._()
    : super(
        retry: null,
        name: r'goalContributionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Newest first.

  GoalContributionsProvider call(String goalId) =>
      GoalContributionsProvider._(argument: goalId, from: this);

  @override
  String toString() => r'goalContributionsProvider';
}
