import 'dart:typed_data';

import 'package:pocket_guard/domain/entities/backup.dart';

abstract class BackupRepository {
  /// A complete `.pgbackup` file with [sections] (plus whatever they
  /// require), encrypted when [password] is non-empty.
  Future<Uint8List> createBackup(
    Set<BackupSection> sections, {
    String? password,
  });

  /// Whether [bytes] needs a password to read. Throws [BackupException] if
  /// it isn't a backup this version can read.
  bool isEncrypted(Uint8List bytes);

  /// Decodes and fully validates a backup without changing anything.
  Future<BackupContents> readBackup(Uint8List bytes, {String? password});

  /// Restores [sections] (plus whatever they require) from [contents], all
  /// or nothing. Returns rows written per table.
  Future<Map<String, int>> restore(
    BackupContents contents,
    Set<BackupSection> sections,
  );
}
