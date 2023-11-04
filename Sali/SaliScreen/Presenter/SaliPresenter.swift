//
//  SaliPresenter.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.11.2023.
//

import Foundation

final class SaliPresenter {
    
    // MARK: Public Properties
    weak var view: SaliViewInput?
    
    // MARK: Private Properties
    private let sampleLoader: SampleLoaderProtocol
    private let mixer: Mixer
    private let permissionManager: PermissionManagerProtocol
    private let urlProvider: URLProviderProtocol
    private let audioRecorder: AudioRecorderProtocol
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
        audioRecorder: AudioRecorderProtocol
    ) {
        self.sampleLoader = sampleLoader
        self.mixer = mixer
        self.permissionManager = permissionManager
        self.urlProvider = urlProvider
        self.audioRecorder = audioRecorder
    }
}

// MARK: - SaliPresenterInput
extension SaliPresenter: SaliPresenterInput {
    func viewDidLoad() {
        let sampleBank = sampleLoader.loadSamples()
        fillSamplesAndPopulateView(withBank: sampleBank)
        view?.disableParametersControl()
    }
    
    func didSelectSample(withIdentifier identifier: SampleIdentifier) {
        guard let sample = samples[identifier] else { return }
        
        let uuid = UUID()
        let layerModel = LayerModel(identifier: uuid, name: uuid.uuidString, isPlaying: false, isMuted: false, isMicrophone: false)
        
        do {
            try mixer.addLayer(withURL: sample.url, loops: true, andIdentifier: uuid)
            layers.append(layerModel)
            updateLayersTable()
            setSelectedIndex(to: layers.endIndex - 1)
            mixer.adjust(parameters: layerModel.parameters, forLayerAt: uuid)
            updateParametersControl()
        } catch {
            #warning("HANDLE ERROR!")
            print(error)
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
            permissionManager.performWithPermission { [weak self] in
                self?.startMicRecording()
            } failure: { [weak self] in
                self?.view?.showPermissionSettingsAlert { [weak self] in
                    self?.permissionManager.requestPermissionInSettings()
                }
            }
        }
    }
    
    func didTapRecordingButton() {
        if isRecording {
            do {
                try mixer.stop()
                isAllPlaying = false
                let url = try mixer.stopRecording()
                view?.enableMicrophoneButton()
                unlockAllPlayButtons()
                isRecording = false
                view?.shareRecording(with: url)
            } catch {
                #warning("HANDLE ERRORS")
                print(error)
            }
        } else {
            do {
                let url = try urlProvider.getURLForRecording()
                try mixer.stop()
                try mixer.startRecording(at: url)
                try mixer.play()
                view?.disableMicrophoneButton()
                setAllLayersNotPlaying()
                view?.setPlayButtonStop()
                lockAllPlayButtons()
                isRecording = true
            } catch {
                #warning("HANDLE ERRORS")
                print(error)
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
            do {
                try mixer.playItem(withIdentifier: layers[index].identifier)
                view?.setPlayButtonStop()
                isAllPlaying = false
                updateLayersTableRows()
            } catch {
                #warning("HANDLE ERROR")
                print(error)
            }
        } else {
            do {
                try mixer.stopItem(withIdentifier: layers[index].identifier)
                updateLayersTableRows()
            } catch {
                #warning("HANDLE ERROR")
                print(error)
            }
        }
    }
    
    func didSelectMute(atIndex index: Int) {
        toggleMute(at: index)
    }
    
    func didSelectDelete(atIndex index: Int) {
        removeLayer(at: index)
    }
}

// MARK: - AudioRecorderDelegate
extension SaliPresenter: AudioRecorderDelegate {
    func didFinishRecording(with url: URL) {
        let uuid = UUID()
        var layerModel = LayerModel(identifier: uuid, name: uuid.uuidString, isPlaying: false, isMuted: false, isMicrophone: true)
        layerModel.parameters.volume = 1.0
        do {
            try mixer.addLayer(withURL: url, loops: false, andIdentifier: uuid)
            layers.append(layerModel)
            updateLayersTable()
            setSelectedIndex(to: layers.endIndex - 1)
            mixer.adjust(parameters: layerModel.parameters, forLayerAt: uuid)
            updateParametersControl()
        } catch {
            #warning("HANDLE ERROR!")
            print(error)
        }
    }
    
    func didEndWithError() {
        #warning("HANDLE ERROR!")
    }
}

// MARK: - MixerDelegate
extension SaliPresenter: MixerDelegate {
    
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
        do {
            try mixer.play()
            setAllLayersNotPlaying()
        } catch {
            #warning("HANDLE ERROR!")
            print(error)
        }
    }
    
    private func stopAll() {
        do {
            try mixer.stop()
        } catch {
            #warning("HANDLE ERROR!")
            print(error)
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
        
        do {
            try mixer.removeLayer(withIdentifier: removedLayer.identifier)
        } catch {
            #warning("HANDLE ERROR!")
            print(error)
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
        
        do {
            let url = try urlProvider.getURLForRecording()
            try mixer.stop()
            isAllPlaying = false
            setAllLayersNotPlaying()
            view?.setPlayButtonStop()
            try audioRecorder.startRecording(to: url)
            lockAllPlayButtons()
            view?.disableRecordingButton()
            isRecordInProgress = true
            print("Recording started!")
        } catch {
            #warning("HANDLE ERROR")
            print(error)
        }
    }
    
    private func stopMicRecording() {
        
        do {
            try audioRecorder.stopRecording()
            unlockAllPlayButtons()
            view?.enableRecordingButton()
            isRecordInProgress = false
            print("Recording stopped!")
        } catch {
            #warning("HANDLE ERROR")
            print(error)
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
}
