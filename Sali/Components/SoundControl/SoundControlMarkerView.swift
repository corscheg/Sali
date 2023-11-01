//
//  SoundControlMarkerView.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 01.11.2023.
//

import UIKit

final class SoundControlMarkerView: UIView {
    
    // MARK: Private Properties
    private let constants = Constants()
    
    // MARK: Visual Components
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11.0)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.textColor = .text
        
        return label
    }()
    
    // MARK: Initializers
    init(frame: CGRect, text: String) {
        super.init(frame: frame)
        
        setupView()
        addSubviews()
        label.text = text
    }
    
    convenience init(text: String) {
        self.init(frame: .zero, text: text)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIView
    override func layoutSubviews() {
        super.layoutSubviews()
        
        label.sizeToFit()
        label.frame.origin = CGPoint(x: constants.labelHorizontal, y: constants.labelTop)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let labelSize = label.sizeThatFits(size)
        
        return CGSize(
            width: labelSize.width + constants.labelHorizontal * 2,
            height: labelSize.height + constants.labelTop + constants.labelBottom
        )
    }
}

// MARK: - Private Methods
extension SoundControlMarkerView {
    private func setupView() {
        backgroundColor = .accent
        layer.cornerRadius = 4.0
        layer.cornerCurve = .continuous
    }
    
    private func addSubviews() {
        addSubview(label)
    }
}

// MARK: - Constants
extension SoundControlMarkerView {
    private struct Constants {
        let labelHorizontal: CGFloat = 3.0
        let labelTop: CGFloat = 0.0
        let labelBottom: CGFloat = 1.0
    }
}
