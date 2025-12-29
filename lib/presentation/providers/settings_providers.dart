// providers/settings_providers.dart
import 'package:money_manager_flutter/domain/data_sources/settings_data_source.dart';
import 'package:money_manager_flutter/domain/repositories/settings_repository.dart';
import 'package:money_manager_flutter/infrastructure/data_sources/settings_shared_preference_data_source_impl.dart';
import 'package:money_manager_flutter/infrastructure/repositories/settings_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_providers.g.dart';

@Riverpod(keepAlive: true)
Future<SettingsDataSource> settingsDataSource(Ref ref) async {
  final prefs = await SharedPreferences.getInstance();
  return SettingsSharedPreferenceDataSourceImpl(prefs);
}

@Riverpod(keepAlive: true)
Future<SettingsRepository> settingsRepository(Ref ref) async {
  final dataSource = await ref.watch(settingsDataSourceProvider.future);
  return SettingsRepositoryImpl(dataSource: dataSource);
}

@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  SettingsRepository? _repository;

  @override
  Future<String> build() async {
    final repository = await ref.watch(settingsRepositoryProvider.future);
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
    final repository = await ref.watch(settingsRepositoryProvider.future);
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
