//
//  SampleViewModel.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.11.2023.
//

import Foundation

struct SampleViewModel {
    let name: String
    let identifier: String
    
    // MARK: Initializer
    init(sample: SampleModel) {
        name = sample.name
        identifier = sample.identifier
    }
}
