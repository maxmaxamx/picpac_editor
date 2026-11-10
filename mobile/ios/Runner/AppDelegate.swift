import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Безопасная инициализация Google Maps SDK для предотвращения краша GMSException на iOS
    let apiKey = ProcessInfo.processInfo.environment["GOOGLE_MAPS_API_KEY"] ?? "AIzaSyDummyDevelopmentKeyForPicPacApp"
    GMSServices.provideAPIKey(apiKey)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
