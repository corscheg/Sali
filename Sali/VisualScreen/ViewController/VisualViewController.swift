//
//  VisualViewController.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.12.2023.
//

import UIKit

final class VisualViewController: UIViewController {
    
    // MARK: Private Properties
    private let presenter: VisualPresenterProtocol
    
    // MARK: Visual Components
    private lazy var visualView: VisualView = {
        let view = VisualView()
        view.delegate = self
        
        return view
    }()
    
    // MARK: Initializers
    init(presenter: VisualPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIViewController
    override func loadView() {
        view = visualView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewDidLoad()
    }
}

// MARK: - VisualViewInput
extension VisualViewController: VisualViewInput {
    func setCurrentTime(text: String) {
        visualView.setCurrentTime(text: text)
    }
    
    func setDuration(text: String) {
        visualView.setDuration(text: text)
    }
    
    func disableSaveButton() {
        visualView.disableSaveButton()
    }
    
    func disablePlaybackControl() {
        visualView.disablePlaybackControl()
    }
    
    func setPlayInactive() {
        visualView.setPlayInactive()
    }
    
    func dismiss() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - VisualViewDelegate
extension VisualViewController: VisualViewDelegate {
    func backButtonTapped() {
        presenter.backButtonTapped()
    }
    
    func saveButtonTapped() {
        presenter.saveButtonTapped()
    }
    
    func rewindTapped() {
        presenter.rewindTapped()
    }
    
    func playTapped() {
        presenter.playTapped()
    }
    
    func toEndTapped() {
        presenter.toEndTapped()
    }
}
