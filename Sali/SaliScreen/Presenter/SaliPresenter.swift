//
//  SaliPresenter.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.11.2023.
//

import OSLog
import Foundation

@MainActor
final class SaliPresenter {
    
    // MARK: Public Properties
    weak var view: SaliViewInput?
    
    // MARK: Private Properties
    private let sampleLoader: SampleLoaderProtocol
    private let mixer: Mixer
    private let permissionManager: PermissionManagerProtocol
    private let urlProvider: URLProviderProtocol
    private let audioRecorder: AudioRecorderProtocol
    private let nameManager: NameManagerProtocol
    
    private var layersTableVisible = false
    private var isAllPlaying = false
    private var isRecordInProgress = false
    private var isPlayingLocked = false
    private var isRecording = false
    private var samples: [SampleIdentifier: SampleModel] = [:]
    private var layers: [LayerModel] = []
    private var selectedLayerIndex: Int?
    
    // MARK: Initializers
    init(
        sampleLoader: SampleLoaderProtocol,
        mixer: Mixer,
        permissionManager: PermissionManagerProtocol,
        urlProvider: URLProviderProtocol,
        audioRecorder: AudioRecorderProtocol,
        nameManager: NameManagerProtocol
    ) {
        self.sampleLoader = sampleLoader
        self.mixer = mixer
        self.permissionManager = permissionManager
        self.urlProvider = urlProvider
        self.audioRecorder = audioRecorder
        self.nameManager = nameManager
    }
}

// MARK: - SaliPresenterInput
extension SaliPresenter: SaliPresenterInput {
    func viewDidLoad() {
        let sampleBank = sampleLoader.loadSamples()
        fillSamplesAndPopulateView(withBank: sampleBank)
        view?.disableParametersControl()
    }
    
    func didSelectSample(withIdentifier identifier: SampleIdentifier, type: LayerType) {
        guard let sample = samples[identifier] else { return }
        
        let uuid = UUID()
        let name = nameManager.getName(forType: type)
        let layerModel = LayerModel(identifier: uuid, name: name, isPlaying: false, isMuted: false, isMicrophone: false)
        
        tryToPerformWithAlert {
            try mixer.addLayer(withURL: sample.url, loops: true, andIdentifier: uuid)
            layers.append(layerModel)
            updateLayersTable()
            setSelectedIndex(to: layers.endIndex - 1)
            mixer.adjust(parameters: layerModel.parameters, forLayerAt: uuid)
            updateParametersControl()
        }
    }
    
    func didChange(soundParameters: SoundParameters) {
        guard let selectedLayerIndex else { return }
        layers[safe: selectedLayerIndex]?.parameters = soundParameters
        mixer.adjust(parameters: soundParameters, forLayerAt: layers[selectedLayerIndex].identifier)
    }
    
    func didTapLayersButton() {
        layersTableVisible.toggle()
        updateLayersTable()
    }
    
    func didTapMicrophoneButton() {
        if isRecordInProgress {
            stopMicRecording()
        } else {
            Task { [permissionManager] in
                do {
                    try await permissionManager.checkPermission()
                    startMicRecording()
                } catch {
                    view?.showPermissionSettingsAlert {
                        permissionManager.requestPermissionInSettings()
                    }
                    
                    view?.setMicrophoneButtonInactive()
                }
            }
        }
    }
    
    func didTapRecordingButton() {
        if isRecording {
            tryToPerformWithAlert {
                try mixer.stop()
                isAllPlaying = false
                let url = try mixer.stopRecording()
                view?.enableMicrophoneButton()
                unlockAllPlayButtons()
                isRecording = false
                view?.openVisualizer(mode: .recording(url: url))
            }
        } else {
            tryToPerformWithAlert {
                try mixer.stop()
                let filename = nameManager.getNameForRecording()
                let url = urlProvider.getURLForRecord(withFilename: filename)
                try mixer.startRecording(at: url)
                try mixer.play()
                view?.disableMicrophoneButton()
                setAllLayersNotPlaying()
                view?.setPlayButtonStop()
                lockAllPlayButtons()
                isRecording = true
            }
        }
    }
    
