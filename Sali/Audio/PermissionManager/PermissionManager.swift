//
//  PermissionManager.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 04.11.2023.
//

import AVFAudio
import UIKit

final class PermissionManager {
    
    // MARK: Private Properties
    private let audioSession: AVAudioSession = .sharedInstance()
    private let respondQueue: DispatchQueue = .main
}

// MARK: - PermissionManagerProtocol
extension PermissionManager: PermissionManagerProtocol {
    func performWithPermission(success: @escaping () -> (), failure: @escaping () -> ()) {
        audioSession.requestRecordPermission { [weak self] granted in
            self?.respondQueue.async {
                if granted {
                    success()
                } else {
                    failure()
                }
            }
        }
    }
    
    func requestPermissionInSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
