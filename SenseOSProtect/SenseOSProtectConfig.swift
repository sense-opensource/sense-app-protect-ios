

import Foundation

public class SenseOSProtectConfig {
    public var installedAppList: [(packageName: String, packageCode: String)]

       public init(installedAppList: [(packageName: String, packageCode: String)]) {
           self.installedAppList = installedAppList
       }
    
}

