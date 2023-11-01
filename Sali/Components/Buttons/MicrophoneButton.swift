//
//  MicrophoneButton.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 01.11.2023.
//

import UIKit

final class MicrophoneButton: SaliButton<CALayer, Double> {
    
    // MARK: Visual Components
    private lazy var microphoneIconLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.clear.cgColor
        layer.backgroundColor = UIColor.clear.cgColor
        layer.fillColor = UIColor.icons.cgColor
        
        return layer
    }()
    
    // MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    // MARK: UIView
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let iconWidth = bounds.width * constants.iconWidthRatio
        let iconPath: UIBezierPath = .makeMicrophoneIcon(width: iconWidth)
        
        microphoneIconLayer.frame = CGRect(
            x: bounds.midX - iconPath.bounds.width / 2,
            y: bounds.midY - iconPath.bounds.height / 2,
            width: iconPath.bounds.width,
            height: iconPath.bounds.height
        )
        
        microphoneIconLayer.path = iconPath.cgPath
    }
}

// MARK: - Private Methods
extension MicrophoneButton {
    private func addSubviews() {
        layer.addSublayer(microphoneIconLayer)
    }
}
