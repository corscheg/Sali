//
//  LayerTableViewCellViewDelegate.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 04.11.2023.
//

import Foundation

protocol LayerTableViewCellViewDelegate: AnyObject {
    func didTapMute()
    func didTapDelete()
    func didTapPlay()
}
