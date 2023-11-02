//
//  SaliPresenterInput.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.11.2023.
//

import Foundation

protocol SaliPresenterInput {
    func viewDidLoad()
    func didSelect(viewModel: SampleViewModel)
    func didTapPlayButton()
    func didTapLayersButton()
}