    func didTapPlayButton() {
        isAllPlaying.toggle()
        
        if isAllPlaying {
            playAll()
        } else {
            stopAll()
        }
    }
    
    func didSelectLayer(atIndex index: Int) {
        setSelectedIndex(to: index, updateLayersView: false)
    }
    
    func didSelectPlay(atIndex index: Int) {
        layers[index].isPlaying.toggle()
        
        if layers[index].isPlaying {
            tryToPerformWithAlert {
                try mixer.playItem(withIdentifier: layers[index].identifier)
                view?.setPlayButtonStop()
                isAllPlaying = false
                updateLayersTableRows()
            }
        } else {
            tryToPerformWithAlert {
                try mixer.stopItem(withIdentifier: layers[index].identifier)
                updateLayersTableRows()
            }
        }
    }
    
    func didSelectMute(atIndex index: Int) {
        toggleMute(at: index)
    }
    
    func didSelectDelete(atIndex index: Int) {
        removeLayer(at: index)
    }
    
    func didTapAnalyzer() {
        view?.openVisualizer(mode: .preview(mixer: mixer))
    }
}

// MARK: - AudioRecorderDelegate
extension SaliPresenter: AudioRecorderDelegate {
    nonisolated func didFinishRecording(with url: URL) {
        Task { @MainActor in
            let uuid = UUID()
            let name = nameManager.getName(forType: .microphone)
            var layerModel = LayerModel(identifier: uuid, name: name, isPlaying: false, isMuted: false, isMicrophone: true)
            layerModel.parameters.volume = 1.0
            
            tryToPerformWithAlert {
                try mixer.addLayer(withURL: url, loops: false, andIdentifier: uuid)
                layers.append(layerModel)
                updateLayersTable()
                setSelectedIndex(to: layers.endIndex - 1)
                mixer.adjust(parameters: layerModel.parameters, forLayerAt: uuid)
                updateParametersControl()
                unlockAllPlayButtons()
                view?.enableRecordingButton()
                isRecordInProgress = false
            }
        }
    }
    
    nonisolated func didEndWithError() {
        Task { @MainActor in
            view?.showAlert(withError: nil)
            unlockAllPlayButtons()
            view?.enableRecordingButton()
            isRecordInProgress = false
        }
    }
}

// MARK: - MixerDelegate
extension SaliPresenter: MixerDelegate {
    nonisolated func didPerformMetering(_ result: [Float], level: Float) {
        Task { @MainActor in
            view?.updateMetering(result)
        }
    }
    
    nonisolated func didEndPlaying() {
        Task { @MainActor in
            view?.clearAnalyzer()
        }
    }
}

// MARK: - Private Methods
extension SaliPresenter {
    private func updateLayersTable() {
        updateLayersTableRows()
        if layersTableVisible {
            view?.showLayersTable()
        } else {
            view?.hideLayersTable()
        }
    }
    
    private func updateLayersTableRows(reload: Bool = true) {
        let viewModels = layers.enumerated().map { createLayerViewModel(withModel: $1, index: $0) }
        view?.populateLayersTable(with: viewModels, reload: reload)
    }
    
    private func fillSamplesAndPopulateView(withBank bank: SampleBankModel) {
        var guitarSampleViewModels: [SampleViewModel] = []
        for guitarSample in bank.guitarSamples {
            let viewModel = SampleViewModel(sample: guitarSample)
            samples[guitarSample.identifier] = guitarSample
            guitarSampleViewModels.append(viewModel)
        }
        
        var drumsSampleViewModels: [SampleViewModel] = []
        for drumSample in bank.drumSamples {
            let viewModel = SampleViewModel(sample: drumSample)
            samples[drumSample.identifier] = drumSample
            drumsSampleViewModels.append(viewModel)
        }
        
        var brassSampleViewModels: [SampleViewModel] = []
        for brassSample in bank.brassSamples {
            let viewModel = SampleViewModel(sample: brassSample)
            samples[brassSample.identifier] = brassSample
            brassSampleViewModels.append(viewModel)
        }
        
        let viewModel = SampleBankViewModel(
            guitarSamples: guitarSampleViewModels,
            drumSamples: drumsSampleViewModels,
            brassSamples: brassSampleViewModels
        )
        
        view?.populateSamples(with: viewModel)
    }
    
