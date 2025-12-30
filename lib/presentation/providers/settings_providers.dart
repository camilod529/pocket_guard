import 'package:pocket_guard/domain/data_sources/settings_data_source.dart';
import 'package:pocket_guard/domain/repositories/settings_repository.dart';
import 'package:pocket_guard/infrastructure/data_sources/settings_shared_preference_data_source_impl.dart';
import 'package:pocket_guard/infrastructure/repositories/settings_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_providers.g.dart';

@Riverpod(keepAlive: true)
SettingsDataSource settingsDataSource(Ref ref) {
  return SettingsSharedPreferenceDataSourceImpl();
}

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) {
  final dataSource = ref.watch(settingsDataSourceProvider);
  return SettingsRepositoryImpl(dataSource: dataSource);
}

@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  SettingsRepository? _repository;

  @override
  Future<String> build() async {
    final repository = ref.watch(settingsRepositoryProvider);
    _repository = repository;

    final savedLocale = await _repository!.getLocale();
    return savedLocale ?? 'en';
  }

  Future<void> setLocale(String locale) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository!.saveLocale(locale);
      return locale;
    });
  }
}

@riverpod
class ThemeIndexNotifier extends _$ThemeIndexNotifier {
  SettingsRepository? _repository;

  @override
  Future<int> build() async {
    final repository = ref.watch(settingsRepositoryProvider);
    _repository = repository;

    final savedIndex = await _repository!.getThemeIndex();
    return savedIndex ?? 0;
  }

  Future<void> setThemeIndex(int index) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository!.saveThemeIndex(index);
      return index;
    });
  }
}
