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
    private var mode: Mode = .still
    
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
        
        units[identifier] = PlayingUnit(
            sample: sample,
            playerNode: playerNode,
            buffer: buffer,
            timingNode: timeNode,
            mutedState: .playing
        )
        
        if audioEngine.isRunning, case .all = mode {
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
        
        switch unit.mutedState {
        case .playing:
            unit.playerNode.volume = Float(parameters.volume)
        case .muted:
            units[identifier]?.mutedState = .muted(storedVolume: Float(parameters.volume))
        }
        
        unit.timingNode.rate = getRateFrom(tempo: parameters.tempo)
    }
    
    func play() throws {
        
        switch mode {
        case .still:
            populatePlayers()
            try startSession()
            try startEngine()
            playUnits()
        case .all:
            break
        case .some(playingUnits: let playingIDs):
            playingIDs.forEach(stopPlayer(withIdentifier:))
            
            populatePlayers()
            playUnits()
        }
        
        mode = .all
    }
    
    func stop() throws {
        stopPlayers()
        stopEngine()
        
        try stopSession()
        mode = .still
    }
    
    func set(muted: Bool, forLayerAt identifier: UUID) {
        guard let unit = units[identifier] else { return }
        
        if muted {
            units[identifier]?.mutedState = .muted(storedVolume: unit.playerNode.volume)
            unit.playerNode.volume = 0.0
        } else {
            guard case let .muted(storedVolume) = unit.mutedState else { return }
            unit.playerNode.volume = storedVolume
            units[identifier]?.mutedState = .playing
        }
    }
    
    func playItem(withIdentifier identifier: UUID) throws {
        switch mode {
        case .still:
            populatePlayer(withIdentifier: identifier)
            try startSession()
            try startEngine()
            playUnit(withIdentifier: identifier)
            mode = .some(playingUnits: [identifier])
        case .all:
            stopPlayers()
            populatePlayer(withIdentifier: identifier)
            playUnit(withIdentifier: identifier)
            mode = .some(playingUnits: [identifier])
        case .some(playingUnits: let playingUnits):
            populatePlayer(withIdentifier: identifier)
            playUnit(withIdentifier: identifier)
            mode = .some(playingUnits: playingUnits.union([identifier]))
        }
    }
    
    func stopItem(withIdentifier identifier: UUID) throws {
        switch mode {
        case .still:
            break
        case .all:
            break
        case .some(playingUnits: let playingUnits):
            stopPlayer(withIdentifier: identifier)
            let newPlayingUnits = playingUnits.subtracting([identifier])
            if newPlayingUnits.isEmpty {
                stopEngine()
                try stopSession()
                mode = .still
            } else {
                mode = .some(playingUnits: newPlayingUnits)
            }
        }
    }
}

// MARK: - PlayingUnit
extension SaliMixer {
    private struct PlayingUnit {
        let sample: SampleModel
        let playerNode: AVAudioPlayerNode
        let buffer: AVAudioPCMBuffer
        let timingNode: AVAudioUnitTimePitch
        var mutedState: MutedState
    }
    
    private enum MutedState {
        case playing
        case muted(storedVolume: Float)
    }
}

// MARK: - Mode
extension SaliMixer {
    private enum Mode {
        case still
        case all
        case some(playingUnits: Set<UUID>)
    }
}

// MARK: - Private Methods
extension SaliMixer {
    private func populatePlayers() {
        units.keys.forEach(populatePlayer(withIdentifier:))
    }
    
    private func playUnits() {
        units.keys.forEach(playUnit(withIdentifier:))
    }
    
    private func stopPlayers() {
        units.keys.forEach(stopPlayer(withIdentifier:))
    }
    
    private func populatePlayer(withIdentifier identifier: UUID) {
        guard let unit = units[identifier] else { return }
        
        unit.playerNode.scheduleBuffer(unit.buffer, at: nil, options: .loops)
    }
    
    private func playUnit(withIdentifier identifier: UUID) {
        guard let unit = units[identifier] else { return }
        
        unit.playerNode.play()
    }
    
    private func stopPlayer(withIdentifier identifier: UUID) {
        guard let unit = units[identifier] else { return }
        unit.playerNode.stop()
    }
    
    private func getRateFrom(tempo: Double) -> Float {
        Float(tempo * 1.5 + 0.5)                            // convert 0.0...1.0 range into 0.5...2.0
    }
    
    private func startSession() throws {
        try audioSession.setCategory(.playback)
        try audioSession.setActive(true)
    }
    
    private func startEngine() throws {
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    private func stopSession() throws {
        try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
    }
    
    private func stopEngine() {
        audioEngine.stop()
    }
}
