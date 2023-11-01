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
}

// MARK: - Constants
extension IconSaliButton {
    struct Constants {
        let iconWidthRatio: CGFloat = 0.34
    }
}
