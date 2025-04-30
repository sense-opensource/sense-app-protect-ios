

import Foundation
import UIKit
import CoreLocation
import SystemConfiguration
import Darwin
import Network
import SystemConfiguration.CaptiveNetwork
import LocalAuthentication
import AVFoundation
import MediaPlayer
import NetworkExtension
import AdSupport
import AppTrackingTransparency
import Foundation
import MachO
import ExternalAccessory
import Photos
import SystemConfiguration
import CryptoKit
import ObjectiveC
import MessageUI
import Contacts
import CoreGraphics
import Security
import DeviceActivity
import CoreTelephony


/* Jailbreak Detection (remove software restrictions) */
func isJailbroken() -> Bool {
    #if targetEnvironment(simulator)
    return false
    #endif
    
    let fileManager = FileManager.default
    let jailbreakFilePaths = [
        "/Applications/Cydia.app",
        "/Library/MobileSubstrate/MobileSubstrate.dylib",
        "/bin/bash",
        "/usr/sbin/sshd",
        "/etc/apt"
    ]
    
    // Check for existence of jailbreak files
    for path in jailbreakFilePaths {
        if fileManager.fileExists(atPath: path) {
            return true
        }
    }
    
    // Attempt to write to a restricted directory
    let tempPath = "/tmp/" + NSUUID().uuidString
    do {
        try "test".write(toFile: tempPath, atomically: true, encoding: .utf8)
        try fileManager.removeItem(atPath: tempPath)
        return true
    } catch {
        return false
    }
}

/* Get Network Type */
func getNetworkType() -> String {
    let telephonyInfo = CTTelephonyNetworkInfo()

    if let radioTechnologies = telephonyInfo.serviceCurrentRadioAccessTechnology {
        for (_, technology) in radioTechnologies {
            return technology
        }
    }
    return "Unknown"
}

/* Check the device whether Real device or Simulator */
extension UIDevice {
    static var isSimulator: Bool = {
#if targetEnvironment(simulator)
        return true
#else
        return false
#endif
    }()
}

func isSIMPresent() -> [String: Any] {
    let networkInfo = CTTelephonyNetworkInfo()
    let carriers = networkInfo.serviceSubscriberCellularProviders
    let radioTechs = networkInfo.serviceCurrentRadioAccessTechnology
    
    var simInfo: [String: Any] = [
        "count": 0
    ]
    
    var simCount = 0
    
    if let carriers = carriers {
        for (index, carrierIdentifier) in carriers.keys.enumerated() {
            if carriers[carrierIdentifier] != nil {
                let isSimEnabled = radioTechs?[carrierIdentifier] != nil
                simCount += 1
                simInfo["sim\(index + 1)Present"] = isSimEnabled
            }
        }
        simInfo["count"] = simCount
    }
    
    return simInfo
}

/* Jailbreak Detection (remove software restrictions) */
func isDeviceJailbroken() -> Bool {
#if arch(i386) || arch(x86_64)
    // This is a simulator not an actual device
    return false
#else
    // Check for files that are common on jailbroken devices
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: "/Applications/Cydia.app") ||
        fileManager.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib") ||
        fileManager.fileExists(atPath: "/bin/bash") ||
        fileManager.fileExists(atPath: "/usr/sbin/sshd") ||
        fileManager.fileExists(atPath: "/etc/apt") {
        return true
    }
    // Check if the app can write to /private
    let stringToWrite = "Jailbreak Test"
    do {
        try stringToWrite.write(toFile: "/private/jailbreak.txt", atomically: true, encoding: String.Encoding.utf8)
        // The device is jailbroken
        return true
    } catch {
        return false
    }
#endif
}

/* Frida Detection */

func isSuspiciousLibraryLoaded() -> Bool {
    let suspiciousKeywords = ["frida", "gadget", "agent", "libinjector", "cynject", "libcycript"]
    
    for i in 0..<_dyld_image_count() {
        if let imageName = _dyld_get_image_name(i) {
            let imageNameStr = String(cString: imageName).lowercased()
            for keyword in suspiciousKeywords {
                if imageNameStr.contains(keyword) {
                    return true
                }
            }
        }
    }
    return false
}

func isFridaPortOpen() -> Bool {
    let ports: [Network.NWEndpoint.Port] = [27042, 27043]
    let host = Network.NWEndpoint.Host("127.0.0.1")
    
    for port in ports {
        let connection = Network.NWConnection(host: host, port: port, using: .tcp)
        var isPortOpen = false
        
        let semaphore = DispatchSemaphore(value: 0)
        connection.stateUpdateHandler = { state in
            switch state {
            case .ready:
                isPortOpen = true
                semaphore.signal()
            case .failed(_):
                semaphore.signal()
            default:
                break
            }
        }
        
        connection.start(queue: .global())
        _ = semaphore.wait(timeout: .now() + 1)
        
        if isPortOpen {
            return true
        }
    }
    
    return false
}

