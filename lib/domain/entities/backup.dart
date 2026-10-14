/// What a backup can contain. The user picks sections when exporting, and
/// picks among the sections a file contains when restoring.
enum BackupSection {
  /// Merged on restore (never deleted) - system categories are matched by
  /// their nameKey, since their ids differ between installs.
  categories,

  /// Accounts, transactions, recurring rules and savings goals, restored as
  /// one unit: a goal's money has already left its account's balance, so
  /// restoring one without the other would make money appear or vanish.
  money,

  budgets,
  wishlist,

  /// Theme and language.
  settings;

  /// Sections that must travel with this one: money and budgets reference
  /// categories by id, and a wishlist item's category link only survives
  /// if its category does.
  Set<BackupSection> get requires => switch (this) {
    money || budgets || wishlist => {categories},
    categories || settings => const {},
  };

  /// The tables this section carries, by their name in the backup file.
  List<String> get tables => switch (this) {
    categories => const ['categories'],
    money => const [
      'accounts',
      'savingsGoals',
      'goalContributions',
      'transactions',
      'recurringTransactions',
    ],
    budgets => const ['budgets'],
    wishlist => const ['wishlistItems'],
    settings => const [],
  };

  /// [sections] plus everything they require.
  static Set<BackupSection> withRequirements(Set<BackupSection> sections) => {
    ...sections,
    for (final section in sections) ...section.requires,
  };
}

/// Describes a backup file: readable before restoring anything.
class BackupManifest {
  /// Version of the file layout. A file with a newer version than this app
  /// understands is rejected rather than half-read.
  final int formatVersion;
  final DateTime createdAt;

  /// The database schema the data was exported from - informational; rows
  /// are stored in the backup format, not raw database rows.
  final int schemaVersion;
  final Set<BackupSection> sections;

  /// Rows per table, e.g. {'accounts': 3, 'transactions': 120}.
  final Map<String, int> counts;

  const BackupManifest({
    required this.formatVersion,
    required this.createdAt,
    required this.schemaVersion,
    required this.sections,
    required this.counts,
  });
}

/// A decoded backup: the manifest plus each table's rows in the backup's
/// own JSON shape (see backup_row_codecs.dart), and the settings values.
class BackupContents {
  final BackupManifest manifest;
  final Map<String, List<Map<String, Object?>>> tables;
  final Map<String, Object?> settings;

  const BackupContents({
    required this.manifest,
    required this.tables,
    required this.settings,
  });
}

/// Why a file couldn't be read. Nothing is restored in any of these cases.
enum BackupError {
  /// Not a PocketGuard backup at all.
  notABackup,

  /// Made by a newer version of the app.
  newerFormat,

  /// Damaged: a checksum or the archive itself doesn't add up.
  corrupted,

  /// Encrypted, and no password was given.
  passwordRequired,

  /// Encrypted, and the password is wrong (or the file was tampered with -
  /// AES-GCM can't tell the two apart).
  wrongPassword,
}

class BackupException implements Exception {
  final BackupError error;
  final Object? cause;

  const BackupException(this.error, [this.cause]);

  @override
  String toString() => 'BackupException(${error.name})';
}
