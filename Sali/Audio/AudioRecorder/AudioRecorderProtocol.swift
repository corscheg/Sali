//
//  AudioRecorderProtocol.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 04.11.2023.
//

import Foundation

protocol AudioRecorderProtocol {
    func startRecording(to url: URL) throws
    func stopRecording() throws
}
