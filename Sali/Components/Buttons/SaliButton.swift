//
//  SaliButton.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 01.11.2023.
//

import UIKit

class SaliButton: UIButton {
    
    // MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - AnimationDescriptor
extension SaliButton {
    struct AnimationDescriptor<T> {
        let layer: CALayer
        let property: KeyPath<CALayer, T>
        let fromValue: T
        let toValue: T
    }
}

// MARK: - Private Methods
extension SaliButton {
    private func setupView() {
        layer.cornerRadius = 4.0
        layer.cornerCurve = .continuous
        backgroundColor = .buttons
    }
}
