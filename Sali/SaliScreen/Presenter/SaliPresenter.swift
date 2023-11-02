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
    private var samples: [SampleViewModel: SampleModel] = [:]
    
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
    }
    
    func didSelect(viewModel: SampleViewModel) {
        guard let sample = samples[viewModel] else { return }
        
        do {
            try mixer.add(sample: sample, forKey: sample.identifier)
        } catch {
            #warning("HANDLE ERROR!")
            print(error)
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
    
    func didTapLayersButton() {
        layersTableVisible.toggle()
        updateLayersTable()
    }
}

// MARK: - Private Methods
extension SaliPresenter {
    private func updateLayersTable() {
        if layersTableVisible {
            let viewModels = (1...5).map(String.init(_:)).map(LayerCellViewModel.init(name:))
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
            samples[viewModel] = guitarSample
            guitarSampleViewModels.append(viewModel)
        }
        
        var drumsSampleViewModels: [SampleViewModel] = []
        for drumSample in bank.drumSamples {
            let viewModel = SampleViewModel(sample: drumSample)
            samples[viewModel] = drumSample
            drumsSampleViewModels.append(viewModel)
        }
        
        var brassSampleViewModels: [SampleViewModel] = []
        for brassSample in bank.brassSamples {
            let viewModel = SampleViewModel(sample: brassSample)
            samples[viewModel] = brassSample
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
        mixer.stop()
    }
}
