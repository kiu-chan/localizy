import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application:  UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Tắt verbose logging của Google Maps
    GMSServices.setMetalRendererEnabled(true)
    
    // Đọc API key từ Secrets.plist hoặc Info.plist
    var apiKey: String? = nil
    
    if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
       let secrets = NSDictionary(contentsOfFile: path),
       let key = secrets["GOOGLE_MAPS_API_KEY"] as? String {
        apiKey = key
    }
    
    if apiKey == nil,
       let key = Bundle.main.object(forInfoDictionaryKey:  "GOOGLE_MAPS_API_KEY") as? String {
        apiKey = key
    }
    
    // Khởi tạo Google Maps
    if let apiKey = apiKey, !apiKey.isEmpty {
        GMSServices.provideAPIKey(apiKey)
        #if DEBUG
        print("✅ Google Maps initialized")
        #endif
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}