//
//  SaliViewInput.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.11.2023.
//

import Foundation

protocol SaliViewInput: AnyObject {
    func showLayersTable()
    func hideLayersTable()
    func populateLayersTable(with viewModels: [LayerCellViewModel])
}
