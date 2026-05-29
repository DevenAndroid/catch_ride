import UIKit
import Flutter
import FirebaseCore
import app_links

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

    // Capture Universal Link from cold start launch options
    if let activityDictionary = launchOptions?[.userActivityDictionary] as? [AnyHashable: Any] {
      for key in activityDictionary.keys {
        if let userActivity = activityDictionary[key] as? NSUserActivity,
           let url = userActivity.webpageURL {
          AppLinks.shared.handleLink(url: url)
          print("Universal Link (cold start): \(url)")
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Universal Links — explicitly forward to app_links plugin
  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
       let url = userActivity.webpageURL {
      AppLinks.shared.handleLink(url: url)
      print("Universal Link (warm start): \(url)")
    }
    return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
  }
}
