//
//  SaliViewDelegate.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.11.2023.
//

import Foundation

@MainActor
protocol SaliViewDelegate: AnyObject {
    func didSelectSample(withIdentifier identifier: SampleIdentifier, type: LayerType)
    func didChange(parameters: SoundParameters)
    func didTapLayersButton()
    func didTapMicrophoneButton()
    func didTapRecordingButton()
    func didTapPlayButton()
    func didSelectLayer(atIndex index: Int)
    func didSelectPlay(atIndex index: Int)
    func didSelectMute(atIndex index: Int)
    func didSelectDelete(atIndex index: Int)
    func didTapAnalyzer()
}
