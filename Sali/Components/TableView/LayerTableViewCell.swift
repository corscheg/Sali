//
//  LayerTableViewCell.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 01.11.2023.
//

import UIKit

final class LayerTableViewCell: UITableViewCell {
    
    // MARK: Private Properties
    private let constants = Constants()
    
    // MARK: Visual Components
    private lazy var cellView = LayerTableViewCellView()
    
    // MARK: Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
        addSubviews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIView
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cellView.frame = CGRect(
            x: bounds.minX,
            y: bounds.minY + constants.topInset,
            width: bounds.width,
            height: bounds.height - constants.topInset
        )
    }
    
    // MARK: UITableViewCell
    override func setSelected(_ selected: Bool, animated: Bool) {
        cellView.setSelected(selected, animated: animated)
    }
    
    // MARK: Public Methods
    func setup(with viewModel: LayerCellViewModel) {
        cellView.setup(with: viewModel)
    }
}

// MARK: - Private Methods
extension LayerTableViewCell {
    private func setupView() {
        backgroundColor = .clear
        backgroundView = nil
    }
    
    private func addSubviews() {
        contentView.addSubview(cellView)
    }
}

// MARK: - Constants
extension LayerTableViewCell {
    private struct Constants {
        let topInset: CGFloat = 7.0
    }
}
