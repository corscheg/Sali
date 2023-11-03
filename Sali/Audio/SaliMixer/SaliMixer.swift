//
//  SaliMixer.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 03.11.2023.
//

import AVFAudio
import Foundation

final class SaliMixer {
    
    // MARK: Private Properties
    private let audioSession: AVAudioSession = .sharedInstance()
    private let audioEngine = AVAudioEngine()
    private let mixerNode: AVAudioMixerNode
    private var units: [UUID: PlayingUnit] = [:]
    
    // MARK: Initializer
    init() {
        self.mixerNode = audioEngine.mainMixerNode
    }
}

// MARK: - Mixer
extension SaliMixer: Mixer {
    func addLayer(withSample sample: SampleModel, andIdentifier identifier: UUID) throws {
        let file = try AVAudioFile(forReading: sample.url)
        let format = file.processingFormat
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(file.length))
        
        guard let buffer else {
            throw MixerError.faledToPopulateBuffer
        }
        
        try file.read(into: buffer)
        
        let playerNode = AVAudioPlayerNode()
        audioEngine.attach(playerNode)
        
        let timeNode = AVAudioUnitTimePitch()
        audioEngine.attach(timeNode)
        
        audioEngine.connect(playerNode, to: timeNode, format: format)
        audioEngine.connect(timeNode, to: mixerNode, format: format)
        
        units[identifier] = PlayingUnit(sample: sample, playerNode: playerNode, buffer: buffer, timingNode: timeNode)
        
        if audioEngine.isRunning {
            populatePlayer(withIdentifier: identifier)
            playerNode.play()
        }
    }
    
    func removeLayer(withIdentifier identifier: UUID) throws {
        guard let unit = units.removeValue(forKey: identifier) else {
            throw MixerError.unitNotFound
        }
        
        unit.playerNode.stop()
        
        audioEngine.disconnectNodeOutput(unit.playerNode)
        audioEngine.disconnectNodeOutput(unit.timingNode)
        
        audioEngine.detach(unit.playerNode)
        audioEngine.detach(unit.timingNode)
    }
    
    func adjust(parameters: SoundParameters, forLayerAt identifier: UUID) {
        guard let unit = units[identifier] else { return }
        
        unit.playerNode.volume = Float(parameters.volume)
        unit.timingNode.rate = getRateFrom(tempo: parameters.tempo)
    }
    
    func play() throws {
        populatePlayers()
        
        try audioSession.setCategory(.playback)
        try audioSession.setActive(true)
        
        audioEngine.prepare()
        try audioEngine.start()
        units.values.map(\.playerNode).forEach {
            $0.play()
        }
    }
    
    func stop() throws {
        stopPlayers()
        audioEngine.stop()
        
        try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
    }
}

// MARK: - PlayingUnit
extension SaliMixer {
    private struct PlayingUnit {
        let sample: SampleModel
        let playerNode: AVAudioPlayerNode
        let buffer: AVAudioPCMBuffer
        let timingNode: AVAudioUnitTimePitch
    }
}

// MARK: - Private Methods
extension SaliMixer {
    private func populatePlayers() {
        units.keys.forEach(populatePlayer(withIdentifier:))
    }
    
    private func stopPlayers() {
        units.values.map(\.playerNode).forEach { node in
            node.stop()
        }
    }
    
    private func populatePlayer(withIdentifier identifier: UUID) {
        guard let unit = units[identifier] else { return }
        
        unit.playerNode.scheduleBuffer(unit.buffer, at: nil, options: .loops)
    }
    
    private func getRateFrom(tempo: Double) -> Float {
        Float(tempo * 1.5 + 0.5)                            // convert 0.0...1.0 range into 0.5...2.0
    }
}
