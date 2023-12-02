//
//  VisualizerMode.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.12.2023.
//

import Foundation

enum VisualizerMode {
    case preview(mixer: Mixer)
    case recording(url: URL)
}
