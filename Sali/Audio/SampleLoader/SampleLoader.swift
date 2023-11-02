//
//  SampleLoader.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.11.2023.
//

import Foundation

final class SampleLoader {
    
    // MARK: Private Properties
    private let bundle: Bundle
    private let fileManager: FileManager
    private let directoryPathInBundle: String
    private let guitarDirName = "Guitar"
    private let drumsDirName = "Drums"
    private let brassDirName = "Brass"
    
    // MARK: Initializers
    init(
        bundle: Bundle = .main,
        fileManager: FileManager = .default,
        directoryPathInBundle: String = "Samples"
    ) {
        self.bundle = bundle
        self.fileManager = fileManager
        self.directoryPathInBundle = directoryPathInBundle
    }
}

// MARK: - SampleLoaderProtocol
extension SampleLoader: SampleLoaderProtocol {
    func loadSamples() -> SampleBankModel {
        let guitarSamples = getItemsInDirectory(withName: guitarDirName).map(makeSampleModel(from:))
        let drumsSamples = getItemsInDirectory(withName: drumsDirName).map(makeSampleModel(from:))
        let brassSamples = getItemsInDirectory(withName: brassDirName).map(makeSampleModel(from:))
        
        return SampleBankModel(guitarSamples: guitarSamples, drumSamples: drumsSamples, brassSamples: brassSamples)
    }
}

// MARK: - Private Methods
extension SampleLoader {
    private var directoryURL: URL {
        bundle.bundleURL.appendingPathComponent(directoryPathInBundle, isDirectory: true)
    }
    
    private func getItemsInDirectory(withName name: String) -> [URL] {
        let subdirectoryURL = directoryURL.appendingPathComponent(name)
        
        do {
            let urls = try fileManager.contentsOfDirectory(
                at: subdirectoryURL,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles
            )
            
            let musicURLs = urls.filter { url in
                url.pathExtension == "wav"
            }
            
            return musicURLs
        } catch {
            return []
        }
    }
    
    private func makeSampleModel(from url: URL) -> SampleModel {
        let name = url.lastPathComponent
        let group = url.deletingLastPathComponent().lastPathComponent
        let displayName = name.components(separatedBy: ".").dropLast().joined()
        return SampleModel(name: displayName, identifier: "\(group)-\(name)", url: url)
    }
}
