import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:cryptography/cryptography.dart';
import 'package:pocket_guard/domain/entities/backup.dart';

/// Reads and writes `.pgbackup` files.
///
/// Layout:
/// ```
/// "PGBACKUP"            8 bytes, identifies the file
/// container version     1 byte  (currently 1)
/// flags                 1 byte  (bit 0: encrypted)
/// -- unencrypted: the zip --
/// -- encrypted:
/// salt                  16 bytes
/// PBKDF2 iterations     4 bytes, big-endian
/// nonce                 12 bytes
/// AES-256-GCM ciphertext of the zip, then its 16-byte MAC
/// ```
/// Everything before the ciphertext is authenticated as associated data,
/// so tampering with the header fails decryption too.
///
/// The zip holds `manifest.json` plus one `data/<table>.json` per table and
/// `settings.json`. The manifest records a SHA-256 of every other entry, so
/// corruption is caught even in unencrypted files.
class BackupFileCodec {
  BackupFileCodec({this.iterations = defaultIterations});

  /// Bumped whenever the zip contents change shape (manifest keys, table
  /// files, row keys in BackupRowCodecs). Files with a newer version are
  /// rejected instead of half-read.
  static const formatVersion = 1;

  /// PBKDF2-HMAC-SHA256 work factor for new files (OWASP's 2023 figure).
  /// Stored per file, so it can be raised later without breaking old ones.
  static const defaultIterations = 600000;

  static const fileExtension = 'pgbackup';

  static final _magic = ascii.encode('PGBACKUP');
  static const _containerVersion = 1;
  static const _encryptedFlag = 0x01;
  static const _saltLength = 16;
  static const _nonceLength = 12;
  static const _macLength = 16;

  final int iterations;
  final _cipher = AesGcm.with256bits();

  Future<BackupContents> decode(Uint8List bytes, {String? password}) async {
    final encrypted = isEncrypted(bytes);
    final Uint8List zip;
    if (encrypted) {
      if (password == null || password.isEmpty) {
        throw const BackupException(BackupError.passwordRequired);
      }
      zip = await _decrypt(bytes, password);
    } else {
      zip = Uint8List.sublistView(bytes, _magic.length + 2);
    }
    return _readZip(zip);
  }

  Future<Uint8List> encode(
    BackupContents contents, {
    String? password,
  }) async {
    final zip = _writeZip(contents);
    if (password == null || password.isEmpty) {
      return Uint8List.fromList([
        ..._magic,
        _containerVersion,
        0,
        ...zip,
      ]);
    }
    return _encrypt(zip, password);
  }

  /// Checks the header only. Throws [BackupException] if [bytes] isn't a
  /// backup this app can read.
  bool isEncrypted(Uint8List bytes) {
    if (bytes.length < _magic.length + 2) {
      throw const BackupException(BackupError.notABackup);
    }
    for (var i = 0; i < _magic.length; i++) {
      if (bytes[i] != _magic[i]) {
        throw const BackupException(BackupError.notABackup);
      }
    }
    if (bytes[_magic.length] > _containerVersion) {
      throw const BackupException(BackupError.newerFormat);
    }
    return bytes[_magic.length + 1] & _encryptedFlag != 0;
  }

  Future<Uint8List> _decrypt(Uint8List bytes, String password) async {
    final headerLength = _magic.length + 2 + _saltLength + 4 + _nonceLength;
    if (bytes.length < headerLength + _macLength) {
      throw const BackupException(BackupError.corrupted);
    }
    var offset = _magic.length + 2;
    final salt = bytes.sublist(offset, offset += _saltLength);
    final storedIterations = ByteData.sublistView(
      bytes,
      offset,
      offset += 4,
    ).getUint32(0);
    final nonce = bytes.sublist(offset, offset += _nonceLength);
    final cipherText = bytes.sublist(offset, bytes.length - _macLength);
    final mac = Mac(bytes.sublist(bytes.length - _macLength));

    final key = await _deriveKey(password, salt, storedIterations);
    try {
      final zip = await _cipher.decrypt(
        SecretBox(cipherText, nonce: nonce, mac: mac),
        secretKey: key,
        aad: bytes.sublist(0, headerLength),
      );
      return Uint8List.fromList(zip);
    } on SecretBoxAuthenticationError {
      throw const BackupException(BackupError.wrongPassword);
    }
  }

