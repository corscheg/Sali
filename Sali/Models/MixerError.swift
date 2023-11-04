//
//  MixerError.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 03.11.2023.
//

import Foundation

enum MixerError: Error {
    case faledToPopulateBuffer
    case unitNotFound
    case noRecordingInProgress
}
