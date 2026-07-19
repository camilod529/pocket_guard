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
  }
}
