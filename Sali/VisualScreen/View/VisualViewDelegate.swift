//
//  VisualViewDelegate.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.12.2023.
//

import Foundation

protocol VisualViewDelegate: AnyObject {
    func backButtonTapped()
    func saveButtonTapped()
    func rewindTapped()
    func playTapped()
    func toEndTapped()
}
