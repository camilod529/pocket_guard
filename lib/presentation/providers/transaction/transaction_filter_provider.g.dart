// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TransactionSearchFilter)
const transactionSearchFilterProvider = TransactionSearchFilterProvider._();

final class TransactionSearchFilterProvider
    extends $NotifierProvider<TransactionSearchFilter, TransactionFilter> {
  const TransactionSearchFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionSearchFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionSearchFilterHash();

  @$internal
  @override
  TransactionSearchFilter create() => TransactionSearchFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionFilter>(value),
    );
  }
}

String _$transactionSearchFilterHash() =>
    r'8b84ceee5afc8d40b166f1a88aa1f7ca92539fbc';

abstract class _$TransactionSearchFilter extends $Notifier<TransactionFilter> {
  TransactionFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<TransactionFilter, TransactionFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TransactionFilter, TransactionFilter>,
              TransactionFilter,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
