//
//  LayerCellViewModel.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.11.2023.
//

import Foundation

struct LayerCellViewModel {
    let name: String
    let isMuted: Bool
    
    // MARK: Initializers
    init(layerModel: LayerModel) {
        name = layerModel.name
        isMuted = layerModel.isMuted
    }
}

// MARK: - Hashable
extension LayerCellViewModel: Hashable { 
    static func ==(lhs: LayerCellViewModel, rhs: LayerCellViewModel) -> Bool {
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
