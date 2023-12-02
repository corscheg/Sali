//
//  AudioUtility.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.12.2023.
//

import AVFoundation

final class AudioUtility {
    private let responseQueue: DispatchQueue = .main
}

// MARK: - AudioUtilityProtocol
extension AudioUtility: AudioUtilityProtocol {
    func getDuration(ofFileAt url: URL, completion: @escaping (Double?) -> ()) {
        let asset = AVAsset(url: url)
        asset.loadTracks(withMediaType: .audio) { [weak self] tracks, error in
            guard let self else { return }
            guard error == nil, let track = tracks?.first else {
                responseQueue.async {
                    completion(nil)
                }
                return
            }
            
            let duration = track.asset?.duration.seconds
            
            responseQueue.async {
                completion(duration)
            }
        }
    }
}
