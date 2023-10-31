//
//  CGRect+.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 01.11.2023.
//

import Foundation

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}
