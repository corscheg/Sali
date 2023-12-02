//
//  VisualPresenterProtocol.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.12.2023.
//

import Foundation

protocol VisualPresenterProtocol {
    func viewDidLoad()
    func backButtonTapped()
    func saveButtonTapped()
    func titleChanged(to newTitle: String)
    func rewindTapped()
    func playTapped()
    func toEndTapped()
}
