


import Foundation
import UIKit
import CoreTelephony
import MapKit
import CoreLocation
import Network
import SystemConfiguration.CaptiveNetwork
import LocalAuthentication
import AVFoundation
import MediaPlayer
import CoreBluetooth

let timeZone = TimeZone.current
let timeZoneName = timeZone.identifier

@objc public protocol SenseOSProtectDelegate {
    func onFailure(message: String)
    func onSuccess(data: String)
}

public class SenseOSProtect: NSObject{
    public static let shared = SenseOSProtect()
    
    private static var senseConfig: SenseOSProtectConfig?
    static var delegate: SenseOSProtectDelegate?
    
    private override init() {}
    
    public static func initSDK(senseConfig: SenseOSProtectConfig?, withDelegate: SenseOSProtectDelegate?) {
        print("SDK initialized")
        self.senseConfig = senseConfig
        self.delegate = withDelegate
       
    }
    
    public static func getSenseDetails(withDelegate: SenseOSProtectDelegate?) {
           guard let config = self.senseConfig else {
               withDelegate?.onFailure(message: "SDK not initialized")
               return
           }

           getInstalledAppsFromLocalList(packageList: config.installedAppList) { installedApps in
               self.delegate = withDelegate

               let data: [String: Any] = [
                   "str": [
                       "version": "0.0.1",
                       "detection": DeviceDetail().getDetection(data: installedApps)
                   ]
               ]

               if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                  let jsonString = String(data: jsonData, encoding: .utf8) {
                   withDelegate?.onSuccess(data: jsonString)
               } else {
                   withDelegate?.onFailure(message: "Failed to serialize data")
               }
           }
       }

       private static func getInstalledAppsFromLocalList(
           packageList: [(packageName: String, packageCode: String)],
           completion: @escaping ([String: Bool]) -> Void
       ) {
           let installedApps = checkInstalledApps(packageList: packageList)
           completion(installedApps)
       }

       private static func checkInstalledApps(
           packageList: [(packageName: String, packageCode: String)]
       ) -> [String: Bool] {
           var result: [String: Bool] = [:]
           for (packageName, packageCode) in packageList {
               if let url = URL(string: "\(packageCode)://"), UIApplication.shared.canOpenURL(url) {
                   result[packageName] = true
               } else {
                   result[packageName] = false
               }
           }
           return result
       }
   }

public class DeviceDetail {
    
    public func getDetection(data:Any) -> Dictionary<String, Any> {
        return [
            "isFrida" : isFridaRunning(),
            "isJailbroken" : isJailbroken(),
            "isSimulator" : UIDevice.isSimulator,
            "sim": isSIMPresent(),
            "vpn": isVPNConnected(),
            "developerModeEnabled": isLikelyDeveloperMode(),
            "installedApps": data
        ]
    }
}


