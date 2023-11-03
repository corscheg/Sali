//
//  SampleViewModel.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.11.2023.
//

import Foundation

struct SampleViewModel {
    let name: String
    let identifier: SampleIdentifier
    
    // MARK: Initializer
    init(sample: SampleModel) {
        name = sample.name
        identifier = sample.identifier
    }
}

// MARK: - Hashable
extension SampleViewModel: Hashable {
    static func ==(lhs: SampleViewModel, rhs: SampleViewModel) -> Bool {
        lhs.identifier == rhs.identifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
