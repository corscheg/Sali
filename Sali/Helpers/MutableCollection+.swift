//
//  MutableCollection+.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.11.2023.
//

import Foundation

extension MutableCollection {
    subscript(safe index: Index) -> Element? {
        get {
            guard index >= startIndex && index < endIndex else { return nil }
            return self[index]
        } mutating set {
            guard index >= startIndex && index < endIndex, let newValue else { return }
            self[index] = newValue
        }
    }
}
