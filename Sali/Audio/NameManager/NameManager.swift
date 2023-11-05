//
//  NameManager.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 05.11.2023.
//

import Foundation

final class NameManager {
    
    // MARK: Private Properties
    private let userDefaults: UserDefaults
    private var nameCounter: [LayerType: Int] = [:]
    private let recordingCounterKey = "SaliRecordingsCount"
    
    // MARK: Initializers
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
}

// MARK: - NameManagerProtocol
extension NameManager: NameManagerProtocol {
    func getName(forType type: LayerType) -> String {
        let count = nameCounter[type, default: 1]
        nameCounter[type] = count + 1
        
        return "\(type.rawValue) \(count)"
    }
    
    func getNameForRecording() -> String {
        let count = userDefaults.integer(forKey: recordingCounterKey)
        userDefaults.setValue(count + 1, forKey: recordingCounterKey)
        
        return "Sali App Recording \(count)"
    }
}
