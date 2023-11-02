//
//  SaliViewDelegate.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.11.2023.
//

import Foundation

protocol SaliViewDelegate: AnyObject {
    func didSelect(viewModel: SampleViewModel)
    func didTapLayersButton()
}
