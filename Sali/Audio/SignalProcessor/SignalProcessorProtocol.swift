//
//  SignalProcessorProtocol.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 04.11.2023.
//

import Foundation

protocol SignalProcessorProtocol {
    func getFrequencies(data: UnsafeMutablePointer<Float>, count: UInt) -> [Float]
}
