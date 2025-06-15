//
//  PermissionManager.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 04.11.2023.
//

import AVFAudio
import UIKit

final class PermissionManager {
    
    enum Error: Swift.Error {
        case permissionNotGranted
    }
    
    // MARK: Private Properties
    private let audioSession: AVAudioSession = .sharedInstance()
    private let respondQueue: DispatchQueue = .main
}

// MARK: - PermissionManagerProtocol
extension PermissionManager: PermissionManagerProtocol {
    func checkPermission() async throws {
        if await requestPersmission() {
            return
        } else {
            throw Error.permissionNotGranted
        }
    }
    
    private func requestPersmission() async -> Bool {
        await withCheckedContinuation { continuation in
            audioSession.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
    
    func requestPermissionInSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        Task { @MainActor in
            UIApplication.shared.open(url)
        }
    }
}
