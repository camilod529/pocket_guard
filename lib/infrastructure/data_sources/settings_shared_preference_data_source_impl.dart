import 'package:pocket_guard/domain/data_sources/settings_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsSharedPreferenceDataSourceImpl implements SettingsDataSource {
  static const String _themeIndexKey = 'theme_index';
  static const String _localeKey = 'locale';

  SettingsSharedPreferenceDataSourceImpl();

  @override
  Future<String?> getLocale() async {
    final prefs = await _getSharedPreferences();
    return prefs.getString(_localeKey);
  }

  @override
  Future<int?> getThemeIndex() async {
    final prefs = await _getSharedPreferences();
    return prefs.getInt(_themeIndexKey);
  }

  @override
  Future<void> saveLocale(String locale) async {
    final prefs = await _getSharedPreferences();
    await prefs.setString(_localeKey, locale);
  }

  @override
  Future<void> saveThemeIndex(int index) async {
    final prefs = await _getSharedPreferences();
    await prefs.setInt(_themeIndexKey, index);
  }

  Future<SharedPreferences> _getSharedPreferences() async =>
      await SharedPreferences.getInstance();
}
