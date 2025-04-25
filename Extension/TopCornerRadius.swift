


import UIKit

extension UIView {
    /// Round specific corners with a border color and width
    func roundCornersWithBorder(
        corners: UIRectCorner,
        radius: CGFloat,
        borderColor: UIColor,
        borderWidth: CGFloat
    ) {
        // Ensure the layout is correctly set before applying the mask
        self.layoutIfNeeded()

        // Create the rounded corner path
        let path = UIBezierPath(
            roundedRect: self.bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )

        // Apply the mask to round the specified corners
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask

        // Create a border layer
        let borderLayer = CAShapeLayer()
        borderLayer.path = path.cgPath
        borderLayer.fillColor = UIColor.clear.cgColor  // Transparent fill
        borderLayer.strokeColor = borderColor.cgColor  // Border color
        borderLayer.lineWidth = borderWidth  // Border width
        borderLayer.frame = self.bounds

        // Remove existing border layer to avoid duplications
        self.layer.sublayers?.removeAll { $0 is CAShapeLayer }

        // Add the border layer as a sublayer
        self.layer.addSublayer(borderLayer)
    }
}

