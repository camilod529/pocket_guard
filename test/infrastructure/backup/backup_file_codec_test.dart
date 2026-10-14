import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_guard/domain/entities/backup.dart';
import 'package:pocket_guard/infrastructure/backup/backup_file_codec.dart';

void main() {
  // A low work factor keeps the suite fast; the real default is exercised
  // once below.
  final codec = BackupFileCodec(iterations: 1000);

  BackupContents sample() => BackupContents(
    manifest: BackupManifest(
      formatVersion: BackupFileCodec.formatVersion,
      createdAt: DateTime.utc(2026, 10, 14, 12),
      schemaVersion: 10,
      sections: {BackupSection.categories, BackupSection.settings},
      counts: {'categories': 2},
    ),
    tables: {
      'categories': [
        {'id': 'a', 'label': 'Food', 'nameKey': null},
        {'id': 'b', 'label': 'Rent', 'nameKey': 'x'},
      ],
    },
    settings: {'locale': 'es', 'themeIndex': 3},
  );

  Matcher throwsBackupError(BackupError error) =>
      throwsA(isA<BackupException>().having((e) => e.error, 'error', error));

  test('round-trips without a password', () async {
    final bytes = await codec.encode(sample());

    expect(codec.isEncrypted(bytes), isFalse);
    final decoded = await codec.decode(bytes);
    expect(decoded.manifest.sections, sample().manifest.sections);
    expect(decoded.manifest.counts, {'categories': 2});
    expect(decoded.manifest.createdAt, DateTime.utc(2026, 10, 14, 12));
    expect(decoded.tables['categories'], sample().tables['categories']);
    expect(decoded.settings, {'locale': 'es', 'themeIndex': 3});
  });

  test('round-trips with a password, and the contents are unreadable '
      'without it', () async {
    final bytes = await codec.encode(sample(), password: 'hunter2');

    expect(codec.isEncrypted(bytes), isTrue);
    expect(utf8.decode(bytes, allowMalformed: true), isNot(contains('Food')));
    final decoded = await codec.decode(bytes, password: 'hunter2');
    expect(decoded.tables['categories'], sample().tables['categories']);
  });

  test('an encrypted file needs a password', () async {
    final bytes = await codec.encode(sample(), password: 'hunter2');

    await expectLater(
      codec.decode(bytes),
      throwsBackupError(BackupError.passwordRequired),
    );
    await expectLater(
      codec.decode(bytes, password: 'wrong'),
      throwsBackupError(BackupError.wrongPassword),
    );
  });

  test('any changed byte in an encrypted file is detected', () async {
    final bytes = await codec.encode(sample(), password: 'hunter2');
    // One byte of ciphertext, and one of the header (authenticated too).
    for (final index in [bytes.length - 40, 12]) {
      final tampered = Uint8List.fromList(bytes)..[index] ^= 0x01;
      await expectLater(
        codec.decode(tampered, password: 'hunter2'),
        throwsBackupError(BackupError.wrongPassword),
      );
    }
  });

  test('a damaged unencrypted file is reported as corrupted', () async {
    final bytes = await codec.encode(sample());
    final truncated = Uint8List.sublistView(bytes, 0, bytes.length - 30);

    await expectLater(
      codec.decode(truncated),
      throwsBackupError(BackupError.corrupted),
    );
  });

  test('an edited data file fails its checksum', () async {
    // Re-zip with a modified categories file but the original manifest.
    final bytes = await codec.encode(sample());
    final archive = ZipDecoder().decodeBytes(bytes.sublist(10));
    final edited = Archive();
    for (final file in archive.files) {
      edited.addFile(
        file.name == 'data/categories.json'
            ? ArchiveFile.bytes(file.name, utf8.encode('[{"id":"evil"},{}]'))
            : ArchiveFile.bytes(file.name, file.content),
      );
    }
    final rebuilt = Uint8List.fromList([
      ...bytes.sublist(0, 10),
      ...ZipEncoder().encodeBytes(edited),
    ]);

    await expectLater(
      codec.decode(rebuilt),
      throwsBackupError(BackupError.corrupted),
    );
  });

  test('other files are not backups', () async {
    await expectLater(
      codec.decode(Uint8List.fromList(utf8.encode('just some text file'))),
      throwsBackupError(BackupError.notABackup),
    );
    await expectLater(
      codec.decode(Uint8List(3)),
      throwsBackupError(BackupError.notABackup),
    );
  });

  test('a file from a newer app version is rejected', () async {
    final bytes = await codec.encode(sample());
    final newer = Uint8List.fromList(bytes)..[8] = 99;

    await expectLater(
      codec.decode(newer),
      throwsBackupError(BackupError.newerFormat),
    );
  });

  test('the real work factor round-trips and reports its cost', () async {
    final real = BackupFileCodec();
    final watch = Stopwatch()..start();
    final bytes = await real.encode(sample(), password: 'hunter2');
    final encodeMs = watch.elapsedMilliseconds;
    watch.reset();
    await real.decode(bytes, password: 'hunter2');
    // ignore: avoid_print
    print(
      'PBKDF2 x${BackupFileCodec.defaultIterations}: '
      'encode ${encodeMs}ms, decode ${watch.elapsedMilliseconds}ms',
    );
  });
}
