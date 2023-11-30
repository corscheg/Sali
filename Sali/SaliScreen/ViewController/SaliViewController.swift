//
//  SaliViewController.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 31.10.2023.
//

import UIKit

final class SaliViewController: UIViewController {
    
    // MARK: Private Properties
    private let presenter: SaliPresenterInput
    
    // MARK: Visual Components
    private lazy var saliView: SaliView = {
        let saliView = SaliView()
        saliView.delegate = self
        
        return saliView
    }()
    
    // MARK: Initializers
    init(presenter: SaliPresenterInput) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIViewController
    override func loadView() {
        view = saliView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewDidLoad()
    }
}

// MARK: - SaliViewInput
extension SaliViewController: SaliViewInput {
    func populateSamples(with viewModel: SampleBankViewModel) {
        saliView.populateSamples(with: viewModel)
    }
    
    func set(soundParameters: SoundParameters) {
        saliView.set(soundParameters: soundParameters)
    }
    
    func showLayersTable() {
        saliView.showLayersTable()
    }
    
    func hideLayersTable() {
        saliView.hideLayersTable()
    }
    
    func populateLayersTable(with viewModels: [LayerCellViewModel], reload: Bool) {
        saliView.populateLayersTable(with: viewModels, reload: reload)
    }
    
    func enableParametersControl() {
        saliView.enableParametersControl()
    }
    
    func disableParametersControl() {
        saliView.disableParametersControl()
    }
    
    func selectLayer(atIndex index: Int?) {
        saliView.selectLayer(atIndex: index)
    }
    
    func setPlayButtonStop() {
        saliView.setPlayButtonStop()
    }
    
    func showPermissionSettingsAlert(withAction action: @escaping () -> ()) {
        let alertController = UIAlertController(
            title: "Microphone access denied :[",
            message: "We are not able to start recording, because you denied the microphone access. But you can go to settings and grant it! Warning: The app will be relaunched, and you will lose your layers!",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let proceedAction = UIAlertAction(title: "Go!", style: .default) { _ in
            action()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(proceedAction)
        
        present(alertController, animated: true)
        alertController.view.tintColor = .accent
    }
    
    func disablePlayButton() {
        saliView.disablePlayButton()
    }
    
    func enablePlayButton() {
        saliView.enablePlayButton()
    }
    
    func disableRecordingButton() {
        saliView.disableRecordingButton()
    }
    
    func enableRecordingButton() {
        saliView.enableRecordingButton()
    }
    
    func disableMicrophoneButton() {
        saliView.disableMicrophoneButton()
    }
    
    func enableMicrophoneButton() {
        saliView.enableMicrophoneButton()
    }
    
    func setMicrophoneButtonInactive() {
        saliView.setMicrophoneButtonInactive()
    }
    
    func shareRecording(with url: URL) {
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(activityViewController, animated: true)
    }
    
    func updateMetering(_ metering: [Float]) {
        saliView.updateMetering(metering)
    }
    
    func clearAnalyzer() {
        saliView.clearAnalyzer()
    }
    
    func showAlert(withError error: Error?) {
        let alertController = UIAlertController(
            title: "Oops! Something went wrong",
            message: error?.localizedDescription ?? "Unknown error",
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: "OK :[", style: .default)
        
        alertController.addAction(action)
        
        present(alertController, animated: true)
        alertController.view.tintColor = .accent
    }
    
    func set(title: String) {
        saliView.set(title: title)
    }
}

// MARK: - SaliViewDelegate
extension SaliViewController: SaliViewDelegate {
    func didSelectSample(withIdentifier identifier: SampleIdentifier, type: LayerType) {
        presenter.didSelectSample(withIdentifier: identifier, type: type)
    }
    
    func didChange(parameters: SoundParameters) {
        presenter.didChange(soundParameters: parameters)
    }
    
    func didTapLayersButton() {
        presenter.didTapLayersButton()
    }
    
    func didTapMicrophoneButton() {
        presenter.didTapMicrophoneButton()
    }
    
    func didTapRecordingButton() {
        presenter.didTapRecordingButton()
    }
    
    func didTapPlayButton() {
        presenter.didTapPlayButton()
    }
    
    func didSelectLayer(atIndex index: Int) {
        presenter.didSelectLayer(atIndex: index)
    }
    
    func didSelectPlay(atIndex index: Int) {
        presenter.didSelectPlay(atIndex: index)
    }
    
    func didSelectMute(atIndex index: Int) {
        presenter.didSelectMute(atIndex: index)
    }
    
    func didSelectDelete(atIndex index: Int) {
        presenter.didSelectDelete(atIndex: index)
    }
}
