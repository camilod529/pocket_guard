import 'package:money_manager_flutter/domain/data_sources/settings_data_source.dart';
import 'package:money_manager_flutter/domain/repositories/settings_repository.dart';
import 'package:money_manager_flutter/domain/services/logger_service.dart';
import 'package:money_manager_flutter/infrastructure/services/logger_service_impl.dart';

class SettingsRepositoryImpl extends SettingsRepository {
  final SettingsDataSource _dataSource;
  late final LoggerService _logger;

  SettingsRepositoryImpl({required SettingsDataSource dataSource})
    : _dataSource = dataSource {
    _logger = LoggerServiceImpl(runtimeType.toString());
  }

  @override
  Future<String?> getLocale() async {
    try {
      return await _dataSource.getLocale();
    } catch (e) {
      _logger.error('Error getting locale: $e');
      rethrow;
    }
  }

  @override
  Future<int?> getThemeIndex() async {
    try {
      return await _dataSource.getThemeIndex();
    } catch (e) {
      _logger.error('Error getting theme index: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveLocale(String locale) async {
    try {
      await _dataSource.saveLocale(locale);
    } catch (e) {
      _logger.error('Error saving locale: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveThemeIndex(int index) async {
    try {
      await _dataSource.saveThemeIndex(index);
    } catch (e) {
      _logger.error('Error saving theme index: $e');
      rethrow;
    }
  }
}
