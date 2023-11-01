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
