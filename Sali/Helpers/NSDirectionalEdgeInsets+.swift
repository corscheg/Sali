//
//  NSDirectionalEdgeInsets+.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 01.11.2023.
//

import UIKit

extension NSDirectionalEdgeInsets {
    init(all value: CGFloat) {
        self.init(top: value, leading: value, bottom: value, trailing: value)
    }
}
