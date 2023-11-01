//
//  LayersTableView.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 01.11.2023.
//

import UIKit

final class LayersTableView: UITableView {
    
    // MARK: Initializers
    init(frame: CGRect, style: UITableView.Style, delegate: UITableViewDelegate) {
        super.init(frame: frame, style: style)
        
        self.delegate = delegate
        
        setupView()
    }
    
    convenience init(delegate: UITableViewDelegate) {
        self.init(frame: .zero, style: .plain, delegate: delegate)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Methods
extension LayersTableView {
    private func setupView() {
        backgroundColor = .clear
        showsVerticalScrollIndicator = false
        contentInsetAdjustmentBehavior = .never
        separatorStyle = .none
        alwaysBounceVertical = false
    }
}
