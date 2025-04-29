

import UIKit
import SenseAppProtect_Demo

class HomeController: UIViewController, SenseOSDelegate {

    @IBOutlet weak var installedAppViewHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var imgVPN: UIImageView!
    @IBOutlet weak var imgSimulator: UIImageView!
    @IBOutlet weak var imgJailbreak: UIImageView!
    @IBOutlet weak var installStackView: NSLayoutConstraint!
    @IBOutlet weak var viewInstallStack: NSLayoutConstraint!
    @IBOutlet weak var simStackView: UIStackView!
    @IBOutlet weak var installedAppsStackView: UIStackView!
    @IBOutlet weak var viewVPN: UIView!
    @IBOutlet weak var viewImgVPN: UIView!
    @IBOutlet weak var lblDevMode: UILabel!
    @IBOutlet weak var viewDevImage: UIView!
    @IBOutlet weak var ImgCircle: UIImageView!
    @IBOutlet weak var lblVPN: UILabel!
    @IBOutlet weak var viewImgDevMode: UIView!
    @IBOutlet weak var viewDevMode: UIView!
    @IBOutlet weak var lblSimulator: UILabel!
    @IBOutlet weak var viewImgSimulator: UIView!
    @IBOutlet weak var viewInstalledApps: UIView!
    @IBOutlet weak var imgFrida: UIImageView!
    @IBOutlet weak var lblFrida: UILabel!
    @IBOutlet weak var viewImgFrida: UIView!
    @IBOutlet weak var viewFrida: UIView!
    @IBOutlet weak var viewSimulator: UIView!
    @IBOutlet weak var lblJailbreak: UILabel!
    @IBOutlet weak var viewImageJailbreak: UIView!
    @IBOutlet weak var viewJailbreak: UIView!
    @IBOutlet weak var viewAdditional: UIView!
    @IBOutlet weak var viewDetection: UIView!
    @IBOutlet weak var viewDetails: UIView!
    @IBOutlet weak var viewSmartSignals: UIView!
    @IBOutlet weak var viewSenseProduct: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SenseOS.getSenseDetails(withDelegate: self)
        
