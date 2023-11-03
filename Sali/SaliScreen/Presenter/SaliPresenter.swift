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
    private var layersTableVisible = false
    private var isAllPlaying = false
    private var samples: [SampleIdentifier: SampleModel] = [:]
    private var layers: [LayerModel] = []
    private var selectedLayerIndex: Int?
    
    // MARK: Initializers
    init(sampleLoader: SampleLoaderProtocol, mixer: Mixer) {
        self.sampleLoader = sampleLoader
        self.mixer = mixer
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
        let layerModel = LayerModel(identifier: uuid, name: uuid.uuidString)
        
        do {
            try mixer.addLayer(withSample: sample, andIdentifier: uuid)
            layers.append(layerModel)
            selectedLayerIndex = layers.endIndex - 1
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
    
    func didTapPlayButton() {
        isAllPlaying.toggle()
        
        if isAllPlaying {
            playAll()
        } else {
            stopAll()
        }
    }
    
    func didTapLayersButton() {
        layersTableVisible.toggle()
        updateLayersTable()
    }
}

// MARK: - Private Methods
extension SaliPresenter {
    private func updateLayersTable() {
        if layersTableVisible {
            let viewModels = layers.enumerated().map { createLayerViewModel(withModel: $1, index: $0) }
            view?.populateLayersTable(with: viewModels)
            view?.showLayersTable()
        } else {
            view?.hideLayersTable()
        }
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
        LayerCellViewModel(layerModel: model) { [weak self] in
            self?.removeLayer(at: index)
            self?.updateLayersTable()
        }
    }
    
    private func removeLayer(at index: Int) {
        let removedLayer = layers.remove(at: index)
        
        
        if let selectedLayerIndex {
            
            var newIndex = selectedLayerIndex
            if index < selectedLayerIndex {
                newIndex -= 1
                self.selectedLayerIndex = newIndex
            } else if index == selectedLayerIndex {
                if (newIndex - 1) >= 0 {
                    self.selectedLayerIndex = newIndex - 1
                } else if selectedLayerIndex >= layers.endIndex {
                    self.selectedLayerIndex = nil
                }
            }
            
            updateParametersControl()
        }
        
        do {
            try mixer.removeLayer(withIdentifier: removedLayer.identifier)
        } catch {
            #warning("HANDLE ERROR!")
            print(error)
        }
    }
    
    private func updateParametersControl() {
        if let selectedLayerIndex {
            view?.enableParametersControl()
            view?.set(soundParameters: layers[selectedLayerIndex].parameters)
        } else {
            view?.disableParametersControl()
        }
    }
}
