//
//  Mixer.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 03.11.2023.
//

import Foundation

protocol Mixer {
    func addLayer(withSample sample: SampleModel, andIdentifier identifier: UUID) throws
    func removeLayer(withIdentifier identifier: UUID) throws
    func adjust(parameters: SoundParameters, forLayerAt identifier: UUID)
    func play() throws
    func stop() throws
    func set(muted: Bool, forLayerAt identifier: UUID)
}
