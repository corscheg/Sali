//
//  MuteButton.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.11.2023.
//

import UIKit

final class MuteButton: IconSaliButton<CAShapeLayer, CGFloat> {
    
    // MARK: Visual Components
    
    private lazy var lineIconLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.mute.cgColor
        layer.backgroundColor = UIColor.clear.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 1.0
        layer.lineCap = .round
        layer.strokeEnd = 0.0
        
        return layer
    }()
    
    // MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews()
        setupAnimation()
        setImage(.speakerIcon, for: .normal)
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    // MARK: UIView
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let muteLineRatio = constants.iconWidthRatio * 1.33
        
        let minimumSide = min(bounds.width, bounds.height)
        let muteLineSide = minimumSide * muteLineRatio
        let muteLineSize = CGSize(width: muteLineSide, height: muteLineSide)
        let muteLineOrigin = CGPoint(x: bounds.midX - muteLineSide / 2.0, y: bounds.midY - muteLineSide / 2.0)
        
        lineIconLayer.frame = CGRect(origin: muteLineOrigin, size: muteLineSize)
        lineIconLayer.path = UIBezierPath.makeMuteLine(size: muteLineSize).cgPath
    }
}

// MARK: - Private Methods
extension MuteButton {
    private func addSubviews() {
        layer.addSublayer(lineIconLayer)
    }
    
    private func setupAnimation() {
        animationDescriptor = .init(
            layer: lineIconLayer,
            property: \.strokeEnd,
            inactiveValue: 0.0,
            activeValue: 1.0
        )
    }
}
