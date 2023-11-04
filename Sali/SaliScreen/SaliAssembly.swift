//
//  SaliAssembly.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.11.2023.
//

import UIKit

struct SaliAssembly {
    func assemble() -> UIViewController {
        let sampleLoader = SampleLoader()
        let signalProcessor = SignalProcessor()
        let mixer = SaliMixer(signalProcessor: signalProcessor)
        let permissionManager = PermissionManager()
        let urlProvider = URLProvider()
        let audioRecorder = AudioRecorder()
        
        let presenter = SaliPresenter(
            sampleLoader: sampleLoader,
            mixer: mixer,
            permissionManager: permissionManager,
            urlProvider: urlProvider,
            audioRecorder: audioRecorder
        )
        let viewController = SaliViewController(presenter: presenter)
        presenter.view = viewController
        audioRecorder.delegate = presenter
        mixer.delegate = presenter
        
        return viewController
    }
}
