//
//  VisualAssembly.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.12.2023.
//

import UIKit

struct VisualAssembly {
    
    @MainActor
    func assemble(mode: VisualizerMode) -> UIViewController {
        let audioUtility = AudioUtility()
        let presenter = switch mode {
        case .preview(let mixer):
            VisualPresenter(mode: .preview(mixer: mixer), utility: audioUtility)
        case .recording(let url):
            VisualPresenter(
                mode: .recording(
                    url: url,
                    mixer: SaliMixer(signalProcessor: SignalProcessor(processingBufferLength: 256), processingBufferLength: 256)
                ),
                utility: audioUtility
            )
        }
        let view = VisualViewController(presenter: presenter)
        
        presenter.view = view
        
        return view
    }
}
