//
//  Mixer.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 03.11.2023.
//

import Foundation

protocol Mixer {
    func add(sample: SampleModel, forKey key: String) throws
    func play() throws
    func stop()
}
