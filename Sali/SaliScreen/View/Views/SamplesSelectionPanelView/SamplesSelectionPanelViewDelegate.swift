//
//  SamplesSelectionPanelViewDelegate.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.11.2023.
//

import Foundation

@MainActor
protocol SamplesSelectionPanelViewDelegate: AnyObject {
    func didSelect(viewModel: SampleViewModel, type: LayerType)
}
