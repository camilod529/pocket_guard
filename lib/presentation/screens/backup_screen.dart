import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pocket_guard/config/router/routes.dart';
import 'package:pocket_guard/domain/entities/backup.dart';
import 'package:pocket_guard/infrastructure/backup/backup_file_codec.dart';
import 'package:pocket_guard/l10n/app_localizations.dart';
import 'package:pocket_guard/presentation/providers/backup/backup_provider.dart';
import 'package:pocket_guard/presentation/widgets/backup/backup_texts.dart';
import 'package:pocket_guard/presentation/widgets/shared/forms/custom_form_field.dart';
import 'package:share_plus/share_plus.dart';

class BackupScreen extends ConsumerStatefulWidget {
  /// A backup the OS opened with the app (see IncomingBackupFileChannel):
  /// read on arrival and taken straight into the restore flow.
  final String? incomingFilePath;

  const BackupScreen({super.key, this.incomingFilePath});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  Set<BackupSection> _selected = BackupSection.values.toSet();
  String _password = '';
  String _confirmation = '';
  bool _busy = false;
  final _shareButtonKey = GlobalKey();

  bool get _passwordsMatch => _password == _confirmation;

  @override
  void initState() {
    super.initState();
    final path = widget.incomingFilePath;
    if (path != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;
        final file = File(path);
        try {
          final bytes = await file.readAsBytes();
          await _open(bytes, l10n);
        } on FileSystemException {
          _showError(l10n.backupErrorNotABackup);
        } finally {
          // Our own temp copy - the original stays wherever it came from.
          if (file.existsSync()) file.deleteSync();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupAndRestore)),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.createBackupTitle, style: textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(l10n.createBackupDescription),
                    const SizedBox(height: 8),
                    BackupSectionChecklist(
                      available: BackupSection.values.toSet(),
                      selected: _selected,
                      onChanged: (s) => setState(() => _selected = s),
                    ),
                    const SizedBox(height: 16),
                    CustomFormField(
                      label: l10n.backupPasswordLabel,
                      helperText: l10n.backupPasswordHelper,
                      prefixIcon: const Icon(Icons.lock_outline),
                      obscureText: true,
                      autocorrect: false,
                      enableSuggestions: false,
                      onChanged: (v) => setState(() => _password = v),
                    ),
                    if (_password.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      CustomFormField(
                        label: l10n.backupPasswordConfirmLabel,
                        prefixIcon: const Icon(Icons.lock_outline),
                        obscureText: true,
                        autocorrect: false,
                        enableSuggestions: false,
                        errorText: _confirmation.isNotEmpty && !_passwordsMatch
                            ? l10n.backupPasswordMismatch
                            : null,
                        onChanged: (v) => setState(() => _confirmation = v),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.backupPasswordWarning,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      key: _shareButtonKey,
                      onPressed:
                          _selected.isEmpty ||
                              (_password.isNotEmpty && !_passwordsMatch)
                          ? null
                          : () => _createBackup(l10n),
                      icon: const Icon(Icons.backup_outlined),
                      label: Text(l10n.createBackupButton),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.restoreBackupTitle, style: textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(l10n.restoreBackupDescription),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => _chooseFile(l10n),
                      icon: const Icon(Icons.restore),
                      label: Text(l10n.chooseBackupFileButton),
                    ),
                  ],
                ),
              ),
            ),
            if (_busy) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 8),
              Center(child: Text(l10n.backupWorking)),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _chooseFile(AppLocalizations l10n) async {
    final file = await FilePicker.pickFile();
    if (file == null || !mounted) return;
    await _open(await file.readAsBytes(), l10n);
  }

  /// Picked or opened from elsewhere: unlock if needed, then preview.
  Future<void> _open(Uint8List bytes, AppLocalizations l10n) async {
    if (!mounted) return;
    final repository = ref.read(backupRepositoryProvider);

    try {
      final BackupContents? contents;
      if (repository.isEncrypted(bytes)) {
        if (!mounted) return;
        contents = await showDialog<BackupContents>(
          context: context,
          builder: (_) => _UnlockDialog(
            unlock: (password) =>
                repository.readBackup(bytes, password: password),
          ),
        );
      } else {
        setState(() => _busy = true);
        contents = await repository.readBackup(bytes);
      }
      if (contents != null && mounted) {
        context.push(Routes.backupRestore, extra: contents);
      }
    } on BackupException catch (e) {
      _showError(backupErrorMessage(l10n, e.error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _createBackup(AppLocalizations l10n) async {
    setState(() => _busy = true);
    try {
      final bytes = await ref
          .read(backupRepositoryProvider)
          .createBackup(_selected, password: _password);

      final now = DateTime.now();
      final date =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';
      final file = File(
        '${(await getTemporaryDirectory()).path}/'
        'PocketGuard-$date.${BackupFileCodec.fileExtension}',
      );
      await file.writeAsBytes(bytes, flush: true);

      // iPad needs an anchor for the share popover.
      final box =
          _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/octet-stream')],
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (e) {
      _showError(l10n.backupFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}

/// Asks for the password and tries it, staying open with an error on a
/// wrong one. Resolves to the decoded contents, or null if cancelled.
class _UnlockDialog extends StatefulWidget {
  final Future<BackupContents> Function(String password) unlock;

  const _UnlockDialog({required this.unlock});

  @override
  State<_UnlockDialog> createState() => _UnlockDialogState();
}

class _UnlockDialogState extends State<_UnlockDialog> {
  String _password = '';
  String? _error;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.backupPasswordPromptTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.backupPasswordPrompt),
          const SizedBox(height: 16),
          TextField(
            obscureText: true,
            autofocus: true,
            autocorrect: false,
            enableSuggestions: false,
            enabled: !_busy,
            decoration: InputDecoration(
              labelText: l10n.backupPasswordLabel.split(' (').first,
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) => _password = v,
            onSubmitted: (_) => _submit(l10n),
          ),
          if (_busy) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : () => _submit(l10n),
          child: Text(l10n.backupUnlockButton),
        ),
      ],
    );
  }

  Future<void> _submit(AppLocalizations l10n) async {
    if (_password.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final contents = await widget.unlock(_password);
      if (mounted) Navigator.of(context).pop(contents);
    } on BackupException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = backupErrorMessage(l10n, e.error);
        });
      }
    }
  }
}
