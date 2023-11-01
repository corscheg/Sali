//
//  SampleControlItemView.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.11.2023.
//

import UIKit

final class SampleControlItemView: UIView {
    
    // MARK: Private Properties
    private let constants = Constants()
    
    // MARK: Visual Components
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12.0)
        label.textColor = .text
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    // MARK: Initializers
    init(frame: CGRect, title: String) {
        super.init(frame: frame)
        
        setupView()
        addSubviews()
        label.text = title
    }
    
    convenience init(title: String) {
        self.init(frame: .zero, title: title)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIView
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let widthForLabel = bounds.width - constants.horizontalInset * 2.0
        let labelSize = label.sizeThatFits(CGSize(width: widthForLabel, height: .greatestFiniteMagnitude))
        let labelOrigin = CGPoint(x: bounds.midX - labelSize.width / 2.0, y: bounds.minY + constants.topInset)
        
        label.frame = CGRect(origin: labelOrigin, size: labelSize)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let sizeForLabel = label.sizeThatFits(
            CGSize(
                width: size.width - constants.horizontalInset * 2.0,
                height: size.height - constants.topInset - constants.bottomInset
            )
        )
        
        return CGSize(
            width: sizeForLabel.width + constants.horizontalInset * 2.0,
            height: sizeForLabel.height + constants.topInset + constants.bottomInset
        )
    }
}

// MARK: - Private Methods
extension SampleControlItemView {
    private func setupView() {
        isUserInteractionEnabled = false
    }
    
    private func addSubviews() {
        addSubview(label)
    }
}

// MARK: - Constants
extension SampleControlItemView {
    private struct Constants {
        let horizontalInset: CGFloat = 8.0
        let topInset: CGFloat = 11.0
        let bottomInset: CGFloat = 14.0
    }
}
