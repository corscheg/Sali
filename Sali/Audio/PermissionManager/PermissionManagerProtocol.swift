//
//  PermissionManagerProtocol.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 04.11.2023.
//

import Foundation

protocol PermissionManagerProtocol {
    func performWithPermission(success: @escaping () -> (), failure: @escaping () -> ())
    func requestPermissionInSettings()
}
