import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Present notifications while the app is in the foreground on iOS 10+.
    // firebase_messaging registers the APNs token automatically via method
    // swizzling (FirebaseAppDelegateProxyEnabled is on by default), so no
    // manual APNs token handling is required here.
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
