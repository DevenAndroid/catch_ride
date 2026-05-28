import UIKit
import Flutter
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let plistPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
    print("GoogleService-Info.plist path: \(plistPath ?? "NOT_FOUND")")

    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
      print("Firebase configured from AppDelegate")
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
