import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Set up method channel for shared UserDefaults
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "shared_user_defaults", binaryMessenger: controller.binaryMessenger)
    
    channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      self?.handleSharedUserDefaultsCall(call: call, result: result)
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func handleSharedUserDefaultsCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let appGroupId = args["appGroupId"] as? String,
          let key = args["key"] as? String else {
      result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
      return
    }
    
    guard let sharedDefaults = UserDefaults(suiteName: appGroupId) else {
      result(FlutterError(code: "APP_GROUP_ERROR", message: "Failed to access app group UserDefaults", details: nil))
      return
    }
    
    switch call.method {
    case "setString":
      guard let value = args["value"] as? String else {
        result(FlutterError(code: "INVALID_VALUE", message: "Value must be a string", details: nil))
        return
      }
      sharedDefaults.set(value, forKey: key)
      let success = sharedDefaults.synchronize()
      print("SharedUserDefaults: Set \(key) = \(value) (success: \(success))")
      result(success)
      
    case "getString":
      let value = sharedDefaults.string(forKey: key)
      print("SharedUserDefaults: Get \(key) = \(value ?? "nil")")
      result(value)
      
    case "remove":
      sharedDefaults.removeObject(forKey: key)
      let success = sharedDefaults.synchronize()
      print("SharedUserDefaults: Removed \(key) (success: \(success))")
      result(success)
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