  Future<SecretKey> _deriveKey(
    String password,
    List<int> salt,
    int iterations,
  ) => Pbkdf2.hmacSha256(
    iterations: iterations,
    bits: 256,
  ).deriveKeyFromPassword(password: password, nonce: salt);

  Future<Uint8List> _encrypt(Uint8List zip, String password) async {
    final salt = SecretKeyData.random(length: _saltLength).bytes;
    final nonce = _cipher.newNonce();
    final iterationBytes = ByteData(4)..setUint32(0, iterations);
    final header = Uint8List.fromList([
      ..._magic,
      _containerVersion,
      _encryptedFlag,
      ...salt,
      ...iterationBytes.buffer.asUint8List(),
      ...nonce,
    ]);

    final box = await _cipher.encrypt(
      zip,
      secretKey: await _deriveKey(password, salt, iterations),
      nonce: nonce,
      aad: header,
    );
    return Uint8List.fromList([...header, ...box.cipherText, ...box.mac.bytes]);
  }

  BackupContents _readZip(Uint8List zip) {
    try {
      final archive = ZipDecoder().decodeBytes(zip, verify: true);
      Uint8List entry(String name) {
        final file = archive.findFile(name);
        if (file == null) throw FormatException('Missing $name');
        return file.content;
      }

      final manifestJson =
          jsonDecode(utf8.decode(entry('manifest.json')))
              as Map<String, Object?>;
      if (manifestJson['format'] != 'pocketguard-backup') {
        throw const BackupException(BackupError.notABackup);
      }
      final version = manifestJson['formatVersion'] as int;
      if (version > formatVersion) {
        throw const BackupException(BackupError.newerFormat);
      }

      final checksums = (manifestJson['sha256'] as Map).cast<String, String>();
      Object? verifiedJson(String name) {
        final bytes = entry(name);
        if (_sha256Hex(bytes) != checksums[name]) {
          throw FormatException('Checksum mismatch for $name');
        }
        return jsonDecode(utf8.decode(bytes));
      }

      final manifest = BackupManifest(
        formatVersion: version,
        createdAt: DateTime.parse(manifestJson['createdAt'] as String),
        schemaVersion: manifestJson['schemaVersion'] as int,
        sections: {
          for (final name in (manifestJson['sections'] as List).cast<String>())
            BackupSection.values.byName(name),
        },
        counts: (manifestJson['counts'] as Map).cast<String, int>(),
      );

      final tables = <String, List<Map<String, Object?>>>{};
      for (final table in manifest.counts.keys) {
        final rows = (verifiedJson('data/$table.json') as List)
            .cast<Map<String, Object?>>();
        if (rows.length != manifest.counts[table]) {
          throw FormatException('Row count mismatch for $table');
        }
        tables[table] = rows;
      }
      final settings = manifest.sections.contains(BackupSection.settings)
          ? (verifiedJson('settings.json') as Map<String, Object?>)
          : const <String, Object?>{};

      return BackupContents(
        manifest: manifest,
        tables: tables,
        settings: settings,
      );
    } on BackupException {
      rethrow;
    } catch (e) {
      // Bad zip, bad JSON, wrong types, failed checksum - all "damaged".
      throw BackupException(BackupError.corrupted, e);
    }
  }

  static String _sha256Hex(List<int> bytes) {
    final digest = Sha256().toSync().hashSync(bytes);
    return digest.bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  Uint8List _writeZip(BackupContents contents) {
    final archive = Archive();
    final checksums = <String, String>{};
    void add(String name, Object? json) {
      final bytes = utf8.encode(jsonEncode(json));
      checksums[name] = _sha256Hex(bytes);
      archive.addFile(ArchiveFile.bytes(name, bytes));
    }

    contents.tables.forEach((table, rows) => add('data/$table.json', rows));
    if (contents.manifest.sections.contains(BackupSection.settings)) {
      add('settings.json', contents.settings);
    }

    final manifest = contents.manifest;
    add('manifest.json', {
      'format': 'pocketguard-backup',
      'formatVersion': manifest.formatVersion,
      'createdAt': manifest.createdAt.toUtc().toIso8601String(),
      'schemaVersion': manifest.schemaVersion,
      'sections': [for (final s in manifest.sections) s.name],
      'counts': manifest.counts,
      'sha256': {...checksums}..remove('manifest.json'),
    });
    return ZipEncoder().encodeBytes(archive);
  }
}
