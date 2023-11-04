//
//  AudioRecorder.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 04.11.2023.
//

import AVFAudio
import Foundation

final class AudioRecorder: NSObject {
    
    // MARK: Public Properties
    weak var delegate: AudioRecorderDelegate?
    
    // MARK: Private Properties
    private let audioSession: AVAudioSession = .sharedInstance()
    private let resonseQueue: DispatchQueue = .main
    private var audioRecorder: AVAudioRecorder?
}

// MARK: - AudioRecorderProtocol
extension AudioRecorder: AudioRecorderProtocol {
    func startRecording(to url: URL) throws {
        
        try audioSession.setCategory(.playAndRecord)
        try audioSession.setActive(true)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        audioRecorder = try AVAudioRecorder(url: url, settings: settings)
        audioRecorder?.delegate = self
        audioRecorder?.record()
    }
    
    func stopRecording() throws {
        guard let audioRecorder else {
            throw AudioRecorderError.noRecordingInProgress
        }
        
        audioRecorder.stop()
        self.audioRecorder = nil
        
        try audioSession.setActive(false)
    }
}

// MARK: - AVAudioRecorderDelegate
extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        resonseQueue.async { [weak self] in
            if flag {
                self?.delegate?.didFinishRecording(with: recorder.url)
            } else {
                self?.delegate?.didEndWithError()
            }
        }
    }
}
