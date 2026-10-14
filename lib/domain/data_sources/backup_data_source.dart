import 'package:pocket_guard/domain/entities/backup.dart';

abstract class BackupDataSource {
  /// The database schema version, recorded in the manifest.
  int get schemaVersion;

  /// Every row of every table in [sections], in the backup's JSON shape,
  /// keyed by table name.
  Future<Map<String, List<Map<String, Object?>>>> readTables(
    Set<BackupSection> sections,
  );

  /// Writes [sections] from [tables] in a single database transaction:
  /// categories are merged, every other section replaces what's there.
  /// Either everything is restored or nothing is. Returns rows written per
  /// table.
  Future<Map<String, int>> restoreTables(
    Map<String, List<Map<String, Object?>>> tables,
    Set<BackupSection> sections,
  );
}