        viewJailbreak.layer.borderColor = UIColor(hex: "#12B76A").cgColor
        viewJailbreak.layer.borderWidth = 1
        viewFrida.layer.borderColor = UIColor(hex: "#12B76A").cgColor
        viewFrida.layer.borderWidth = 1
        viewSimulator.layer.borderColor = UIColor(hex: "#12B76A").cgColor
        viewSimulator.layer.borderWidth = 1
        viewDevMode.layer.borderColor = UIColor(hex: "#12B76A").cgColor
        viewDevMode.layer.borderWidth = 1
        viewImgVPN.layer.borderColor = UIColor(hex: "#12B76A").cgColor
        viewImgVPN.layer.borderWidth = 1
        
//        installStackView = installedAppsStackView.heightAnchor.constraint(equalToConstant: 100) // default
//        installStackView?.isActive = true
//        viewInstallStack = installedAppsStackView.heightAnchor.constraint(equalToConstant: 100) // default
//        viewInstallStack?.isActive = true

        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
            self.navigationController?.pushViewController(tabBarController, animated: true)
        }
        
        viewSenseProduct.applyBorderAndShadow(borderWidth: 0.3, borderColor: UIColor.lightGray, cornerRadius: 10)
        viewSmartSignals.roundCornersWithBorder(
            corners: [.topLeft, .topRight],radius: 10,borderColor: .lightGray,borderWidth: 0.5
        )
        viewAdditional.roundCornersWithBorder(
            corners: [.bottomLeft, .bottomRight],radius: 10,borderColor: .lightGray,borderWidth: 0.5
        )
    }
    
    func onFailure(message: String) {
        
    }
    
    func onSuccess(data: String) {
        guard let jsonData = data.data(using: .utf8) else {
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
               let str = json["str"] as? [String: Any],
               let detection = str["detection"] as? [String: Any] {
                
                            let isFrida = detection["isFrida"] as? Bool ?? false
                            let isJailbroken = detection["isJailbroken"] as? Bool ?? false
                            let developerMode = detection["developerModeEnabled"] as? Bool ?? false
                            let isSimulator = detection["isSimulator"] as? Bool ?? false
                            
                            let vpnInfo = detection["vpn"] as? [String: Any]
                            let isVpnAuxiliary = vpnInfo?["auxiliary"] as? Bool ?? false
                            
                            let simInfo = detection["sim"] as? [String: Any]
                            let sim1Present = simInfo?["sim1Present"] as? Bool ?? false
                            let sim2Present = simInfo?["sim2Present"] as? Bool ?? false
                            let simCount = simInfo?["count"] as? Int ?? 0
                            
                            let installedApps = detection["installedApps"] as? [[String: Bool]] ?? []
                            for appStatus in installedApps {
                                if let appName = appStatus.keys.first,
                                   let isInstalled = appStatus[appName] {
                                }
                            }
                
                DispatchQueue.main.async {
                    self.rootLabelFunction(
                        jailBreak: isJailbroken,
                        Frida: isFrida,
                        Simulator: isSimulator,
                        DeveloperMode: developerMode,
                        Vpn: isVpnAuxiliary
                    )
                    self.updateInstalledAppsList(installedApps)
                    self.updateSimDetails(
                        sim1Present: sim1Present,
                        sim2Present: sim2Present,
                        simCount: simCount
                    )
                }
            }
        } catch {
          //  print("Error decoding JSON: \(error.localizedDescription)")
        }
    }


    func updateInstalledAppsList(_ installedApps: [[String: Bool]]) {
        installedAppsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        var hasInstalledApp = false

        for appStatus in installedApps {
            if let appName = appStatus.keys.first,
               let isInstalled = appStatus[appName], isInstalled {
                
                hasInstalledApp = true

                let label = PaddedLabel()
                label.text = appName
                label.font = UIFont.systemFont(ofSize: 14)
                label.textColor = .darkText
                label.backgroundColor = UIColor(hex: "#ABEFC6")
                label.layer.borderColor = UIColor(hex: "#12B76A").cgColor
                label.layer.borderWidth = 1
                label.layer.cornerRadius = 6
                label.layer.masksToBounds = true
                
                installedAppsStackView.addArrangedSubview(label)
            }
        }

        if !hasInstalledApp {
            let label = PaddedLabel()
            label.text = "-"
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = .gray
         //   label.backgroundColor = UIColor(hex: "#F2F4F7")
//            label.layer.borderColor = UIColor.gray.cgColor
//            label.layer.borderWidth = 1
//            label.layer.cornerRadius = 6
//            label.layer.masksToBounds = true
            
            installedAppsStackView.addArrangedSubview(label)
            installedAppViewHeightConstant.constant = 50
            viewInstallStack?.constant = 30
            installStackView?.constant = 30
        } else {
            installedAppViewHeightConstant.constant = 150
            viewInstallStack?.constant = 128
            installStackView?.constant = 128
        }
    }



    
    func updateSimDetails(sim1Present: Bool, sim2Present: Bool, simCount: Int) {
        simStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let sim1Status = sim1Present ? "SIM 1: Present" : "SIM 1: Not Present"
        let sim2Status = sim2Present ? "SIM 2: Present" : "SIM 2: Not Present"
        let simCountText = "SIM Count: \(simCount)"

        simStackView.addArrangedSubview(createBorderedLabel(text: sim1Status))
        simStackView.addArrangedSubview(createBorderedLabel(text: sim2Status))
        simStackView.addArrangedSubview(createBorderedLabel(text: simCountText))
    }

    func createBorderedLabel(text: String) -> UILabel {
        let label = PaddedLabel()
        label.text = text
        label.textColor = UIColor(hex: "#344054")
        label.layer.borderColor = UIColor(hex: "#12B76A").cgColor
        label.backgroundColor = UIColor(hex: "#ABEFC6")
        label.layer.borderWidth = 1
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }
    
    class PaddedLabel: UILabel {
        var contentInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)

        override func drawText(in rect: CGRect) {
            super.drawText(in: rect.inset(by: contentInsets))
        }

        override var intrinsicContentSize: CGSize {
            let size = super.intrinsicContentSize
            return CGSize(width: size.width + contentInsets.left + contentInsets.right,
                          height: size.height + contentInsets.top + contentInsets.bottom)
        }
    }
    
    func rootLabelFunction(jailBreak: Bool, Frida: Bool, Simulator: Bool, DeveloperMode: Bool, Vpn: Bool) {
        
        if jailBreak {
            if #available(iOS 13.0, *) {
                self.imgJailbreak.image = UIImage(systemName: "checkmark.circle")
            } else {
            }
            self.imgJailbreak.tintColor =  UIColor(hex: "#B42318")
            self.viewJailbreak.backgroundColor = UIColor(hex: "#FECDCA")
            self.viewJailbreak.tintColor =  UIColor(hex: "#B42318")
            self.imgJailbreak.backgroundColor =  UIColor(hex: "#FECDCA")
            self.lblJailbreak.text = "Detected  "
            self.lblJailbreak.textColor = UIColor(hex: "#B42318")
            self.viewJailbreak.layer.borderColor = UIColor(hex: "#B42318").cgColor
            self.viewJailbreak.layer.borderWidth = 1
        } else {
            
        }
        
        if Frida {
            if #available(iOS 13.0, *) {
                self.imgFrida.image = UIImage(systemName: "checkmark.circle")
            } else {
            }
            self.imgFrida.tintColor =  UIColor(hex: "#B42318")
            self.viewFrida.backgroundColor = UIColor(hex: "#FECDCA")
            self.viewImgFrida.tintColor =  UIColor(hex: "#B42318")
            self.imgFrida.backgroundColor =  UIColor(hex: "#FECDCA")
            self.lblFrida.text = "Detected  "
            self.lblFrida.textColor = UIColor(hex: "#B42318")
            self.viewFrida.layer.borderColor = UIColor(hex: "#B42318").cgColor
            self.viewFrida.layer.borderWidth = 1
        } else {
            
        }
        
        if Simulator {
            if #available(iOS 13.0, *) {
                self.imgSimulator.image = UIImage(systemName: "checkmark.circle")
            } else {
            }
            self.imgSimulator.tintColor =  UIColor(hex: "#B42318")
            self.viewSimulator.backgroundColor = UIColor(hex: "#FECDCA")
            self.viewImgSimulator.tintColor =  UIColor(hex: "#B42318")
            self.imgSimulator.backgroundColor =  UIColor(hex: "#FECDCA")
            self.lblSimulator.text = "Detected  "
            self.lblSimulator.textColor = UIColor(hex: "#B42318")
            self.viewSimulator.layer.borderColor = UIColor(hex: "#B42318").cgColor
            self.viewSimulator.layer.borderWidth = 1
        } else {
            
        }
        
        if DeveloperMode {
            self.viewDevMode.backgroundColor = UIColor(hex: "#FECDCA")
            if #available(iOS 13.0, *) {
                self.ImgCircle.image = UIImage(systemName: "checkmark.circle")
            } else {
            }
            self.ImgCircle.tintColor =  UIColor(hex: "#B42318")
            self.ImgCircle.backgroundColor =  UIColor(hex: "#FECDCA")
            self.viewImgDevMode.backgroundColor =  UIColor(hex: "#FECDCA")
            self.lblDevMode.text = "Detected  "
            self.lblDevMode.textColor = UIColor(hex: "#B42318")
            self.viewDevMode.layer.borderColor = UIColor(hex: "#B42318").cgColor
            self.viewDevMode.layer.borderWidth = 1
        } else {
            
        }
        
        if Vpn {
            if #available(iOS 13.0, *) {
                self.imgVPN.image = UIImage(systemName: "checkmark.circle")
            } else {
            }
            self.imgVPN.tintColor =  UIColor(hex: "#B42318")
            self.viewImgVPN.backgroundColor = UIColor(hex: "#FECDCA")
            self.viewImgVPN.tintColor =  UIColor(hex: "#B42318")
            self.imgVPN.backgroundColor =  UIColor(hex: "#FECDCA")
            self.lblVPN.text = "Detected  "
            self.lblVPN.textColor = UIColor(hex: "#B42318")
            self.viewImgVPN.layer.borderColor = UIColor(hex: "#B42318").cgColor
            self.viewImgVPN.layer.borderWidth = 1
        } else {
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
}
