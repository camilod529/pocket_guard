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
          AsyncValue<SettingsDataSource>,
          SettingsDataSource,
          FutureOr<SettingsDataSource>
        >
    with
        $FutureModifier<SettingsDataSource>,
        $FutureProvider<SettingsDataSource> {
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
  $FutureProviderElement<SettingsDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SettingsDataSource> create(Ref ref) {
    return settingsDataSource(ref);
  }
}

String _$settingsDataSourceHash() =>
    r'9839b68a6e369f5f172346fe9c778a88a2a356a9';

@ProviderFor(settingsRepository)
const settingsRepositoryProvider = SettingsRepositoryProvider._();

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<SettingsRepository>,
          SettingsRepository,
          FutureOr<SettingsRepository>
        >
    with
        $FutureModifier<SettingsRepository>,
        $FutureProvider<SettingsRepository> {
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
  $FutureProviderElement<SettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SettingsRepository> create(Ref ref) {
    return settingsRepository(ref);
  }
}

String _$settingsRepositoryHash() =>
    r'49042bb4087468aa4dd34e1b01b768f990af1609';

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

String _$localeNotifierHash() => r'0a48323b5dbc60bdf0ba15ee292b0ff8372f4672';

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
    r'9140f37d2cb4fdad718a4cf3e189f488a41b71b3';

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
