//
//  VisualPresenter.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.12.2023.
//

import Foundation

final class VisualPresenter {
    
    // MARK: Public Properties
    weak var view: VisualViewInput?
    
    // MARK: Private Properties
    private let mixer: Mixer
    private var mixerStoredDelegate: MixerDelegate?
    private let mode: Mode
    private var renamedURL: URL?
    private let audioUtility: AudioUtilityProtocol
    private let fileManager: FileManager = .default
    private var isPlaying = false
    private var timer: Timer?
    private var trackDuration: Int?
    private var currentSeconds = 0 {
        didSet {
            view?.setCurrentTime(text: timeString(fromSeconds: currentSeconds))
            
            if let trackDuration, currentSeconds >= trackDuration, isPlaying {
                playTapped()
                view?.setPlayInactive()
            }
        }
    }
    
    // MARK: Initializers
    init(mode: VisualizerModeInternal, utility: AudioUtilityProtocol) {
        self.audioUtility = utility
        switch mode {
        case .preview(mixer: let mixer):
            self.mode = .preview
            self.mixer = mixer
            mixerStoredDelegate = mixer.delegate
            isPlaying = true
        case .recording(url: let url, mixer: let mixer):
            let id = UUID()
            self.mode = .recording(url: url, layerID: id)
            self.mixer = mixer
            try? mixer.addLayer(withURL: url, loops: false, andIdentifier: id)
        }
        
        mixer.delegate = self
    }
}

// MARK: - VisualPresenterProtocol
extension VisualPresenter: VisualPresenterProtocol {
    func viewDidLoad() {
        view?.setCurrentTime(text: "0:00")
        
        switch mode {
        case .preview:
            view?.setDuration(text: "-:--")
            view?.disableSaveButton()
            view?.disablePlaybackControl()
            view?.setRecording(title: nil)
            view?.disableTitle()
            startCurrentTimer()
        case .recording(let url, _):
            audioUtility.getDuration(ofFileAt: url) { [weak self] duration in
                guard let self else { return }
                if let duration {
                    let seconds = Int(duration)
                    trackDuration = seconds
                    view?.setDuration(text: timeString(fromSeconds: seconds))
                }
            }
            
            view?.setRecording(title: url.deletingPathExtension().lastPathComponent)
        }
    }
    
    func backButtonTapped() {
        mixer.delegate = mixerStoredDelegate
        view?.dismiss()
    }
    
    func saveButtonTapped() {
        guard case .recording(let url, _) = mode else { return }
        view?.shareRecording(with: renamedURL ?? url)
    }
    
    func titleChanged(to newTitle: String) {
        guard case .recording(let url, _) = mode else { return }
        let oldTitle = url.deletingPathExtension().lastPathComponent
        guard oldTitle != newTitle else { return }
        
        let newURL = url.deletingLastPathComponent().appendingPathComponent("\(newTitle).wav")
        
        if let renamedURL {
            try? fileManager.removeItem(at: renamedURL)
        }
        
        do {
            try fileManager.copyItem(at: url, to: newURL)
            renamedURL = newURL
        } catch {
            view?.setRecording(title: oldTitle)
        }
    }
    
    func rewindTapped() {
        guard case .recording(_, let layerID) = mode else { return }
        
        stopCurrentTimer()
        startCurrentTimer()
        mixer.restartLayer(withIdentifier: layerID)
    }
    
    func playTapped() {
        guard case .recording(_, let layerID) = mode else { return }
        
        if isPlaying {
            try? mixer.stopItem(withIdentifier: layerID)
            isPlaying = false
            stopCurrentTimer()
        } else {
            try? mixer.playItem(withIdentifier: layerID)
            startCurrentTimer()
            isPlaying = true
            view?.updateVisual(frequencies: [], level: 1.0)
        }
    }
    
    func toEndTapped() {
        guard case .recording = mode else { return }
        
        if let trackDuration {
            currentSeconds = trackDuration
        }
    }
}

// MARK: - MixerDelegate
extension VisualPresenter: MixerDelegate {
    func didPerformMetering(_ result: [Float], level: Float) {
        view?.updateVisual(frequencies: result, level: level)
    }
    
    func didEndPlaying() { }
}

// MARK: - Private Properties
extension VisualPresenter {
    private func timeString(fromSeconds duration: Int) -> String {
        let minutes = duration / 60
        let seconds = duration % 60
        
        let minutesString = String(format: "%d", minutes)
        let secondsString = String(format: "%02d", seconds)
        
        return "\(minutesString):\(secondsString)"
    }
    
    private func startCurrentTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            self?.currentSeconds += 1
        }
    }
    
    private func stopCurrentTimer() {
        timer?.invalidate()
        currentSeconds = 0
        timer = nil
    }
}

// MARK: - Mode
extension VisualPresenter {
    private enum Mode {
        case preview
        case recording(url: URL, layerID: UUID)
    }
}
