import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Tạo Method Channel để nhận API key từ Flutter
    let controller:  FlutterViewController = window?.rootViewController as! FlutterViewController
    let configChannel = FlutterMethodChannel(name: "com.cameroon.localizy/config",
                                             binaryMessenger: controller.binaryMessenger)
    
    configChannel.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "setGoogleMapsApiKey" {
        if let args = call.arguments as? Dictionary<String, Any>,
           let apiKey = args["apiKey"] as? String {
          GMSServices.provideAPIKey(apiKey)
          result(true)
        } else {
          result(FlutterError(code: "UNAVAILABLE", message: "API Key not available", details: nil))
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions:  launchOptions)
  }
}