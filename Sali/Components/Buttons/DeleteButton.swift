//
//  DeleteButton.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.11.2023.
//

import UIKit

final class DeleteButton: IconSaliButton<CALayer, Double> {
    
    // MARK: Visual Components
    private lazy var deleteIconLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.clear.cgColor
        layer.backgroundColor = UIColor.clear.cgColor
        layer.fillColor = UIColor.icons.cgColor
        
        return layer
    }()
    
    // MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
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
        
        let deleteIconSize = CGSize(width: iconSide, height: iconSide)
        let deleteIconOrigin = CGPoint(
            x: bounds.midX - deleteIconSize.width / 2,
            y: bounds.midY - deleteIconSize.height / 2
        )
        
        deleteIconLayer.frame = CGRect(origin: deleteIconOrigin, size: deleteIconSize)
        deleteIconLayer.path = UIBezierPath.makeXMark(size: deleteIconSize).cgPath
    }
}

// MARK: - Private Methods
extension DeleteButton {
    private func setupView() {
        backgroundColor = .closeButton
    }
    
    private func addSubviews() {
        layer.addSublayer(deleteIconLayer)
    }
}
