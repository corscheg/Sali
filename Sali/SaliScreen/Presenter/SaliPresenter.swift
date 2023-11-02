//
//  SaliPresenter.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.11.2023.
//

import Foundation

final class SaliPresenter {
    
    // MARK: Public Properties
    weak var view: SaliViewInput?
    
    // MARK: Private Properties
    private var layersTableVisible = false
}

// MARK: - SaliPresenterInput
extension SaliPresenter: SaliPresenterInput {
    func viewDidLoad() {
        let viewModel = SampleBankViewModel(
            guitarSamples: [SampleViewModel(name: "Guitar 1"), SampleViewModel(name: "Guitar 2"), SampleViewModel(name: "Guitar 3"), SampleViewModel(name: "Guitar 4")],
            drumSamples: [SampleViewModel(name: "Drum 1"), SampleViewModel(name: "Drum 2"), SampleViewModel(name: "Drum 3")],
            brassSamples: [SampleViewModel(name: "Brass 1"), SampleViewModel(name: "Brass 2")]
        )
        
        view?.populateSamples(with: viewModel)
    }
    
    func didSelect(viewModel: SampleViewModel) {
        print(viewModel)
    }
    
    func didTapLayersButton() {
        layersTableVisible.toggle()
        updateLayersTable()
    }
}

// MARK: - Private Methods
extension SaliPresenter {
    private func updateLayersTable() {
        if layersTableVisible {
            let viewModels = (1...5).map(String.init(_:)).map(LayerCellViewModel.init(name:))
            view?.populateLayersTable(with: viewModels)
            view?.showLayersTable()
        } else {
            view?.hideLayersTable()
        }
    }
}
