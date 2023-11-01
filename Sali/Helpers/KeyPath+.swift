//
//  KeyPath+.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 01.11.2023.
//

import Foundation

extension KeyPath where Root: NSObject {
    var stringValue: String {
        NSExpression(forKeyPath: self).keyPath
    }
}
