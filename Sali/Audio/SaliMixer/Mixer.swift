//
//  Mixer.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 03.11.2023.
//

import Foundation

protocol Mixer {
    func addLayer(withURL url: URL, loops: Bool, andIdentifier identifier: UUID) throws
    func removeLayer(withIdentifier identifier: UUID) throws
    func adjust(parameters: SoundParameters, forLayerAt identifier: UUID)
    func play() throws
    func stop() throws
    func set(muted: Bool, forLayerAt identifier: UUID)
    func playItem(withIdentifier identifier: UUID) throws
    func stopItem(withIdentifier identifier: UUID) throws
    func startRecording(at url: URL) throws
    func stopRecording() throws -> URL
}
