//
//  SampleSelectView.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 01.11.2023.
//

import UIKit

final class SampleSelectView: UIView {
    
    // MARK: Public Properties
    weak var delegate: SampleSelectViewDelegate?
    
    // MARK: Private Properties
    let controlLabelSpacing: CGFloat = 8.0
    
    // MARK: Visual Components
    private let sampleControl: SampleControl
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .buttons
        label.textAlignment = .center
        label.numberOfLines = 1
        
        return label
    }()
    
    // MARK: Initializers
    init(frame: CGRect, image: UIImage, imageOffset: CGSize, text: String) {
        sampleControl = SampleControl(image: image, imageOffset: imageOffset)
        super.init(frame: frame)
        sampleControl.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        
        addSubviews()
        label.text = text
    }
    
    convenience init(image: UIImage, imageOffset: CGSize, text: String) {
        self.init(frame: .zero, image: image, imageOffset: imageOffset, text: text)
    }
    
    convenience init(image: UIImage, text: String) {
        self.init(image: image, imageOffset: .zero, text: text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIView
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let controlSize = bounds.width
        
        label.sizeToFit()
        
        if !sampleControl.isAnimatingScale {
            sampleControl.frame = CGRect(x: bounds.minX, y: bounds.minY, width: controlSize, height: controlSize)
            label.frame.origin = CGPoint(x: bounds.midX - (label.frame.width / 2), y: sampleControl.frame.maxY + controlLabelSpacing)
        }
        
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let width = size.width
        
        let sampleControlHeight = width
        let labelHeight = label.sizeThatFits(CGSize(width: width, height: size.height)).height
        let height = sampleControlHeight + controlLabelSpacing  + labelHeight
        
        return CGSize(width: width, height: height)
    }
    
    // MARK: Public Methods
    func populate(with viewModels: [SampleViewModel]) {
        sampleControl.set(options: viewModels)
    }
    
    // MARK: Actions
    @objc private func valueChanged() {
        guard let viewModel = sampleControl.selectedViewModel else { return }
        delegate?.sampleSelectView(self, didSelect: viewModel)
    }
}

// MARK: - Private Methods
extension SampleSelectView {
    private func addSubviews() {
        addSubview(label)
        addSubview(sampleControl)
    }
}
