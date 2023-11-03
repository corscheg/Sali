//
//  SaliViewDelegate.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.11.2023.
//

import Foundation

protocol SaliViewDelegate: AnyObject {
    func didSelectSample(withIdentifier identifier: SampleIdentifier)
    func didChange(parameters: SoundParameters)
    func didTapPlayButton()
    func didTapLayersButton()
    func didSelectLayer(atIndex index: Int)
}
