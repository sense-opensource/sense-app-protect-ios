


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

let sense = SenseOSProtect()
public class SenseOSProtect: NSObject{
    private static var senseConfig: SenseOSProtectConfig?
    static var delegate: SenseOSProtectDelegate?
    
    public static func initSDK(senseConfig: SenseOSProtectConfig?, withDelegate: SenseOSProtectDelegate?) {
        self.delegate = withDelegate
        self.senseConfig = senseConfig
    }
    
    public static func getSenseDetails(
        withDelegate: SenseOSProtectDelegate?) {
            getInstalledAppsFromLocalList{ installedApps in
                self.delegate = withDelegate

                let data: [String: Any] = [
                    "str": [
                        "version": "0.0.1",
                        "detection": DeviceDetail().getDetection(data: installedApps)
                    ],
                ]
                
                if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    withDelegate?.onSuccess(data: jsonString)
                } else {
                    withDelegate?.onFailure(message: "Failed to serialize data")
                }
            }
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


