//
//  URLProviderProtocol.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 04.11.2023.
//

import Foundation

protocol URLProviderProtocol {
    func getURLForMicrophoneRecording() throws -> URL
    func getURLForRecord(withFilename filename: String) -> URL
}
