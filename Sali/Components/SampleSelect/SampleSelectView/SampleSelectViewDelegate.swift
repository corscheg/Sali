//
//  SampleSelectViewDelegate.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.11.2023.
//

import Foundation

@MainActor
protocol SampleSelectViewDelegate: AnyObject {
    func sampleSelectView(_ sampleSelectView: SampleSelectView, didSelect viewModel: SampleViewModel)
}
