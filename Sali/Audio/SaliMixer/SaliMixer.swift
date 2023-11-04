//
//  SaliMixer.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 03.11.2023.
//

import AVFAudio
import Foundation

final class SaliMixer {
    
    // MARK: Public Properties
    weak var delegate: MixerDelegate?
    
    // MARK: Private Properties
    private let signalProcessor: SignalProcessorProtocol
    private let audioSession: AVAudioSession = .sharedInstance()
    private let audioEngine = AVAudioEngine()
    private let mixerNode: AVAudioMixerNode
    private let bypassMixerNode = AVAudioMixerNode()
    private var units: [UUID: PlayingUnit] = [:]
    private var mode: Mode = .still
    private var recordingFile: AVAudioFile?
    
    // MARK: Initializer
    init(signalProcessor: SignalProcessorProtocol) {
        self.signalProcessor = signalProcessor
        self.mixerNode = audioEngine.mainMixerNode
        audioEngine.attach(bypassMixerNode)
        audioEngine.connect(bypassMixerNode, to: mixerNode, format: mixerNode.outputFormat(forBus: 0))
        
        installProcessingTap()
    }
}

// MARK: - Mixer
extension SaliMixer: Mixer {
    func addLayer(withURL url: URL, loops: Bool, andIdentifier identifier: UUID) throws {
        let file = try AVAudioFile(forReading: url)
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
        audioEngine.connect(timeNode, to: bypassMixerNode, format: format)
        
        units[identifier] = PlayingUnit(
            playerNode: playerNode,
            buffer: buffer,
            timingNode: timeNode,
            loops: loops,
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
    
    func startRecording(at url: URL) throws {
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: mixerNode.outputFormat(forBus: 0).sampleRate,
            AVNumberOfChannelsKey: mixerNode.outputFormat(forBus: 0).channelCount
        ]
        
        let file = try AVAudioFile(forWriting: url, settings: settings)
        
        mixerNode.installTap(onBus: 0, bufferSize: 1024, format: mixerNode.outputFormat(forBus: 0)) { buffer, _ in
            do {
                try file.write(from: buffer)
            } catch {
                print(error)
            }
        }
        
        recordingFile = file
    }
    
    func stopRecording() throws -> URL {
        guard let recordingFile else {
            throw MixerError.noRecordingInProgress
        }
        
        mixerNode.removeTap(onBus: 0)
        let url = recordingFile.url
        
        self.recordingFile = nil
        return url
    }
}

// MARK: - PlayingUnit
extension SaliMixer {
    private struct PlayingUnit {
        let playerNode: AVAudioPlayerNode
        let buffer: AVAudioPCMBuffer
        let timingNode: AVAudioUnitTimePitch
        let loops: Bool
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
        
        unit.playerNode.scheduleBuffer(unit.buffer, at: nil, options: unit.loops ? .loops : [])
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
        let powValue = tempo * 2 - 1
        return Float(pow(2, powValue))
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
    
    private func installProcessingTap() {
        bypassMixerNode.installTap(onBus: 0, bufferSize: 1024, format: bypassMixerNode.outputFormat(forBus: 0)) { [weak self] buffer, _ in
            self?.process(buffer: buffer)
        }
    }
    
    private func process(buffer: AVAudioPCMBuffer) {
        
    }
}
