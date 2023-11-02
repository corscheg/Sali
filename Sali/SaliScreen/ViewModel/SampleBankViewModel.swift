//
//  SampleBankViewModel.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.11.2023.
//

import Foundation

struct SampleBankViewModel {
    let guitarSamples: [SampleViewModel]
    let drumSamples: [SampleViewModel]
    let brassSamples: [SampleViewModel]
    
    // MARK: Initializer
    init(bankModel: SampleBankModel) {
        guitarSamples = bankModel.guitarSamples.map(SampleViewModel.init(sample:))
        drumSamples = bankModel.drumSamples.map(SampleViewModel.init(sample:))
        brassSamples = bankModel.brassSamples.map(SampleViewModel.init(sample:))
    }
}
