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
    private let duration = 0.15
    private let timingFunction = CAMediaTimingFunction(name: .easeOut)
    
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
        
        let fromValue: AnimatedProperty
        let reverseAnimationKey = isActive ? toInactiveKey : toActiveKey
        let actualKey = isActive ? toActiveKey : toInactiveKey
        let reverseValue = isActive ? animationDescriptor.inactiveValue : animationDescriptor.activeValue
        let targetValue = isActive ? animationDescriptor.activeValue : animationDescriptor.inactiveValue
        
        if animationDescriptor.layer.animation(forKey: reverseAnimationKey) != nil,
           let presentationLayer = animationDescriptor.layer.presentation() {
            fromValue = presentationLayer[keyPath: animationDescriptor.property]
        } else {
            fromValue = reverseValue
        }
        
        let animation = CABasicAnimation(keyPath: animationDescriptor.property.stringValue)
        animation.fromValue = fromValue
        animation.toValue = targetValue
        animation.duration = duration
        animation.timingFunction = timingFunction
        
        animationDescriptor.layer[keyPath: animationDescriptor.property] = targetValue
        animationDescriptor.layer.removeAnimation(forKey: reverseAnimationKey)
        animationDescriptor.layer.add(animation, forKey: actualKey)
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
