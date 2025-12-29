abstract class SettingsDataSource {
  Future<String?> getLocale();
  Future<int?> getThemeIndex();

  Future<void> saveLocale(String locale);
  Future<void> saveThemeIndex(int index);
}
