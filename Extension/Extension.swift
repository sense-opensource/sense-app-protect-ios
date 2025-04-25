

import UIKit

extension UIView {
    
    /// Applies border and shadow styling to a UIView
    func applyBorderAndShadow(
        borderWidth: CGFloat = 0.5,
        borderColor: UIColor = .lightGray,
        cornerRadius: CGFloat = 0,
        shadowColor: UIColor = .lightGray,
        shadowOpacity: Float = 0.1,
        shadowOffset: CGSize = CGSize(width: 1, height: 1),
        shadowRadius: CGFloat = 4
    ) {
        // Border properties
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.layer.cornerRadius = cornerRadius
        
        // Shadow properties
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowRadius = shadowRadius

        // Ensure shadow is visible outside of view's bounds
        self.layer.masksToBounds = false
    }
}


extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
