//
//  SaliAssembly.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.11.2023.
//

import UIKit

struct SaliAssembly {
    func assemble() -> UIViewController {
        
        let processingBufferLength = 256
        let sampleLoader = SampleLoader()
        let signalProcessor = SignalProcessor(processingBufferLength: processingBufferLength)
        let mixer = SaliMixer(signalProcessor: signalProcessor, processingBufferLength: processingBufferLength)
        let permissionManager = PermissionManager()
        let urlProvider = URLProvider()
        let audioRecorder = AudioRecorder()
        let nameManager = NameManager(userDefaults: .standard)
        
        let presenter = SaliPresenter(
            sampleLoader: sampleLoader,
            mixer: mixer,
            permissionManager: permissionManager,
            urlProvider: urlProvider,
            audioRecorder: audioRecorder,
            nameManager: nameManager
        )
        let viewController = SaliViewController(presenter: presenter)
        presenter.view = viewController
        audioRecorder.delegate = presenter
        mixer.delegate = presenter
        
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.isNavigationBarHidden = true
        
        return navigationController
    }
}
