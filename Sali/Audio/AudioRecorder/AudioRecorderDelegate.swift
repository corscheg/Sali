//
//  AudioRecorderDelegate.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 04.11.2023.
//

import Foundation

protocol AudioRecorderDelegate: AnyObject, Sendable {
    func didFinishRecording(with url: URL)
    func didEndWithError()
}
