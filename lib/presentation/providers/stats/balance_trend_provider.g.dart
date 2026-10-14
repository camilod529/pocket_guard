// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balance_trend_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// End-of-day balances (index 0 = day 1) for the calendar's selected month,
/// combining every account in [currency] - or just [accountId] when given.
///
/// Queries the repositories directly instead of reusing transactionsProvider:
/// that list is narrowed to the selected month *and* the user's search and
/// category filters, while working back from today's balance needs every
/// change since the month began, unfiltered (see BalanceTrendCalculator).

@ProviderFor(balanceTrend)
const balanceTrendProvider = BalanceTrendFamily._();

/// End-of-day balances (index 0 = day 1) for the calendar's selected month,
/// combining every account in [currency] - or just [accountId] when given.
///
/// Queries the repositories directly instead of reusing transactionsProvider:
/// that list is narrowed to the selected month *and* the user's search and
/// category filters, while working back from today's balance needs every
/// change since the month began, unfiltered (see BalanceTrendCalculator).

final class BalanceTrendProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<double>>,
          List<double>,
          FutureOr<List<double>>
        >
    with $FutureModifier<List<double>>, $FutureProvider<List<double>> {
  /// End-of-day balances (index 0 = day 1) for the calendar's selected month,
  /// combining every account in [currency] - or just [accountId] when given.
  ///
  /// Queries the repositories directly instead of reusing transactionsProvider:
  /// that list is narrowed to the selected month *and* the user's search and
  /// category filters, while working back from today's balance needs every
  /// change since the month began, unfiltered (see BalanceTrendCalculator).
  const BalanceTrendProvider._({
    required BalanceTrendFamily super.from,
    required (String, String?) super.argument,
  }) : super(
         retry: null,
         name: r'balanceTrendProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$balanceTrendHash();

  @override
  String toString() {
    return r'balanceTrendProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<double>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<double>> create(Ref ref) {
    final argument = this.argument as (String, String?);
    return balanceTrend(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is BalanceTrendProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$balanceTrendHash() => r'6947a4c48faac1e784cb621db04a0525be85326b';

/// End-of-day balances (index 0 = day 1) for the calendar's selected month,
/// combining every account in [currency] - or just [accountId] when given.
///
/// Queries the repositories directly instead of reusing transactionsProvider:
/// that list is narrowed to the selected month *and* the user's search and
/// category filters, while working back from today's balance needs every
/// change since the month began, unfiltered (see BalanceTrendCalculator).

final class BalanceTrendFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<double>>, (String, String?)> {
  const BalanceTrendFamily._()
    : super(
        retry: null,
        name: r'balanceTrendProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// End-of-day balances (index 0 = day 1) for the calendar's selected month,
  /// combining every account in [currency] - or just [accountId] when given.
  ///
  /// Queries the repositories directly instead of reusing transactionsProvider:
  /// that list is narrowed to the selected month *and* the user's search and
  /// category filters, while working back from today's balance needs every
  /// change since the month began, unfiltered (see BalanceTrendCalculator).

  BalanceTrendProvider call(String currency, String? accountId) =>
      BalanceTrendProvider._(argument: (currency, accountId), from: this);

  @override
  String toString() => r'balanceTrendProvider';
}
