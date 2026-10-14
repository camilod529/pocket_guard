import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pocket_guard/config/router/router.dart';
import 'package:pocket_guard/config/router/routes.dart';
import 'package:pocket_guard/presentation/providers/backup/backup_provider.dart';

/// Sends `.pgbackup` files the OS opened with the app to Backup & Restore,
/// whether one launched the app or arrived while it was running.
class IncomingBackupFileListener extends ConsumerStatefulWidget {
  final Widget child;

  const IncomingBackupFileListener({super.key, required this.child});

  @override
  ConsumerState<IncomingBackupFileListener> createState() =>
      _IncomingBackupFileListenerState();
}

class _IncomingBackupFileListenerState
    extends ConsumerState<IncomingBackupFileListener> {
  StreamSubscription<String>? _subscription;

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final channel = ref.read(incomingBackupFileChannelProvider);
    _subscription = channel.files.listen(_open);
    // After the first frame, so the router has a page to push onto.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final path = await channel.takePendingFile();
      await _sweepStaleCopies(keep: path);
      if (path != null) _open(path);
    });
  }

  /// BackupScreen deletes each copy once read, but one received just
  /// before the app was killed would otherwise sit in the temp/cache
  /// directory (where the native side writes them) forever.
  Future<void> _sweepStaleCopies({String? keep}) async {
    try {
      final dir = await getTemporaryDirectory();
      await for (final entity in dir.list()) {
        final name = entity.uri.pathSegments.last;
        if (entity is File &&
            name.startsWith('incoming-') &&
            name.endsWith('.pgbackup') &&
            entity.path != keep) {
          await entity.delete();
        }
      }
    } catch (_) {
      // Best effort - never block startup over temp files.
    }
  }

  void _open(String path) => appRouter.push(Routes.backup, extra: path);
}
