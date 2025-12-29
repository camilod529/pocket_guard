import 'package:money_manager_flutter/domain/data_sources/settings_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsSharedPreferenceDataSourceImpl implements SettingsDataSource {
  static const String _themeIndexKey = 'theme_index';
  static const String _localeKey = 'locale';

  final SharedPreferences _prefs;

  SettingsSharedPreferenceDataSourceImpl(this._prefs);

  @override
  Future<String?> getLocale() async {
    return _prefs.getString(_localeKey);
  }

  @override
  Future<int?> getThemeIndex() async {
    return _prefs.getInt(_themeIndexKey);
  }

  @override
  Future<void> saveLocale(String locale) async {
    await _prefs.setString(_localeKey, locale);
  }

  @override
  Future<void> saveThemeIndex(int index) async {
    await _prefs.setInt(_themeIndexKey, index);
  }
}
