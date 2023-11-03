//
//  SaliPresenterInput.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.11.2023.
//

import Foundation

protocol SaliPresenterInput {
    func viewDidLoad()
    func didSelectSample(withIdentifier identifier: SampleIdentifier)
    func didChange(soundParameters: SoundParameters)
    func didTapPlayButton()
    func didTapLayersButton()
    func didSelectLayer(atIndex index: Int)
    func didSelectPlay(atIndex index: Int)
    func didSelectMute(atIndex index: Int)
    func didSelectDelete(atIndex index: Int)
}
