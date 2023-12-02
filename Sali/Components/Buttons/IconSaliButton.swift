//
//  IconSaliButton.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 01.11.2023.
//

import UIKit

class IconSaliButton<LayerType: CALayer, AnimatedProperty>: SaliButton<LayerType, AnimatedProperty> {
    
    // MARK: Private Properties
    let constants = Constants()
    
    // MARK: Visual Components
    private lazy var highlightedView: UIView = {
        let view = UIView()
        view.backgroundColor = .closeButton
        view.layer.masksToBounds = true
        view.alpha = 0.0
        
        return view
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
    override var intrinsicContentSize: CGSize {
        CGSize(width: 44.0, height: 44.0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = bounds.width
        let insetValue = size * 0.125
        let inset = UIEdgeInsets(top: insetValue, left: insetValue, bottom: insetValue, right: insetValue)
        highlightedView.frame = bounds.inset(by: inset)
        
        highlightedView.layer.cornerRadius = highlightedView.frame.width / 2.0
    }
    
    // MARK: UIButton
    override var isHighlighted: Bool {
        didSet {
            updateHighlightedView()
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            updateEnabled()
        }
    }
}

// MARK: - Private Methods
extension IconSaliButton {
    private func addSubviews() {
        addSubview(highlightedView)
    }
    
    private func updateHighlightedView() {
        let finalAlpha: CGFloat = isHighlighted ? 1.0 : 0.0
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut) {
            self.highlightedView.alpha = finalAlpha
        }
    }
    
    private func updateEnabled() {
        let finalAlpha: CGFloat = isEnabled ? 1.0 : 0.4
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut) {
            self.alpha = finalAlpha
        }
    }
}

// MARK: - Constants
extension IconSaliButton {
    struct Constants {
        let iconWidthRatio: CGFloat = 0.34
    }
}
