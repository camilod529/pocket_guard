import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_guard/domain/entities/backup.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/backup/backup_provider.dart';
import 'package:pocket_guard/presentation/widgets/backup/backup_texts.dart';
import 'package:pocket_guard/utils/shared/dates/calendar_date_formatter.dart';

/// Shows what a decoded backup contains and restores the chosen sections.
/// Nothing is written until the user confirms.
class BackupRestoreScreen extends ConsumerStatefulWidget {
  final BackupContents contents;

  const BackupRestoreScreen({super.key, required this.contents});

  @override
  ConsumerState<BackupRestoreScreen> createState() =>
      _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  // Pre-tick only sections with something in them: restoring an empty
  // section still replaces it, so a backup from a device with no budgets
  // would silently wipe this device's budgets. Empty ones can still be
  // ticked on purpose.
  late Set<BackupSection> _selected = {
    for (final section in widget.contents.manifest.sections)
      if (section == BackupSection.settings ||
          section.tables.any(
            (table) => (widget.contents.manifest.counts[table] ?? 0) > 0,
          ))
        section,
  };
  bool _busy = false;

  BackupManifest get _manifest => widget.contents.manifest;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final created = CalendarDateFormatter(
      Localizations.localeOf(context),
    ).formatFullDate(_manifest.createdAt.toLocal());

    return Scaffold(
      appBar: AppBar(title: Text(l10n.restoreBackupTitle)),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(l10n.backupCreatedOn(created)),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.restoreChooseSections,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            BackupSectionChecklist(
              available: _manifest.sections,
              selected: _selected,
              onChanged: (s) => setState(() => _selected = s),
              detail: (section) => section == BackupSection.settings
                  ? null
                  : l10n.backupItemCount(
                      section.tables.fold(
                        0,
                        (sum, table) => sum + (_manifest.counts[table] ?? 0),
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.restoreReplaceNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: _selected.isEmpty ? null : () => _restore(l10n),
              icon: const Icon(Icons.restore),
              label: Text(l10n.restoreButton),
            ),
            if (_busy) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _restore(AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.restoreConfirmTitle),
        content: Text(l10n.restoreConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.restoreButton),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(backupRepositoryProvider)
          .restore(widget.contents, _selected);
      invalidateAfterRestore(ref);
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.restoreSuccess),
          backgroundColor: Colors.green,
        ),
      );
      if (mounted) context.pop();
    } on BackupException catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(backupErrorMessage(l10n, e.error)),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.restoreFailed),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