    private func playAll() {
        tryToPerformWithAlert {
            try mixer.play()
            setAllLayersNotPlaying()
        }
    }
    
    private func stopAll() {
        tryToPerformWithAlert {
            try mixer.stop()
        }
    }
    
    private func createLayerViewModel(withModel model: LayerModel, index: Int) -> LayerCellViewModel {
        LayerCellViewModel(layerModel: model, isPlayLocked: isPlayingLocked)
    }
    
    private func removeLayer(at index: Int) {
        let removedLayer = layers.remove(at: index)
        
        updateLayersTable()
        
        if let selectedLayerIndex {
            
            var newIndex = selectedLayerIndex
            if index < selectedLayerIndex {
                newIndex -= 1
                setSelectedIndex(to: newIndex)
            } else if index == selectedLayerIndex {
                if (newIndex - 1) >= 0 {
                    setSelectedIndex(to: newIndex - 1)
                } else if selectedLayerIndex >= layers.endIndex {
                    setSelectedIndex(to: nil)
                }
            }
        }
        
        tryToPerformWithAlert {
            try mixer.removeLayer(withIdentifier: removedLayer.identifier)
        }
    }
    
    private func updateParametersControl() {
        if let selectedLayerIndex, !layers[selectedLayerIndex].isMicrophone {
            view?.enableParametersControl()
            view?.set(soundParameters: layers[selectedLayerIndex].parameters)
        } else {
            view?.disableParametersControl()
        }
    }
    
    private func setSelectedIndex(to value: Int?, updateLayersView: Bool = true) {
        selectedLayerIndex = value
        updateParametersControl()
        
        if let selectedLayerIndex {
            view?.set(title: layers[selectedLayerIndex].name)
        } else {
            view?.set(title: "")
        }
        
        if updateLayersView {
            view?.selectLayer(atIndex: value)
        }
    }
    
    private func toggleMute(at index: Int) {
        layers[index].isMuted.toggle()
        updateLayersTableRows()
        mixer.set(muted: layers[index].isMuted, forLayerAt: layers[index].identifier)
    }
    
    private func startMicRecording() {
        tryToPerformWithAlert {
            let url = try urlProvider.getURLForMicrophoneRecording()
            try mixer.stop()
            isAllPlaying = false
            setAllLayersNotPlaying()
            view?.setPlayButtonStop()
            try audioRecorder.startRecording(to: url)
            lockAllPlayButtons()
            view?.disableRecordingButton()
            isRecordInProgress = true
        }
    }
    
    private func stopMicRecording() {
        tryToPerformWithAlert {
            try audioRecorder.stopRecording()
        }
    }
    
    private func setAllLayersNotPlaying() {
        for i in layers.indices {
            layers[i].isPlaying = false
        }
        updateLayersTableRows(reload: false)
    }
    
    private func lockAllPlayButtons() {
        isPlayingLocked = true
        updateLayersTableRows(reload: false)
        view?.disablePlayButton()
    }
    
    private func unlockAllPlayButtons() {
        isPlayingLocked = false
        updateLayersTableRows(reload: false)
        view?.enablePlayButton()
    }
    
    private func showAlert(withError error: Error?) {
        view?.showAlert(withError: error)
    }
    
    private func tryToPerformWithAlert(block: () throws -> (), failure: (() -> ())? = nil) {
        do {
            try block()
        } catch {
            showAlert(withError: error)
            failure?()
        }
    }
}
