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
    private var units: [String: PlayingUnit] = [:]
    
    // MARK: Initializer
    init() {
        self.mixerNode = audioEngine.mainMixerNode
    }
}

// MARK: - Mixer
extension SaliMixer: Mixer {
    func add(sample: SampleModel, forKey key: String) throws {
        let file = try AVAudioFile(forReading: sample.url)
        let format = file.processingFormat
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(file.length))
        
        #warning("ADD CUSTOM ERROR THROWING")
        guard let buffer else { return }
        try file.read(into: buffer)
        
        let playerNode = AVAudioPlayerNode()
        audioEngine.attach(playerNode)
        
        let timeNode = AVAudioUnitTimePitch()
        audioEngine.attach(timeNode)
        
        audioEngine.connect(playerNode, to: timeNode, format: format)
        audioEngine.connect(timeNode, to: mixerNode, format: format)
        
        units[key] = PlayingUnit(sample: sample, playerNode: playerNode, buffer: buffer, timingNode: timeNode)
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
    
    func stop() {
        stopPlayers()
        audioEngine.stop()
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
        units.values.forEach { unit in
            unit.playerNode.scheduleBuffer(unit.buffer, at: nil, options: .loops)
        }
    }
    
    private func stopPlayers() {
        units.values.map(\.playerNode).forEach { node in
            node.stop()
        }
    }
}
