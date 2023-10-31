//
//  SaliViewController.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 31.10.2023.
//

import UIKit

final class SaliViewController: UIViewController {
    
    // MARK: Visual Components
    private lazy var saliView = SaliView()
    
    // MARK: UIViewController
    override func loadView() {
        view = saliView
    }
}
