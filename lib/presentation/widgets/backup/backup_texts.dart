import 'package:flutter/material.dart';
import 'package:pocket_guard/domain/entities/backup.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';

/// User-facing names, descriptions and icons for backup sections, and
/// messages for backup errors.
extension BackupSectionTexts on BackupSection {
  IconData get icon => switch (this) {
    BackupSection.categories => Icons.category_outlined,
    BackupSection.money => Icons.account_balance_wallet_outlined,
    BackupSection.budgets => Icons.pie_chart_outline,
    BackupSection.wishlist => Icons.shopping_bag_outlined,
    BackupSection.settings => Icons.tune,
  };

  String description(AppLocalizations l10n) => switch (this) {
    BackupSection.categories => l10n.backupSectionCategoriesDescription,
    BackupSection.money => l10n.backupSectionMoneyDescription,
    BackupSection.budgets => l10n.backupSectionBudgetsDescription,
    BackupSection.wishlist => l10n.backupSectionWishlistDescription,
    BackupSection.settings => l10n.backupSectionSettingsDescription,
  };

  String title(AppLocalizations l10n) => switch (this) {
    BackupSection.categories => l10n.backupSectionCategories,
    BackupSection.money => l10n.backupSectionMoney,
    BackupSection.budgets => l10n.backupSectionBudgets,
    BackupSection.wishlist => l10n.backupSectionWishlist,
    BackupSection.settings => l10n.backupSectionSettings,
  };
}

String backupErrorMessage(AppLocalizations l10n, BackupError error) =>
    switch (error) {
      BackupError.notABackup => l10n.backupErrorNotABackup,
      BackupError.newerFormat => l10n.backupErrorNewerFormat,
      BackupError.corrupted => l10n.backupErrorCorrupted,
      BackupError.passwordRequired ||
      BackupError.wrongPassword => l10n.backupErrorWrongPassword,
    };

/// A checklist of sections where anything another checked section needs is
/// shown checked and locked. [selected] is what the user picked;
/// [available] limits the list (e.g. to what a backup file contains).
class BackupSectionChecklist extends StatelessWidget {
  final Set<BackupSection> available;
  final Set<BackupSection> selected;
  final ValueChanged<Set<BackupSection>> onChanged;

  /// Optional extra line per section (e.g. "12 items").
  final String? Function(BackupSection section)? detail;

  const BackupSectionChecklist({
    super.key,
    required this.available,
    required this.selected,
    required this.onChanged,
    this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final effective = BackupSection.withRequirements(selected);

    return Column(
      children: [
        for (final section in BackupSection.values)
          if (available.contains(section))
            Builder(
              builder: (context) {
                // Another checked section needs it, so it can't be unticked
                // - whether or not the user also ticked it themselves.
                final locked = selected.any(
                  (other) =>
                      other != section && other.requires.contains(section),
                );
                final extra = detail?.call(section);
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: Icon(section.icon),
                  value: effective.contains(section),
                  onChanged: locked
                      ? null
                      : (checked) => onChanged(
                          checked == true
                              ? {...selected, section}
                              : ({...selected}..remove(section)),
                        ),
                  title: Text(section.title(l10n)),
                  subtitle: Text(
                    [
                      locked
                          ? l10n.backupSectionRequired
                          : section.description(l10n),
                      ?extra,
                    ].join(' · '),
                  ),
                );
              },
            ),
      ],
    );
  }
}
