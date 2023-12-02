//
//  PlayStopButton.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 01.11.2023.
//

import UIKit

class PlayStopButton: IconSaliButton<CAShapeLayer, CGPath?> {
    
    // MARK: Visual Components
    private(set) lazy var playStopIconLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.clear.cgColor
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
        
        let minimalSide = min(bounds.width, bounds.height)
        let iconSide = minimalSide * constants.iconWidthRatio
        
        let playIconSize = CGSize(width: iconSide, height: iconSide)
        let playIconOrigin = CGPoint(
            x: bounds.midX - playIconSize.width / 2,
            y: bounds.midY - playIconSize.height / 2
        )
        
        playStopIconLayer.frame = CGRect(origin: playIconOrigin, size: playIconSize)
        
        let inactivePath: UIBezierPath = .makePlayIcon(size: iconSide)
        let activePath: UIBezierPath = .makeStopIcon(size: iconSide)
        
        animationDescriptor = .init(
            layer: playStopIconLayer,
            property: \.path,
            inactiveValue: inactivePath.cgPath,
            activeValue: activePath.cgPath
        )
        
        if isActive {
            playStopIconLayer.path = activePath.cgPath
        } else {
            playStopIconLayer.path = inactivePath.cgPath
        }
    }
}

// MARK: - Private Methods
extension PlayStopButton {
    private func addSubviews() {
        layer.addSublayer(playStopIconLayer)
    }
}
