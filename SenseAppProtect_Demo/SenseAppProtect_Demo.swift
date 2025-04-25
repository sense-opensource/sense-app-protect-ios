


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

@objc public protocol SenseOSDelegate {
    func onFailure(message: String)
    func onSuccess(data: String)
}

let sense = SenseOS()
public class SenseOS: NSObject{
    private static var senseConfig: SenseOSProtectConfig?
    static var delegate: SenseOSDelegate?
    
    public static func initSDK(senseConfig: SenseOSProtectConfig?, withDelegate: SenseOSDelegate?) {
        self.delegate = withDelegate
        self.senseConfig = senseConfig
    }
    
    public static func getSenseDetails(
        withDelegate: SenseOSDelegate?) {
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