func isFridaSymbolLoaded() -> Bool {
    let suspiciousSymbols = ["_frida_get_api_version", "frida_agent_main"]
    
    for symbol in suspiciousSymbols {
        if dlsym(UnsafeMutableRawPointer(bitPattern: -2), symbol) != nil {
            return true
        }
    }
    return false
}

func isFridaRunning() -> Bool {
    return isSuspiciousLibraryLoaded() || isFridaPortOpen() || isFridaSymbolLoaded()
}


/* Factory Reset Detection */

func isDeviceReset() -> String? {
    if let provisioningTime = Bundle.main.infoDictionary?["DTProvisioningTime"] as? TimeInterval {
        let date = Date(timeIntervalSince1970: provisioningTime)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let provisioningDateString = formatter.string(from: date)
        return "Approximate Factory Reset Time: \(provisioningDateString)"
    } else {
        return nil
    }
}

func getFirstInstallDate() -> Date? {
    if let libraryDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: libraryDirectory.path)
            if let creationDate = attributes[.creationDate] as? Date {
                return creationDate
            }
        } catch {
        }
    }
    return nil
}


func getFirstLaunchDate() -> Date {
    let userDefaults = UserDefaults.standard
    let firstLaunchKey = "firstLaunchDate"
    
    if let firstLaunchDate = userDefaults.object(forKey: firstLaunchKey) as? Date {
        // Return the stored first launch date
        return firstLaunchDate
    } else {
        // Store the current date as the first launch date
        let firstLaunchDate = Date()
        userDefaults.set(firstLaunchDate, forKey: firstLaunchKey)
        return firstLaunchDate
    }
}

/* VPN Detection */
func isVPNConnected() -> [String: Any] {
    var result: [String: Any] = [
        "auxiliary" : false
    ]
    let cfDict = CFNetworkCopySystemProxySettings()
    let nsDict = cfDict?.takeRetainedValue() as NSDictionary?
    let keys = nsDict?["__SCOPED__"] as? NSDictionary
    
    for key in keys?.allKeys as? [String] ?? [] {
        if (key.contains("tap") || key.contains("tun") || key.contains("ppp") || key.contains("ipsec") || key.contains("utun")) {
            result["auxiliary"] = true
            return result
        }
    }
    
    return result
}

/* Developer Mode */
//func isBeingDebugged() -> Bool {
//    var info = kinfo_proc()
//    var mib = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
//    var size = MemoryLayout<kinfo_proc>.stride
//
//    let sysctlResult = sysctl(&mib, u_int(mib.count), &info, &size, nil, 0)
//    assert(sysctlResult == 0, "sysctl failed")
//
//    return (info.kp_proc.p_flag & P_TRACED) != 0
//}

func isLikelyDeveloperMode() -> Bool {
    return isDeveloperProvisioned() || isBeingDebugged()
}

func isBeingDebugged() -> Bool {
    var info = kinfo_proc()
    var size = MemoryLayout.stride(ofValue: info)
    var name: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
    
    let result = sysctl(&name, u_int(name.count), &info, &size, nil, 0)
    if result != 0 {
        return false
    }
    
    return (info.kp_proc.p_flag & P_TRACED) != 0
}


func isDeveloperProvisioned() -> Bool {
    guard let path = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision"),
          let _ = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
        return false
    }
    return true
}

func getSIMCount() -> Int {
    let networkInfo = CTTelephonyNetworkInfo()
    if let carriers = networkInfo.serviceSubscriberCellularProviders {
        // Filter out nil or inactive carriers
        let activeSIMs = carriers.filter { $0.value.mobileNetworkCode != nil }
        return activeSIMs.count
    }
    return 0
}

extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}


func getNetwork() -> String {
    let networkInfo = CTTelephonyNetworkInfo()
    guard let currentRadioTech = networkInfo.serviceCurrentRadioAccessTechnology?.values.first else {
        return "Unknown"
    }
    
    if #available(iOS 14.1, *) {
        switch currentRadioTech {
        case CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyGPRS:
            return "2G"
        case CTRadioAccessTechnologyWCDMA, CTRadioAccessTechnologyHSDPA, CTRadioAccessTechnologyHSUPA,
            CTRadioAccessTechnologyCDMA1x, CTRadioAccessTechnologyCDMAEVDORev0, CTRadioAccessTechnologyCDMAEVDORevA, CTRadioAccessTechnologyCDMAEVDORevB:
            return "3G"
        case CTRadioAccessTechnologyLTE:
            return "4G LTE"
        case CTRadioAccessTechnologyNRNSA, CTRadioAccessTechnologyNR:
            return "5G"
        default:
            return "Unknown"
        }
    } else {
        // Fallback on earlier versions
    }
    return "Unknown"
}

func getNetworkName(completion: @escaping (String) -> Void) {
    // 1. Check for Wi-Fi
    if isWiFiConnected() {
        if let ssid = getWiFiSSID(), isMobileHotspot(ssid: ssid) {
            completion("Mobile Hotspot")
            return
        } else {
            completion("Wi-Fi")
            return
        }
    }
    
    // 2. Check for Ethernet (Wired Connection)
    if isEthernetConnected() {
        completion("Ethernet (Wired)")
        return
    }
    
    // 3. Check for Cellular (4G/5G)
    if let cellularInfo = getCellularNetworkType() {
        completion(cellularInfo)
        return
    }
    
    // If no connection type was detected
    completion("No Network")
}

