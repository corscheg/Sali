//
//  SoundControl.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 01.11.2023.
//

import UIKit

final class SoundControl: UIControl {
    
    // MARK: Private Properties
    private let constants = Constants()
    
    // MARK: Visual Components
    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.locations = [0, 1]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.colors = [UIColor.clear.cgColor, UIColor.field.cgColor]
        
        return layer
    }()
    
    private lazy var volumeScaleView = VolumeScaleView(units: 5, subunits: 5)
    
    // MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIView
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
        
        volumeScaleView.frame = CGRect(
            x: bounds.minX,
            y: bounds.minY,
            width: constants.volumeScaleWidth,
            height: bounds.height - constants.volumeScaleBottom
        )
    }
}

// MARK: - Private Methods
extension SoundControl {
    private func addSubviews() {
        layer.addSublayer(gradientLayer)
        addSubview(volumeScaleView)
    }
}

// MARK: - Constants
extension SoundControl {
    private struct Constants {
        let volumeScaleBottom: CGFloat = 26.0
        let volumeScaleWidth: CGFloat = 16.0
    }
}
