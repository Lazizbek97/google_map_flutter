import UIKit
import Flutter
import GoogleMaps 

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    GMSServices.provideAPIKey("AIzaSyA58QFhsr2qSp2tqnk5DN9gwvQS39CfJZ8")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
