//
//  AudioUtilityProtocol.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.12.2023.
//

import Foundation

protocol AudioUtilityProtocol {
    func getDuration(ofFileAt url: URL, completion: @escaping (Double?) -> ())
}
