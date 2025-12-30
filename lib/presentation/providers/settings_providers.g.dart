// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(settingsDataSource)
const settingsDataSourceProvider = SettingsDataSourceProvider._();

final class SettingsDataSourceProvider
    extends
        $FunctionalProvider<
          SettingsDataSource,
          SettingsDataSource,
          SettingsDataSource
        >
    with $Provider<SettingsDataSource> {
  const SettingsDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsDataSourceHash();

  @$internal
  @override
  $ProviderElement<SettingsDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsDataSource create(Ref ref) {
    return settingsDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsDataSource>(value),
    );
  }
}

String _$settingsDataSourceHash() =>
    r'62e1b27ed574b30a6c6fa92474f64c6ca9d13ad2';

@ProviderFor(settingsRepository)
const settingsRepositoryProvider = SettingsRepositoryProvider._();

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          SettingsRepository,
          SettingsRepository,
          SettingsRepository
        >
    with $Provider<SettingsRepository> {
  const SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsRepository>(value),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'44ce80ceb1d82251588c2c9e249fa75bce060e53';

@ProviderFor(LocaleNotifier)
const localeProvider = LocaleNotifierProvider._();

final class LocaleNotifierProvider
    extends $AsyncNotifierProvider<LocaleNotifier, String> {
  const LocaleNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeNotifierHash();

  @$internal
  @override
  LocaleNotifier create() => LocaleNotifier();
}

String _$localeNotifierHash() => r'e6c4a66edcc87437387dcafe98beaf95fa370fba';

abstract class _$LocaleNotifier extends $AsyncNotifier<String> {
  FutureOr<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<String>, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String>, String>,
              AsyncValue<String>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ThemeIndexNotifier)
const themeIndexProvider = ThemeIndexNotifierProvider._();

final class ThemeIndexNotifierProvider
    extends $AsyncNotifierProvider<ThemeIndexNotifier, int> {
  const ThemeIndexNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeIndexProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeIndexNotifierHash();

  @$internal
  @override
  ThemeIndexNotifier create() => ThemeIndexNotifier();
}

String _$themeIndexNotifierHash() =>
    r'd6d0415304d876c609aa89b74f8d160f95f2f37f';

abstract class _$ThemeIndexNotifier extends $AsyncNotifier<int> {
  FutureOr<int> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<int>, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int>, int>,
              AsyncValue<int>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
