//
//  ButtonsPanelViewDelegate.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.11.2023.
//

import Foundation

@MainActor
protocol ButtonsPanelViewDelegate: AnyObject {
    func didTapLayersButton()
    func didTapMicrophoneButton()
    func didTapRecordingButton()
    func didTapPlayButton()
}
