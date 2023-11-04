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
        let mixer = SaliMixer()
        let permissionManager = PermissionManager()
        let urlProvider = URLProvider()
        let presenter = SaliPresenter(sampleLoader: sampleLoader, mixer: mixer, permissionManager: permissionManager, urlProvider: urlProvider)
        let viewController = SaliViewController(presenter: presenter)
        presenter.view = viewController
        
        return viewController
    }
}
