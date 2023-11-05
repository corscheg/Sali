//
//  TempoScaleView.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 01.11.2023.
//

import UIKit

final class TempoScaleView: UIView {
    
    // MARK: Private Properties
    private let units: UInt
    
    // MARK: Initializers
    init(frame: CGRect, units: UInt) {
        self.units = units
        super.init(frame: frame)
        
        setupView()
    }
    
    convenience init(units: UInt) {
        self.init(frame: .zero, units: units)
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
        let dashCount = units
        
        for i in 0...dashCount {
            let startY = bounds.minY
            let endY = bounds.maxY
            let x = bounds.width * (CGFloat(i) / CGFloat(dashCount))
            
            let startPoint = CGPoint(x: x, y: startY)
            let endPoint = CGPoint(x: x, y: endY)
            
            context.strokeLineSegments(between: [startPoint, endPoint])
        }
        
        context.restoreGState()
    }
}

// MARK: - Private Methods
extension TempoScaleView {
    private func setupView() {
        clipsToBounds = false
        backgroundColor = .clear
    }
}
