//
//  VisualViewInput.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.12.2023.
//

import Foundation

protocol VisualViewInput: AnyObject {
    func setCurrentTime(text: String)
    func setDuration(text: String)
    func disableSaveButton()
    func disablePlaybackControl()
    func setPlayInactive()
    func dismiss()
}
