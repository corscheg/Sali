//
//  LayerModel.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 03.11.2023.
//

import Foundation

struct LayerModel {
    let identifier: UUID
    let name: String
    var isPlaying: Bool
    var isMuted: Bool
    var parameters = SoundParameters()
}
