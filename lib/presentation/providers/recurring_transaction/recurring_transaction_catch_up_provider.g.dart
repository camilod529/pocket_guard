// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_transaction_catch_up_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Seam the tests override to simulate "the app hasn't been opened in a
/// while" without waiting on the real clock.

@ProviderFor(currentDateTime)
const currentDateTimeProvider = CurrentDateTimeProvider._();

/// Seam the tests override to simulate "the app hasn't been opened in a
/// while" without waiting on the real clock.

final class CurrentDateTimeProvider
    extends $FunctionalProvider<DateTime, DateTime, DateTime>
    with $Provider<DateTime> {
  /// Seam the tests override to simulate "the app hasn't been opened in a
  /// while" without waiting on the real clock.
  const CurrentDateTimeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentDateTimeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentDateTimeHash();

  @$internal
  @override
  $ProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DateTime create(Ref ref) {
    return currentDateTime(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$currentDateTimeHash() => r'a1f52ebad4a0bd2dac9eccd61c6b67288c2b2f09';

/// Runs once per app process (keepAlive - re-watching this from a rebuilt
/// widget is a cache hit, not a re-run) to catch up any recurring
/// transactions that are due. This is the *guaranteed* trigger; a periodic
/// background task (see lib/infrastructure/background/) is a best-effort
/// supplement for while the app is closed, not a replacement for this one.

@ProviderFor(recurringTransactionCatchUp)
const recurringTransactionCatchUpProvider =
    RecurringTransactionCatchUpProvider._();

/// Runs once per app process (keepAlive - re-watching this from a rebuilt
/// widget is a cache hit, not a re-run) to catch up any recurring
/// transactions that are due. This is the *guaranteed* trigger; a periodic
/// background task (see lib/infrastructure/background/) is a best-effort
/// supplement for while the app is closed, not a replacement for this one.

final class RecurringTransactionCatchUpProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Runs once per app process (keepAlive - re-watching this from a rebuilt
  /// widget is a cache hit, not a re-run) to catch up any recurring
  /// transactions that are due. This is the *guaranteed* trigger; a periodic
  /// background task (see lib/infrastructure/background/) is a best-effort
  /// supplement for while the app is closed, not a replacement for this one.
  const RecurringTransactionCatchUpProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringTransactionCatchUpProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringTransactionCatchUpHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return recurringTransactionCatchUp(ref);
  }
}

String _$recurringTransactionCatchUpHash() =>
    r'd962e9d4bbd464388dc0c896fb3001df342a34b9';
