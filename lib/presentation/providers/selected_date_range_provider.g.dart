// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_date_range_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedDateRange)
const selectedDateRangeProvider = SelectedDateRangeProvider._();

final class SelectedDateRangeProvider
    extends $NotifierProvider<SelectedDateRange, DateRangeSelection> {
  const SelectedDateRangeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedDateRangeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedDateRangeHash();

  @$internal
  @override
  SelectedDateRange create() => SelectedDateRange();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateRangeSelection value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateRangeSelection>(value),
    );
  }
}

String _$selectedDateRangeHash() => r'f749437b7da82b44dcded1002e25b365031b4f92';

abstract class _$SelectedDateRange extends $Notifier<DateRangeSelection> {
  DateRangeSelection build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<DateRangeSelection, DateRangeSelection>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateRangeSelection, DateRangeSelection>,
              DateRangeSelection,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
