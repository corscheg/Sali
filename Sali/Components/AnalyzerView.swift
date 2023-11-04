//
//  AnalyzerView.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 01.11.2023.
//

import UIKit

final class AnalyzerView: UIView {
    
    // MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Public Methods
    func updateMetering(_ metering: [Float]) {
        
    }
}

// MARK: Private Methods
extension AnalyzerView {
    private func setupView() {
        backgroundColor = .accent
        layer.cornerRadius = 8
        layer.cornerCurve = .continuous
    }
}
