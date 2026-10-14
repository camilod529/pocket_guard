import Flutter
import UIKit
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // BGTaskScheduler requires every identifier to be registered with
    // `register(forTaskWithIdentifier:using:launchHandler:)` before the app
    // finishes launching - Dart's Workmanager().registerPeriodicTask() (see
    // main.dart) only submits a request, it can't perform this native
    // registration. Identifier must match Info.plist's
    // BGTaskSchedulerPermittedIdentifiers entry and the
    // recurringTransactionsTaskName constant in
    // lib/infrastructure/background/recurring_transaction_background_task.dart.
    // Frequency is in seconds and only matters here - the Dart-side
    // `frequency:` passed to registerPeriodicTask is Android-only.
    WorkmanagerPlugin.registerPeriodicTask(
      withIdentifier: "recurring-transactions-catchup",
      frequency: NSNumber(value: 12 * 60 * 60)
    )

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(
      forPlugin: "IncomingBackupFilePlugin")
    {
      IncomingBackupFilePlugin.register(with: registrar)
    }
  }
}

/// Receives `.pgbackup` files opened with PocketGuard from Files, Drive,
/// Mail, etc. (the type is declared in Info.plist), both when they launch
/// the app and while it's running. Each file is copied into the app's temp
/// directory and handed to Dart over a method channel - see
/// lib/infrastructure/platform/incoming_backup_file_channel.dart, which
/// must use the same channel and method names.
class IncomingBackupFilePlugin: NSObject, FlutterPlugin, FlutterSceneLifeCycleDelegate {
  private let channel: FlutterMethodChannel
  /// Path of a received file Dart hasn't taken yet - survives the gap
  /// between a cold launch and Dart being ready to listen.
  private var pendingPath: String?

  init(channel: FlutterMethodChannel) {
    self.channel = channel
  }

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "pocket_guard/incoming_backup_file",
      binaryMessenger: registrar.messenger())
    let instance = IncomingBackupFilePlugin(channel: channel)
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.addSceneDelegate(instance)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "takePendingFile":
      result(pendingPath)
      pendingPath = nil
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // Cold launch by opening a file.
  func scene(
    _ scene: UIScene, willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions?
  ) -> Bool {
    guard let contexts = connectionOptions?.urlContexts else { return false }
    return receive(contexts)
  }

  // Opened while the app is already running.
  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) -> Bool {
    return receive(URLContexts)
  }

  private func receive(_ contexts: Set<UIOpenURLContext>) -> Bool {
    guard
      let url = contexts.map(\.url).first(where: {
        $0.isFileURL && $0.pathExtension.lowercased() == "pgbackup"
      })
    else { return false }

    let scoped = url.startAccessingSecurityScopedResource()
    defer { if scoped { url.stopAccessingSecurityScopedResource() } }

    let destination = FileManager.default.temporaryDirectory
      .appendingPathComponent("incoming-\(UUID().uuidString).pgbackup")
    do {
      try FileManager.default.copyItem(at: url, to: destination)
    } catch {
      return false
    }
    // iOS put a copy in Documents/Inbox for us; don't let them pile up.
    if url.path.contains("/Inbox/") {
      try? FileManager.default.removeItem(at: url)
    }

    pendingPath = destination.path
    // Dart answers by calling takePendingFile; if it isn't listening yet
    // (cold launch), it takes the file once it starts.
    channel.invokeMethod("fileOpened", arguments: nil)
    return true
  }
}
