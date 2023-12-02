//
//  PlaybackControlViewDelegate.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.12.2023.
//

import Foundation

protocol PlaybackControlViewDelegate: AnyObject {
    func didTapRewind()
    func didTapPlayPause()
    func didTapToEnd()
}
