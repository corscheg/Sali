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
    
    func populateLayersTable(with viewModels: [LayerCellViewModel]) {
        saliView.populateLayersTable(with: viewModels)
    }
    
    func enableParametersControl() {
        saliView.enableParametersControl()
    }
    
    func disableParametersControl() {
        saliView.disableParametersControl()
    }
}

// MARK: - SaliViewDelegate
extension SaliViewController: SaliViewDelegate {
    func didSelectSample(withIdentifier identifier: SampleIdentifier) {
        presenter.didSelectSample(withIdentifier: identifier)
    }
    
    func didChange(parameters: SoundParameters) {
        presenter.didChange(soundParameters: parameters)
    }
    
    func didTapPlayButton() {
        presenter.didTapPlayButton()
    }
    
    func didTapLayersButton() {
        presenter.didTapLayersButton()
    }
}
