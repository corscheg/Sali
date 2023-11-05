//
//  NameManagerProtocol.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 05.11.2023.
//

import Foundation

protocol NameManagerProtocol {
    func getName(forType type: LayerType) -> String
    func getNameForRecording() -> String
}
