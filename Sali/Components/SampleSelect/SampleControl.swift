//
//  SampleControl.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 31.10.2023.
//

import UIKit

final class SampleControl: UIControl {
    
    // MARK: Private Properties
    private let constants = Constants()
    private let image: UIImage
    private let imageOffset: CGSize
    private var options: [String] = []
    
    private var heightExpanding: CGFloat = 0.0
    private let heightExpandingKey = "SampleControlHeightExpanding"
    private let longTapThreshold = 0.8
    private var longTapDetectionInProgress = false
    private var longTapInProgress = false
    private var foldingInProgress = false
    
    // MARK: Visual Components
    private lazy var backgroundLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.buttons.cgColor
        
        return layer
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = image
        
        return imageView
    }()
    
    private var optionViews: [SampleControlItemView] = []
    
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
        backgroundLayer.cornerRadius = minimalSide / 2.0
        
        var optionY = bounds.maxY + constants.baseOptionsInset
        
        for optionView in optionViews {
            let desiredSize = optionView.sizeThatFits(
                CGSize(width: bounds.width, height: .greatestFiniteMagnitude)
            )
            
            optionView.frame = CGRect(
                x: bounds.minX,
                y: optionY,
                width: bounds.width,
                height: desiredSize.height
            )
            
            optionY += desiredSize.height
        }
        
        heightExpanding = optionY - bounds.height / 2.0
        
        if !longTapInProgress {
            backgroundLayer.frame = layer.bounds
        }
    }
    
    // MARK: UIControl
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard !foldingInProgress else {
            foldingInProgress = false
            longTapInProgress = true
            expandBackground()
            return true
        }
        
        longTapDetectionInProgress = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + longTapThreshold) {
            guard self.longTapDetectionInProgress else { return }
            self.longTapDetectionInProgress = false
            self.longTapInProgress = true
            self.expandBackground()
        }
        
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        longTapDetectionInProgress = false
        longTapInProgress = false
        foldingInProgress = true
        foldBackground()
    }
    
    override func cancelTracking(with event: UIEvent?) {
        longTapDetectionInProgress = false
        longTapInProgress = false
        foldingInProgress = true
        foldBackground()
    }
    
    // MARK: Public Methods
    func set(options: [String]) {
        self.options = options
        optionViews.forEach { $0.removeFromSuperview() }
        optionViews.removeAll()
        
        optionViews = options.map(SampleControlItemView.init(title:))
        optionViews.forEach(addSubview(_:))
        setNeedsLayout()
    }
}

// MARK: - CAAnimationDelegate
extension SampleControl: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if !longTapInProgress, flag {
            layer.masksToBounds = true
            foldingInProgress = false
        }
    }
}

// MARK: - Private Methods
extension SampleControl {
    private func setupView() {
        backgroundColor = .buttons
        layer.masksToBounds = true
    }
    
    private func addSubviews() {
        layer.addSublayer(backgroundLayer)
        addSubview(imageView)
    }
    
    private func expandBackground() {
        layer.masksToBounds = false
        
        animateBackgroundLayer(to: heightExpanding, color: .accent)
    }
    
    private func foldBackground() {
        animateBackgroundLayer(to: 0.0, color: .buttons)
    }
    
    private func animateBackgroundLayer(to expansionHeight: CGFloat, color: UIColor) {
        let initialBounds: CGRect
        let initialPosition: CGPoint
        let initialColor: CGColor?
        if backgroundLayer.animation(forKey: heightExpandingKey) != nil,
           let presentationLayer = backgroundLayer.presentation() {
            initialBounds = presentationLayer.bounds
            initialPosition = presentationLayer.position
            initialColor = presentationLayer.backgroundColor
            backgroundLayer.removeAnimation(forKey: heightExpandingKey)
        } else {
            initialBounds = backgroundLayer.bounds
            initialPosition = backgroundLayer.position
            initialColor = backgroundLayer.backgroundColor
        }
        
        var finalBounds = bounds
        finalBounds.size.height += expansionHeight
        let finalPosition = finalBounds.center
        
        let boundsAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.bounds))
        boundsAnimation.fromValue = initialBounds
        boundsAnimation.toValue = finalBounds
        
        let positionAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.position))
        positionAnimation.fromValue = initialPosition
        positionAnimation.toValue = finalPosition
        
        let colorAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.backgroundColor))
        colorAnimation.fromValue = initialColor
        colorAnimation.toValue = color.cgColor
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.delegate = self
        groupAnimation.animations = [boundsAnimation, positionAnimation, colorAnimation]
        groupAnimation.duration = 0.2
        groupAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        backgroundLayer.bounds = finalBounds
        backgroundLayer.position = finalPosition
        backgroundLayer.backgroundColor = color.cgColor
        backgroundLayer.add(groupAnimation, forKey: heightExpandingKey)
    }
}

// MARK: - Constants
extension SampleControl {
    private struct Constants {
        let baseOptionsInset: CGFloat = 12.0
    }
}
