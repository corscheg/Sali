//
//  VolumeScaleView.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 01.11.2023.
//

import UIKit

final class VolumeScaleView: UIView {
    
    // MARK: Private Properties
    private let units: UInt
    private let subunits: UInt
    
    // MARK: Initializers
    init(frame: CGRect, units: UInt, subunits: UInt) {
        self.units = units
        self.subunits = subunits
        super.init(frame: frame)
        
        setupView()
    }
    
    convenience init(units: UInt, subunits: UInt) {
        self.init(frame: .zero, units: units, subunits: subunits)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIView
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.saveGState()
        context.setStrokeColor(UIColor.buttons.cgColor)
        context.setLineWidth(1.0)
        let dashCount = units * subunits
        
        for i in 0...dashCount {
            let startX: CGFloat = 0
            let isMainUnit = (i % subunits == 0)
            let endX: CGFloat = isMainUnit ? bounds.width : bounds.width / 2
            let y = bounds.height * (CGFloat(i) / CGFloat(dashCount))
            
            let startPoint = CGPoint(x: startX, y: y)
            let endPoint = CGPoint(x: endX, y: y)
            
            context.strokeLineSegments(between: [startPoint, endPoint])
        }
        
        context.restoreGState()
    }
}

// MARK: - Private Methods
extension VolumeScaleView {
    private func setupView() {
        clipsToBounds = false
        backgroundColor = .clear
    }
}
