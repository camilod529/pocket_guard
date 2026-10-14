import 'dart:async';

import 'package:flutter/services.dart';

/// `.pgbackup` files the OS opened with PocketGuard (Files, Drive, Mail...).
///
/// The native side (IncomingBackupFilePlugin in ios/Runner/AppDelegate.swift,
/// MainActivity.kt on Android) copies each file into the app's temp/cache
/// directory, keeps its path as "pending", and calls `fileOpened`. Dart then
/// takes it with `takePendingFile` - which also covers a cold launch, where
/// the file arrives before Dart is listening.
class IncomingBackupFileChannel {
  IncomingBackupFileChannel({MethodChannel? channel})
    : _channel =
          channel ?? const MethodChannel('pocket_guard/incoming_backup_file') {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'fileOpened') {
        final path = await takePendingFile();
        if (path != null) _files.add(path);
      }
    });
  }

  final MethodChannel _channel;
  final _files = StreamController<String>.broadcast();

  /// Paths of files opened while the app is running.
  Stream<String> get files => _files.stream;

  /// The file that launched the app (or arrived before anyone listened),
  /// at most once.
  Future<String?> takePendingFile() async {
    try {
      return await _channel.invokeMethod<String>('takePendingFile');
    } on MissingPluginException {
      // Platforms without the native side (desktop, tests).
      return null;
    }
  }
}
