import 'dart:isolate';
import 'dart:typed_data';

import 'package:pocket_guard/domain/data_sources/backup_data_source.dart';
import 'package:pocket_guard/domain/data_sources/settings_data_source.dart';
import 'package:pocket_guard/domain/entities/backup.dart';
import 'package:pocket_guard/domain/repositories/backup_repository.dart';
import 'package:pocket_guard/domain/services/logger_service.dart';
import 'package:pocket_guard/infrastructure/backup/backup_file_codec.dart';
import 'package:pocket_guard/infrastructure/errors/data_exceptions.dart';
import 'package:pocket_guard/infrastructure/services/logger_service_impl.dart';

class BackupRepositoryImpl extends BackupRepository {
  BackupRepositoryImpl({
    required BackupDataSource dataSource,
    required SettingsDataSource settings,
    int iterations = BackupFileCodec.defaultIterations,
    bool runCodecInIsolate = true,
  }) : _dataSource = dataSource,
       _settings = settings,
       _iterations = iterations,
       _runCodecInIsolate = runCodecInIsolate {
    _logger = LoggerServiceImpl(runtimeType.toString());
  }

  static const _localeKey = 'locale';
  static const _themeIndexKey = 'themeIndex';

  final BackupDataSource _dataSource;
  final SettingsDataSource _settings;
  final int _iterations;

  /// Encryption is ~2s of pure-Dart PBKDF2 per file, which would freeze
  /// the UI on the main isolate. Tests turn this off.
  final bool _runCodecInIsolate;
  late final LoggerService _logger;

  @override
  Future<Uint8List> createBackup(
    Set<BackupSection> sections, {
    String? password,
  }) async {
    final included = BackupSection.withRequirements(sections);
    _logger.info('Creating backup: ${included.map((s) => s.name)}');
    try {
      final tables = await _dataSource.readTables(included);
      final contents = BackupContents(
        manifest: BackupManifest(
          formatVersion: BackupFileCodec.formatVersion,
          createdAt: DateTime.now(),
          schemaVersion: _dataSource.schemaVersion,
          sections: included,
          counts: {for (final e in tables.entries) e.key: e.value.length},
        ),
        tables: tables,
        settings: included.contains(BackupSection.settings)
            ? {
                _localeKey: await _settings.getLocale(),
                _themeIndexKey: await _settings.getThemeIndex(),
              }
            : const {},
      );

      // Only plain values cross into the isolate - not `this`, which holds
      // the database.
      final iterations = _iterations;
      final bytes = await _runCodec(
        () => BackupFileCodec(
          iterations: iterations,
        ).encode(contents, password: password),
      );
      _logger.info('Backup created: ${bytes.length} bytes');
      return bytes;
    } on DataException catch (e, stackTrace) {
      _logger.error(
        'Failed to create backup: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  bool isEncrypted(Uint8List bytes) => BackupFileCodec().isEncrypted(bytes);

  @override
  Future<BackupContents> readBackup(Uint8List bytes, {String? password}) async {
    try {
      return await _runCodec(
        () => BackupFileCodec().decode(bytes, password: password),
      );
    } on BackupException catch (e) {
      // Expected outcomes (wrong password, foreign file) - not errors.
      _logger.info('Backup not readable: ${e.error.name}');
      rethrow;
    }
  }

  @override
  Future<Map<String, int>> restore(
    BackupContents contents,
    Set<BackupSection> sections,
  ) async {
    // Never restore something the file doesn't have; always restore what
    // the chosen sections depend on.
    final included = BackupSection.withRequirements(
      sections,
    ).intersection(contents.manifest.sections);
    _logger.info('Restoring backup: ${included.map((s) => s.name)}');
    try {
      final written = await _dataSource.restoreTables(
        contents.tables,
        included,
      );
      // Settings live in shared preferences, outside the database
      // transaction - restored only once the data restore has succeeded.
      if (included.contains(BackupSection.settings)) {
        if (contents.settings[_localeKey] case final String locale) {
          await _settings.saveLocale(locale);
        }
        if (contents.settings[_themeIndexKey] case final int index) {
          await _settings.saveThemeIndex(index);
        }
      }
      _logger.info('Backup restored: $written');
      return written;
    } on DataException catch (e, stackTrace) {
      _logger.error(
        'Failed to restore backup: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<T> _runCodec<T>(Future<T> Function() work) =>
      _runCodecInIsolate ? Isolate.run(work) : work();
}
