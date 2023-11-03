//
//  LayerTableViewCellDelegate.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 04.11.2023.
//

import Foundation

protocol LayerTableViewCellDelegate: AnyObject {
    func layerCellDidTapPlay(_ layerCell: LayerTableViewCell)
    func layerCellDidTapMute(_ layerCell: LayerTableViewCell)
    func layerCellDidTapDelete(_ layerCell: LayerTableViewCell)
}