private func isWiFiConnected() -> Bool {
    let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
    var isConnected = false
    let semaphore = DispatchSemaphore(value: 0)
    
    monitor.pathUpdateHandler = { path in
        if path.status == .satisfied && path.usesInterfaceType(.wifi) {
            isConnected = true
        }
        semaphore.signal()
    }
    
    let queue = DispatchQueue(label: "MonitorQueue")
    monitor.start(queue: queue)
    semaphore.wait()
    
    return isConnected
}

private func isEthernetConnected() -> Bool {
    let monitor = NWPathMonitor(requiredInterfaceType: .wiredEthernet)
    var isConnected = false
    let semaphore = DispatchSemaphore(value: 0)
    
    monitor.pathUpdateHandler = { path in
        if path.status == .satisfied && path.usesInterfaceType(.wiredEthernet) {
            isConnected = true
        }
        semaphore.signal()
    }
    
    let queue = DispatchQueue(label: "MonitorQueue")
    monitor.start(queue: queue)
    semaphore.wait()
    
    return isConnected
}

private func getCellularNetworkType() -> String? {
    let networkInfo = CTTelephonyNetworkInfo()

    if let serviceRadioAccessTechnology = networkInfo.serviceCurrentRadioAccessTechnology {
        for (_, radioAccessTechnology) in serviceRadioAccessTechnology {
            return mapRadioAccessTechnologyToNetworkType(radioAccessTechnology)
        }
    }
    return "Unknown Cellular"
}

private func mapRadioAccessTechnologyToNetworkType(_ technology: String) -> String {
    if #available(iOS 14.1, *) {
        switch technology {
        case CTRadioAccessTechnologyNRNSA, CTRadioAccessTechnologyNR:
            return "5G"
        case CTRadioAccessTechnologyLTE:
            return "4G"
        case CTRadioAccessTechnologyWCDMA, CTRadioAccessTechnologyHSDPA, CTRadioAccessTechnologyHSUPA,
             CTRadioAccessTechnologyCDMA1x, CTRadioAccessTechnologyCDMAEVDORev0,
             CTRadioAccessTechnologyCDMAEVDORevA, CTRadioAccessTechnologyCDMAEVDORevB:
            return "3G"
        case CTRadioAccessTechnologyGPRS, CTRadioAccessTechnologyEdge:
            return "2G"
        default:
            return "Unknown Cellular"
        }
    } else {
        switch technology {
        case CTRadioAccessTechnologyLTE:
            return "4G"
        case CTRadioAccessTechnologyWCDMA, CTRadioAccessTechnologyHSDPA, CTRadioAccessTechnologyHSUPA,
             CTRadioAccessTechnologyCDMA1x, CTRadioAccessTechnologyCDMAEVDORev0,
             CTRadioAccessTechnologyCDMAEVDORevA, CTRadioAccessTechnologyCDMAEVDORevB:
            return "3G"
        case CTRadioAccessTechnologyGPRS, CTRadioAccessTechnologyEdge:
            return "2G"
        default:
            return "Unknown Cellular"
        }
    }
}

private func getWiFiSSID() -> String? {
    // Retrieve the SSID of the connected Wi-Fi network (this works only if you have permissions)
    if let interfaces = CNCopySupportedInterfaces() as? [String] {
        for interface in interfaces {
            if let info = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any] {
                return info["SSID"] as? String
            }
        }
    }
    return nil
}

private func isMobileHotspot(ssid: String) -> Bool {
    let hotspotIdentifiers = [
        "iPhone",
        "Android Hotspot",
        "My Mobile Hotspot",
        "Mobile Hotspot"
    ]
    
    // If the SSID matches one of the hotspot names, consider it as a mobile hotspot
    return hotspotIdentifiers.contains(where: { ssid.contains($0) })
}

// Global result list
var resultList: [[String: Bool]] = []
let localPackageList: [(packageName: String, packageCode: String)] = [
    ("WhatsApp", "whatsapp"),
    ("PhonePe", "phonepe"),
    ("Tez", "tez"),
    ("Cred", "cred"),
    ("SuperMoney", "supermoney")
]

func getInstalledAppsFromLocalList(completion: @escaping ([[String: Bool]]) -> Void) {
    let installedApps = checkInstalledApps(packageList: localPackageList)

    var updatedList: [[String: Bool]] = []
    for (packageName, isInstalled) in installedApps {
        updatedList.append([packageName: isInstalled])
    }

    resultList = updatedList
    completion(updatedList)
}

func checkInstalledApps(packageList: [(packageName: String, packageCode: String)]) -> [String: Bool] {
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


class ScreenMirroringDetector {
    
    static func isScreenMirroringActive() -> Bool {
        let screens = UIScreen.screens
        
        if screens.count > 1 {
            return true
        }
        
        if let mainScreen = screens.first, mainScreen.mirrored != nil {
                return true
            }
        
        return false
    }
}

