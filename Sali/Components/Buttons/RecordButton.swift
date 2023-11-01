//
//  RecordButton.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 01.11.2023.
//

import UIKit

final class RecordButton: SaliButton<CAShapeLayer, CGColor?> {
    
    // MARK: Visual Components
    private lazy var recordIconLayer: CAShapeLayer = {
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
        setupAnimaiton()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    // MARK: UIView
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let minimalSide = min(bounds.width, bounds.height)
        let iconSide = minimalSide * constants.iconWidthRatio
        
        let recordIconSize = CGSize(width: iconSide, height: iconSide)
        let recordIconOrigin = CGPoint(
            x: bounds.midX - recordIconSize.width / 2,
            y: bounds.midY - recordIconSize.height / 2
        )
        
        recordIconLayer.frame = CGRect(origin: recordIconOrigin, size: recordIconSize)
        recordIconLayer.path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: recordIconSize)).cgPath
    }
}

// MARK: - Private Methods
extension RecordButton {
    private func addSubviews() {
        layer.addSublayer(recordIconLayer)
    }
    
    private func setupAnimaiton() {
        animationDescriptor = AnimationDescriptor(
            layer: recordIconLayer,
            property: \.fillColor,
            inactiveValue: UIColor.icons.cgColor,
            activeValue: UIColor.record.cgColor
        )
    }
}
