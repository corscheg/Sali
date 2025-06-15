//
//  AudioUtility.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.12.2023.
//

import AVFoundation

final class AudioUtility {
}

// MARK: - AudioUtilityProtocol
extension AudioUtility: AudioUtilityProtocol {
    func getDuration(ofFileAt url: URL) async -> Double? {
        let asset = AVAsset(url: url)
        
        do {
            let tracks = try await asset.loadTracks(withMediaType: .audio)
            guard let track = tracks.first else {
                throw NSError()
            }
            
            return try await track.asset?.load(.duration).seconds
        } catch {
            return nil
        }
    }
}
