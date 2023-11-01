//
//  SampleSelectView.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 01.11.2023.
//

import UIKit

final class SampleSelectView: UIView {
    
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
        sampleControl.set(options: ["sample 1", "sample 2", "sample 3"])
        super.init(frame: frame)
        
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
        sampleControl.frame = CGRect(x: bounds.minX, y: bounds.minY, width: controlSize, height: controlSize)
        
        label.sizeToFit()
        
        label.frame.origin = CGPoint(x: bounds.midX - (label.frame.width / 2), y: sampleControl.frame.maxY + controlLabelSpacing)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let width = size.width
        
        let sampleControlHeight = width
        let labelHeight = label.sizeThatFits(CGSize(width: width, height: size.height)).height
        let height = sampleControlHeight + controlLabelSpacing  + labelHeight
        
        return CGSize(width: width, height: height)
    }
}

// MARK: - Private Methods
extension SampleSelectView {
    private func addSubviews() {
        addSubview(label)
        addSubview(sampleControl)
    }
}
