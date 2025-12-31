// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ui_visibility_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FilterSheetVisibility)
const filterSheetVisibilityProvider = FilterSheetVisibilityProvider._();

final class FilterSheetVisibilityProvider
    extends $NotifierProvider<FilterSheetVisibility, bool> {
  const FilterSheetVisibilityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filterSheetVisibilityProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filterSheetVisibilityHash();

  @$internal
  @override
  FilterSheetVisibility create() => FilterSheetVisibility();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$filterSheetVisibilityHash() =>
    r'8f92b13761295578c187190fc45c03d75ffd0ac4';

abstract class _$FilterSheetVisibility extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
