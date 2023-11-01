//
//  LayerTableViewCellView.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 01.11.2023.
//

import UIKit

final class LayerTableViewCellView: UIView {
    
    // MARK: Private Properties
    private let constants = Constants()
    
    // MARK: Visual Components
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .text
        label.numberOfLines = 1
        label.textAlignment = .natural
        
        return label
    }()
    
    private lazy var playStopButton = PlayStopButton()
    private lazy var muteButton = MuteButton()
    private lazy var deleteButton = DeleteButton()
    
    // MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        addSubviews()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIView
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let buttonSize = CGSize(width: bounds.height, height: bounds.height)
        
        deleteButton.frame = CGRect(
            origin: CGPoint(x: bounds.maxX - buttonSize.width, y: bounds.minY),
            size: buttonSize
        )
        
        muteButton.frame = CGRect(
            origin: CGPoint(x: deleteButton.frame.minX - buttonSize.width, y: bounds.minY),
            size: buttonSize
        )
        
        playStopButton.frame = CGRect(
            origin: CGPoint(x: muteButton.frame.minX - buttonSize.width, y: bounds.minY),
            size: buttonSize
        )
        
        label.sizeToFit()
        
        label.frame = CGRect(
            x: bounds.minX + constants.leftInset,
            y: bounds.midY - label.bounds.height / 2,
            width: bounds.width - bounds.minX - constants.leftInset - playStopButton.frame.minX,
            height: label.bounds.height
        )
    }
    
    // MARK: Public Methods
    func setup(with viewModel: LayerCellViewModel) {
        label.text = viewModel.name
    }
}

// MARK: - Private Methods
extension LayerTableViewCellView {
    private func setupView() {
        backgroundColor = .buttons
        layer.cornerRadius = constants.cornerRadius
        layer.cornerCurve = .continuous
    }
    
    private func addSubviews() {
        addSubview(label)
        addSubview(playStopButton)
        addSubview(muteButton)
        addSubview(deleteButton)
    }
}

// MARK: - Constants
extension LayerTableViewCellView {
    private struct Constants {
        let cornerRadius: CGFloat = 4.0
        let leftInset: CGFloat = 10.0
    }
}
