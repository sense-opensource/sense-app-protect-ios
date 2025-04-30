

import UIKit
import SenseOSProtect

@available(iOS 13.0, *)
class SenseController: UIViewController,SenseOSProtectDelegate {
    @IBOutlet weak var btnSubmit: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func btnSubmit(_ sender: Any) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
        }
        
    }
    
    func onFailure(message: String) {
        DispatchQueue.main.async {
            
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func onSuccess(data: String) {
        DispatchQueue.main.async {
            
            let encodedString = "\(data)"
            
            if self.beautifyJSON(encodedString) != nil {
                
            }
        }
    }
    
    func beautifyJSON(_ jsonString: String) -> String? {
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                
                let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
                let prettyPrintedData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                let prettyPrintedString = String(data: prettyPrintedData, encoding: .utf8)
                return prettyPrintedString
            } catch {
                print("Error beautifying JSON: \(error.localizedDescription)")
                return nil
            }
        }
        
        return nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
}
