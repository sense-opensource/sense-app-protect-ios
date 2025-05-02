<h1>Sense App Protect iOS</h1>

<p width="100%">
    <a href="https://github.com/sense-opensource/sense-app-protect-ios/blob/main/LICENSE"> 
        <img width="9%" src="https://custom-icon-badges.demolab.com/github/license/denvercoder1/custom-icon-badges?logo=law">
    </a>
    <img width="12.6%" src="https://badge-generator.vercel.app/api?icon=Github&label=Last%20Commit&status=May&color=6941C6"/> 
    <a href="https://discord.gg/hzNHTpwt">
        <img width="10%" src="https://badge-generator.vercel.app/api?icon=Discord&label=Discord&status=Live&color=6941C6"> 
    </a>
</p>

<h2>Welcome to Sense’s open source repository</h2>

<p width="100%">  
<img width="4.5%" src="https://custom-icon-badges.demolab.com/badge/Fork-orange.svg?logo=fork"> 
<img width="4.5%" src="https://custom-icon-badges.demolab.com/badge/Star-yellow.svg?logo=star"> 
<img width="6.5%" src="https://custom-icon-badges.demolab.com/badge/Commit-green.svg?logo=git-commit&logoColor=fff"> 
</p>

### 🛡️ Device Integrity Checks

![Frida](https://img.shields.io/badge/Frida-blue)
![Simulator](https://img.shields.io/badge/Simulator-orange)
![Installed Apps](https://img.shields.io/badge/Installed_Apps-yellow)
![VPN](https://img.shields.io/badge/VPN-lightblue)
![SIM](https://img.shields.io/badge/SIM-lightgreen)
![Factory Reset](https://img.shields.io/badge/Factory_Reset-darkgreen)
![Remote Control](https://img.shields.io/badge/Remote_Control-darkblue)

<h3>Getting started with Sense </h3>

Sense is a device intelligence and identification tool. This tool collects a comprehensive set of attributes unique to a device or browser, forming an identity that will help businesses.

<h3>Requirements</h3>

* OS 12.0 or above.
* Swift version 5.0 and above


Note: If the application does not have the listed permissions, the values collected using those permissions will be ignored. To provide a valid device details, we recommend employing as much permission as possible based on your use-case.

 Step 1 - Import SDK
 ```
 import SenseOSProtect
```

 Step 2 - Add Delegate Method

 Add the delegate method in your Controller Class file.
```
 SenseOSProtectDelegate
```
 Step 3 - Get Device Details

Use the line below to invoke any button action or ViewDidLoad to get the DeviceDetails
```
let localPackageList: [(packageName: String, packageCode: String)] = [
                    (“Package Name”, “Package Code”)]        
        let config = SenseOSProtectConfig(installedAppList: localPackageList)
        SenseOSProtect.initSDK(senseConfig: config, withDelegate: self)
        SenseOSProtect.getSenseDetails(withDelegate: self)
```
 Step 4 - Add your plist file
 
Add the bundle identifier name in your plist file, whatever you want.
```
	<key>LSApplicationQueriesSchemes</key>
	<array>
		<string>whatsapp</string>
		<string>tez</string>
		<string>phonepe</string>
		<string>cred</string>
		<string>supermoney</string>
	</array>
```
 Step 5 - Implement Delegate Method

 Set and Implement our Delegate method to receive the Callback details

```
 extension ViewController: SenseOSProtectDelegate{
    func onFailure(message: String) {
        // Failure Callback.
    }
    func onSuccess(data: [String : Any]) {
        // Success Callback
    }
}
```
 Sample Program

Here you can find the demonstration to do the integration.
```
import UIKit
import SenseOSProtect

class SenseOSController: UIViewController, SenseOSProtectDelegate {

  override func viewDidLoad() {
      super.viewDidLoad()
      let localPackageList: [(packageName: String, packageCode: String)] = [
                    (“Package Name”, “Package Code”)]      
        let config = SenseOSProtectConfig(installedAppList: localPackageList)
        SenseOSProtect.initSDK(senseConfig: config, withDelegate: self)
        SenseOSProtect.getSenseDetails(withDelegate: self)
  }
  @objc func onSuccess(data: String) {     
      // Handle success callback
  }
  @objc func onFailure(message: String) {
      // Handle failure callback
  }

}
 ```

<h4>Plug and play, in just 4 steps</h3>  

1️⃣ Visit the GitHub Repository</br>
2️⃣ Download or Clone the Repository. Use the GitHub interface to download the ZIP file, or run.</br>
3️⃣ Run the Installer / Setup Script. Follow the setup instructions provided below.</br>
4️⃣ Start Testing. Once installed, begin testing and validating the accuracy of the metrics you're interested in.</br>

#### With Sense, you can  

✅ Predict user intent : Identify the good from the bad visitors with precision  
✅ Create user identities : Tokenise events with a particular user and device  
✅ Custom risk signals : Developer specific scripts that perform unique functions  
✅ Protect against Identity spoofing : Prevent users from impersonation  
✅ Stop device or browser manipulation : Detect user behaviour anomalies 


#### MIT license : 

Sense OS is available under the <a href="https://github.com/sense-opensource/sense-app-protect-ios/blob/main/LICENSE"> MIT license </a>

#### Contributors code of conduct : 

Thank you for your interest in contributing to this project! We welcome all contributions and are excited to have you join our community. Please read these <a href="https://github.com/sense-opensource/sense-app-protect-ios/blob/main/code_of_conduct.md"> code of conduct </a> to ensure a smooth collaboration.

#### Where you can get support :     
![Gmail](https://img.shields.io/badge/Gmail-D14836?logo=gmail&logoColor=white)       product@getsense.co 

Public Support:

For questions, bug reports, or feature requests, please use the Issues and Discussions sections on our repository. This helps the entire community benefit from shared knowledge and solutions.

Community Chat:

Join our Discord server (link) to connect with other developers, ask questions in real-time, and share your feedback on Sense.

Interested in contributing to Sense?

Please review our <a href="https://github.com/sense-opensource/sense-app-protect-ios/blob/main/CONTRIBUTING.md"> Contribution Guidelines </a> to learn how to get started, submit pull requests, or run the project locally. We encourage you to read these guidelines carefully before making any contributions. Your input helps us make Sense better for everyone!
