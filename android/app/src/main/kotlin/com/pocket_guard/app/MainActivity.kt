package com.pocket_guard.app

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * Receives .pgbackup files opened with PocketGuard (the intent filter is in
 * AndroidManifest.xml), both when they launch the app and while it's
 * running. Each file is copied into the cache directory and handed to Dart
 * over a method channel - see
 * lib/infrastructure/platform/incoming_backup_file_channel.dart, which must
 * use the same channel and method names.
 */
class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null

    /** A received file Dart hasn't taken yet (e.g. during a cold launch). */
    private var pendingPath: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "pocket_guard/incoming_backup_file",
        ).also {
            it.setMethodCallHandler { call, result ->
                if (call.method == "takePendingFile") {
                    result.success(pendingPath)
                    pendingPath = null
                } else {
                    result.notImplemented()
                }
            }
        }
        receive(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        receive(intent)
    }

    private fun receive(intent: Intent?) {
        if (intent?.action != Intent.ACTION_VIEW) return
        val uri = intent.data ?: return
        // Handled once: don't re-import on a configuration change, which
        // re-runs configureFlutterEngine with the same intent.
        intent.action = null

        val destination = File(cacheDir, "incoming-${System.nanoTime()}.pgbackup")
        try {
            contentResolver.openInputStream(uri)?.use { input ->
                destination.outputStream().use { output -> input.copyTo(output) }
            } ?: return
        } catch (e: Exception) {
            return
        }

        pendingPath = destination.absolutePath
        // Dart answers by calling takePendingFile; if it isn't listening yet
        // (cold launch), it takes the file once it starts.
        channel?.invokeMethod("fileOpened", null)
    }
}
