//
//  MixerDelegate.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 04.11.2023.
//

import Foundation

protocol MixerDelegate: AnyObject {
    func didPerformMetering(_ result: [Float], level: Float)
    func didEndPlaying() 
}
