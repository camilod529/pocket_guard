// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_goals_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(savingsGoalDataSource)
const savingsGoalDataSourceProvider = SavingsGoalDataSourceProvider._();

final class SavingsGoalDataSourceProvider
    extends
        $FunctionalProvider<
          SavingsGoalDataSource,
          SavingsGoalDataSource,
          SavingsGoalDataSource
        >
    with $Provider<SavingsGoalDataSource> {
  const SavingsGoalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savingsGoalDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savingsGoalDataSourceHash();

  @$internal
  @override
  $ProviderElement<SavingsGoalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SavingsGoalDataSource create(Ref ref) {
    return savingsGoalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavingsGoalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavingsGoalDataSource>(value),
    );
  }
}

String _$savingsGoalDataSourceHash() =>
    r'1162949f6715f87a7f31a449b85e872fb446e4c8';

@ProviderFor(savingsGoalRepository)
const savingsGoalRepositoryProvider = SavingsGoalRepositoryProvider._();

final class SavingsGoalRepositoryProvider
    extends
        $FunctionalProvider<
          SavingsGoalRepository,
          SavingsGoalRepository,
          SavingsGoalRepository
        >
    with $Provider<SavingsGoalRepository> {
  const SavingsGoalRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savingsGoalRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savingsGoalRepositoryHash();

  @$internal
  @override
  $ProviderElement<SavingsGoalRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SavingsGoalRepository create(Ref ref) {
    return savingsGoalRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavingsGoalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavingsGoalRepository>(value),
    );
  }
}

String _$savingsGoalRepositoryHash() =>
    r'b3a43f3c3f24ccfd205fa2cbc1ca798bf47a3ad3';

/// The goal list. Contribution writes go through here too (not a separate
/// notifier) so every money movement re-emits this list - that's what
/// goalProgressProvider and goalContributionsProvider watch to recompute.
///
/// Same error contract as BudgetsNotifier: mutating methods revert to the
/// prior state and rethrow instead of setting `AsyncValue.error`, so callers
/// can catch [SavingsGoalValidationException] and show its reason.

@ProviderFor(SavingsGoalsNotifier)
const savingsGoalsProvider = SavingsGoalsNotifierProvider._();

/// The goal list. Contribution writes go through here too (not a separate
/// notifier) so every money movement re-emits this list - that's what
/// goalProgressProvider and goalContributionsProvider watch to recompute.
///
/// Same error contract as BudgetsNotifier: mutating methods revert to the
/// prior state and rethrow instead of setting `AsyncValue.error`, so callers
/// can catch [SavingsGoalValidationException] and show its reason.
final class SavingsGoalsNotifierProvider
    extends
        $AsyncNotifierProvider<SavingsGoalsNotifier, List<SavingsGoalEntity>> {
  /// The goal list. Contribution writes go through here too (not a separate
  /// notifier) so every money movement re-emits this list - that's what
  /// goalProgressProvider and goalContributionsProvider watch to recompute.
  ///
  /// Same error contract as BudgetsNotifier: mutating methods revert to the
  /// prior state and rethrow instead of setting `AsyncValue.error`, so callers
  /// can catch [SavingsGoalValidationException] and show its reason.
  const SavingsGoalsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savingsGoalsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savingsGoalsNotifierHash();

  @$internal
  @override
  SavingsGoalsNotifier create() => SavingsGoalsNotifier();
}

String _$savingsGoalsNotifierHash() =>
    r'f1ec852b9a86502b20afe81c2a4dd486c8857699';

/// The goal list. Contribution writes go through here too (not a separate
/// notifier) so every money movement re-emits this list - that's what
/// goalProgressProvider and goalContributionsProvider watch to recompute.
///
/// Same error contract as BudgetsNotifier: mutating methods revert to the
/// prior state and rethrow instead of setting `AsyncValue.error`, so callers
/// can catch [SavingsGoalValidationException] and show its reason.

abstract class _$SavingsGoalsNotifier
    extends $AsyncNotifier<List<SavingsGoalEntity>> {
  FutureOr<List<SavingsGoalEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<SavingsGoalEntity>>,
              List<SavingsGoalEntity>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<SavingsGoalEntity>>,
                List<SavingsGoalEntity>
              >,
              AsyncValue<List<SavingsGoalEntity>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
