//
//  SaliButton.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 01.11.2023.
//

import UIKit

class SaliButton<LayerType: CALayer, AnimatedProperty>: UIButton {
    
    // MARK: Public Properties
    var animationDescriptor: AnimationDescriptor<LayerType, AnimatedProperty>?
    
    // MARK: Private Properties
    private(set) var isActive = false {
        didSet {
            activeStateDidChange()
        }
    }
    private let toActiveKey = "SaliButtonToActive"
    private let toInactiveKey = "SaliButtonToInactive"
    private let duration = 0.3
    
    // MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupAnimations()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Public Methods
    func activeStateDidChange() { }
    
    func set(active: Bool) {
        guard active != isActive else { return }
        
        handleTap()
    }
    
    // MARK: Actions
    @objc private func handleTap() {
        isActive.toggle()
        guard var animationDescriptor else { return }
        
        #warning("REFACTOR")
        if isActive {
            let fromValue: AnimatedProperty
            
            if animationDescriptor.layer.animation(forKey: toInactiveKey) != nil,
               let presentationLayer = animationDescriptor.layer.presentation() {
                fromValue = presentationLayer[keyPath: animationDescriptor.property]
            } else {
                fromValue = animationDescriptor.inactiveValue
            }
            
            let animation = CABasicAnimation(keyPath: animationDescriptor.property.stringValue)
            animation.fromValue = fromValue
            animation.toValue = animationDescriptor.activeValue
            animation.duration = duration
            
            animationDescriptor.layer[keyPath: animationDescriptor.property] = animationDescriptor.activeValue
            animationDescriptor.layer.removeAnimation(forKey: toInactiveKey)
            animationDescriptor.layer.add(animation, forKey: toActiveKey)
        } else {
            let fromValue: AnimatedProperty
            
            if animationDescriptor.layer.animation(forKey: toActiveKey) != nil,
               let presentationLayer = animationDescriptor.layer.presentation() {
                fromValue = presentationLayer[keyPath: animationDescriptor.property]
            } else {
                fromValue = animationDescriptor.activeValue
            }
            
            let animation = CABasicAnimation(keyPath: animationDescriptor.property.stringValue)
            animation.fromValue = fromValue
            animation.toValue = animationDescriptor.inactiveValue
            animation.duration = duration
            
            animationDescriptor.layer[keyPath: animationDescriptor.property] = animationDescriptor.inactiveValue
            animationDescriptor.layer.removeAnimation(forKey: toActiveKey)
            animationDescriptor.layer.add(animation, forKey: toInactiveKey)
        }
    }
}

// MARK: - AnimationDescriptor
extension SaliButton {
    struct AnimationDescriptor<Layer: CALayer, Property> {
        var layer: Layer
        let property: WritableKeyPath<Layer, Property>
        let inactiveValue: Property
        let activeValue: Property
    }
}

// MARK: - Private Methods
extension SaliButton {
    private func setupView() {
        layer.cornerRadius = 4.0
        layer.cornerCurve = .continuous
        backgroundColor = .buttons
        clipsToBounds = true
    }
    
    private func setupAnimations() {
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }
}
