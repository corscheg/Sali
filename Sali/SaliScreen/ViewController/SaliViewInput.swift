//
//  SaliViewInput.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.11.2023.
//

import Foundation

protocol SaliViewInput: AnyObject {
    func populateSamples(with viewModel: SampleBankViewModel)
    func set(soundParameters: SoundParameters)
    func showLayersTable()
    func hideLayersTable()
    func disableParametersControl()
    func enableParametersControl()
    func populateLayersTable(with viewModels: [LayerCellViewModel], reload: Bool)
    func selectLayer(atIndex index: Int?)
}
