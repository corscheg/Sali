//
//  VisualViewInput.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.12.2023.
//

import Foundation

@MainActor
protocol VisualViewInput: AnyObject {
    func setCurrentTime(text: String)
    func setDuration(text: String)
    func updateVisual(frequencies: [Float], level: Float)
    func setRecording(title: String?)
    func disableTitle()
    func disableSaveButton()
    func disablePlaybackControl()
    func setPlayInactive()
    func shareRecording(with url: URL)
    func dismiss()
}
