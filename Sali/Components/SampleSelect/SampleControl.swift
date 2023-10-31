//
//  SampleControl.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 31.10.2023.
//

import UIKit

final class SampleControl: UIControl {
    
    // MARK: Private Properties
    private let image: UIImage
    private let imageOffset: CGSize
    
    // MARK: Visual Components
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = image
        
        return imageView
    }()
    
    // MARK: Initializers
    init(frame: CGRect, image: UIImage, imageOffset: CGSize) {
        self.image = image
        self.imageOffset = imageOffset
        super.init(frame: frame)
        
        setupView()
        addSubviews()
    }
    
    convenience init(image: UIImage, imageOffset: CGSize) {
        self.init(frame: .zero, image: image, imageOffset: imageOffset)
    }
    
    convenience init(image: UIImage) {
        self.init(image: image, imageOffset: .zero)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIView
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.sizeToFit()
        imageView.center = CGPoint(x: bounds.center.x + imageOffset.width, y: bounds.center.y + imageOffset.height)
        
        let minimalSide = min(bounds.width, bounds.height)
        layer.cornerRadius = minimalSide / 2.0
    }
}

// MARK: Private Methods
extension SampleControl {
    private func setupView() {
        backgroundColor = .buttons
        layer.masksToBounds = true
    }
    
    private func addSubviews() {
        addSubview(imageView)
    }
}
