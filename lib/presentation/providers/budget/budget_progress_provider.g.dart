// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_progress_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Combines the active budgets with this month's actual spending per
/// category. Deliberately queries the repository directly (not through
/// transactionsProvider's cached list) so the date-range filter happens at
/// the query layer, matching how the rest of the app filters transactions
/// (see TransactionFilter) - but still watches transactionsProvider (result
/// discarded) purely to pick up a dependency, so this recomputes whenever
/// any transaction is created/updated/deleted anywhere in the app.

@ProviderFor(budgetProgress)
const budgetProgressProvider = BudgetProgressProvider._();

/// Combines the active budgets with this month's actual spending per
/// category. Deliberately queries the repository directly (not through
/// transactionsProvider's cached list) so the date-range filter happens at
/// the query layer, matching how the rest of the app filters transactions
/// (see TransactionFilter) - but still watches transactionsProvider (result
/// discarded) purely to pick up a dependency, so this recomputes whenever
/// any transaction is created/updated/deleted anywhere in the app.

final class BudgetProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BudgetProgress>>,
          List<BudgetProgress>,
          FutureOr<List<BudgetProgress>>
        >
    with
        $FutureModifier<List<BudgetProgress>>,
        $FutureProvider<List<BudgetProgress>> {
  /// Combines the active budgets with this month's actual spending per
  /// category. Deliberately queries the repository directly (not through
  /// transactionsProvider's cached list) so the date-range filter happens at
  /// the query layer, matching how the rest of the app filters transactions
  /// (see TransactionFilter) - but still watches transactionsProvider (result
  /// discarded) purely to pick up a dependency, so this recomputes whenever
  /// any transaction is created/updated/deleted anywhere in the app.
  const BudgetProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetProgressHash();

  @$internal
  @override
  $FutureProviderElement<List<BudgetProgress>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BudgetProgress>> create(Ref ref) {
    return budgetProgress(ref);
  }
}

String _$budgetProgressHash() => r'4c09938ced583309fb1374561c029573d175a3c9';
