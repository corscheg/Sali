//
//  URLProvider.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 04.11.2023.
//

import Foundation

final class URLProvider {
    
    // MARK: Private Properties
    private let fileManager: FileManager = .default
    private let micRecordingsDirectoryName = "SaliMicRecordings"
}

// MARK: - URLProviderProtocol
extension URLProvider: URLProviderProtocol {
    func urlForMicrophoneRecording() throws -> URL {
        try fileManager.createDirectory(at: micRecordingsDirectory, withIntermediateDirectories: true)
        let fileName = "\(UUID().uuidString).wav"
        
        return micRecordingsDirectory.appendingPathComponent(fileName)
    }
}

// MARK: - Private Methods
extension URLProvider {
    private var temporaryDirectory: URL {
        fileManager.temporaryDirectory
    }
    
    private var micRecordingsDirectory: URL {
        temporaryDirectory.appendingPathComponent(micRecordingsDirectoryName)
    }
}
