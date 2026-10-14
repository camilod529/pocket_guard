import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_guard/infrastructure/platform/incoming_backup_file_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channelName = 'pocket_guard/incoming_backup_file';
  const channel = MethodChannel(channelName);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  /// Plays the native side: holds one pending path, handed out once.
  void fakeNative(String? pending) {
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method != 'takePendingFile') return null;
      final path = pending;
      pending = null;
      return path;
    });
  }

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('a file that launched the app is taken exactly once', () async {
    fakeNative('/tmp/incoming-1.pgbackup');
    final incoming = IncomingBackupFileChannel();

    expect(await incoming.takePendingFile(), '/tmp/incoming-1.pgbackup');
    expect(await incoming.takePendingFile(), isNull);
  });

  test('a file opened while running is delivered on the stream', () async {
    fakeNative('/tmp/incoming-2.pgbackup');
    final incoming = IncomingBackupFileChannel();
    final received = expectLater(
      incoming.files,
      emits('/tmp/incoming-2.pgbackup'),
    );

    // Native announces the file; Dart takes it.
    await messenger.handlePlatformMessage(
      channelName,
      const StandardMethodCodec().encodeMethodCall(
        const MethodCall('fileOpened'),
      ),
      (_) {},
    );

    await received;
  });

  test('platforms without the native side report no file', () async {
    // No mock handler: MissingPluginException.
    expect(await IncomingBackupFileChannel().takePendingFile(), isNull);
  });
}
