//
//  LayersButton.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 01.11.2023.
//

import UIKit

final class LayersButton: SaliButton<CALayer, CGColor?> {
    
    // MARK: Private Properties
    private let constants = Constants()
    
    // MARK: Visual Components
    private lazy var backgroundLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.buttons.cgColor
        
        return layer
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12.0)
        label.textColor = .text
        label.textAlignment = .center
        label.numberOfLines = 1
        label.text = "Layers"
        
        return label
    }()
    
    private lazy var chevronLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.clear.cgColor
        layer.backgroundColor = UIColor.clear.cgColor
        layer.fillColor = UIColor.text.cgColor
        layer.path = UIBezierPath.makeChevronDown(size: constants.iconSize).cgPath
        
        return layer
    }()
    
    // MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews()
        setupBackgroundAnimation()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    // MARK: UIView
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundLayer.frame = bounds
        
        label.sizeToFit()
        label.frame.origin = CGPoint(
            x: bounds.minX + constants.horizontalInset,
            y: bounds.midY - label.bounds.height / 2.0
        )
        
        chevronLayer.frame = CGRect(
            x: label.frame.maxX + constants.labelIconSpacing,
            y: bounds.midY - constants.iconSize.height / 2.0,
            width: constants.iconSize.width,
            height: constants.iconSize.height
        )
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let labelSize = label.sizeThatFits(size)
        let height = size.height
        
        let width = constants.horizontalInset * 2 + labelSize.width + constants.labelIconSpacing + constants.iconSize.width
        
        return CGSize(width: width, height: height)
    }
}

// MARK: - Private Methods
extension LayersButton {
    private func addSubviews() {
        layer.addSublayer(backgroundLayer)
        addSubview(label)
        layer.addSublayer(chevronLayer)
    }
    
    private func setupBackgroundAnimation() {
        animationDescriptor = .init(
            layer: backgroundLayer,
            property: \.backgroundColor,
            inactiveValue: UIColor.buttons.cgColor,
            activeValue: UIColor.accent.cgColor
        )
    }
}

// MARK: - Constants
extension LayersButton {
    private struct Constants {
        let horizontalInset: CGFloat = 10.0
        let labelIconSpacing: CGFloat = 16.0
        let iconSize = CGSize(width: 9.0, height: 4.0)
    }
}
