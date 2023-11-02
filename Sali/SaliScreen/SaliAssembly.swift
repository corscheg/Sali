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
        let presenter = SaliPresenter(sampleLoader: sampleLoader)
        let viewController = SaliViewController(presenter: presenter)
        presenter.view = viewController
        
        return viewController
    }
}
