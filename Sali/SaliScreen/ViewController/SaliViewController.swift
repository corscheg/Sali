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
    
    func showLayersTable() {
        saliView.showLayersTable()
    }
    
    func hideLayersTable() {
        saliView.hideLayersTable()
    }
    
    func populateLayersTable(with viewModels: [LayerCellViewModel]) {
        saliView.populateLayersTable(with: viewModels)
    }
}

// MARK: - SaliViewDelegate
extension SaliViewController: SaliViewDelegate {
    func didSelect(viewModel: SampleViewModel) {
        presenter.didSelect(viewModel: viewModel)
    }
    
    func didTapLayersButton() {
        presenter.didTapLayersButton()
    }
}