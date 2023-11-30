//
//  SaliViewInput.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.11.2023.
//

import Foundation

protocol SaliViewInput: AnyObject {
    func populateSamples(with viewModel: SampleBankViewModel)
    func set(soundParameters: SoundParameters)
    func showLayersTable()
    func hideLayersTable()
    func disableParametersControl()
    func enableParametersControl()
    func populateLayersTable(with viewModels: [LayerCellViewModel], reload: Bool)
    func selectLayer(atIndex index: Int?)
    func setPlayButtonStop()
    func showPermissionSettingsAlert(withAction action: @escaping () -> ())
    func disablePlayButton()
    func enablePlayButton()
    func disableRecordingButton()
    func enableRecordingButton()
    func disableMicrophoneButton()
    func enableMicrophoneButton()
    func setMicrophoneButtonInactive()
    func shareRecording(with url: URL)
    func updateMetering(_ metering: [Float])
    func clearAnalyzer()
    func showAlert(withError error: Error?)
    func set(title: String)
}
