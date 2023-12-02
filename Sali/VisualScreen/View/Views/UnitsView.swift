//
//  UnitsView.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.12.2023.
//

import UIKit

final class UnitsView: UIView {
    
    // MARK: Visual Components
    private lazy var units: [UIImage] = [.aunit8, .aunit3, .aunit2, .aunit4, .aunit5, .aunit6, .aunit7, .aunit1, .aunit9, .aunit10, .aunit11, .aunit12, .aunit13, .aunit14]
    
    private lazy var imageViews = units.map { image in
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.image = image
        
        return imageView
    }
    
    private lazy var centers: [CGPoint] = (imageViews.startIndex ..< imageViews.endIndex).map { _ in
        CGPoint(x: .random(in: 0.0 ... 1.0), y: .random(in: 0.0 ... 1.0))
    }
    
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
        
        for i in (imageViews.startIndex ..< imageViews.endIndex) {
            imageViews[i].center = CGPoint(x: (bounds.width * centers[i].x) + bounds.minX, y: (bounds.height * centers[i].y) + bounds.minY)
        }
    }
    
    // MARK: Public Methods
    func set(level: Float) {
        imageViews.forEach { imageView in
            let transform = imageView.transform
            let scaleX = sqrt(pow(transform.a, 2) + pow(transform.c, 2))
            let scaleY = sqrt(pow(transform.b, 2) + pow(transform.d, 2))
            let concScaleX = CGFloat(level) / scaleX
            let concScaleY = CGFloat(level) / scaleY
            
            let concTransform: CGAffineTransform = .init(scaleX: concScaleX, y: concScaleY)
            
            imageView.transform = transform.concatenating(concTransform)
        }
    }
    
    func set(frequencies: [Float]) {
        let binsByUnit = frequencies.count / imageViews.count
        let normalizedFrequencies = (imageViews.startIndex ..< imageViews.endIndex).map { index in
            let binsOfUnitSlice = frequencies[binsByUnit * index ..< (binsByUnit * index) + binsByUnit]
            let binsOfUnit = Array(binsOfUnitSlice)
            
            let average = binsOfUnit.reduce(0.0) { $0 + $1 / Float(binsOfUnit.count) }
            
            return average
        }
        
        let radians = normalizedFrequencies.map { level in
            (level - 0.5) * .pi / 2.0
        }
        
        for i in imageViews.startIndex ..< imageViews.endIndex {
            let transform = imageViews[i].transform
            let angle = atan2f(Float(transform.b), Float(transform.a))
            let desiredAngle = radians[i]
            let concatAngle = desiredAngle - angle
            let concatTransform = CGAffineTransform(rotationAngle: CGFloat(concatAngle))
            imageViews[i].transform = transform.concatenating(concatTransform)
        }
    }
}

// MARK: - Private Methods
extension UnitsView {
    private func setupView() {
        backgroundColor = .clear
        clipsToBounds = true
    }
    
    private func addSubviews() {
        imageViews.forEach(addSubview(_:))
    }
}
