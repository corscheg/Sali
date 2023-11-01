//
//  clamp.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 01.11.2023.
//

import Foundation

func clamp<T: Comparable>(value: T, min: T, max: T) -> T {
    return Swift.min(max, Swift.max(min, value))
}
