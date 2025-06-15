//
//  SampleControl.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 31.10.2023.
//

import UIKit

final class SampleControl: UIControl {
    
    // MARK: Public Properties
    private(set) var selectedViewModel: SampleViewModel?
    private(set) var isAnimatingScale = false
    
    // MARK: Private Properties
    private let constants = Constants()
    private let image: UIImage
    private let imageOffset: CGSize
    private var options: [SampleViewModel] = []
    private var currentSelectionYRange: ClosedRange<CGFloat>?
    private var selectedIndex: Int?
    
    private var heightExpanding: CGFloat = 0.0
    private let heightExpandingKey = "SampleControlHeightExpanding"
    private let hoverOpacityKey = "SampleControlHoverOpacity"
    private let longTapThreshold = 0.5
    private var longTapDetectionInProgress = false
    private var longTapInProgress = false
    private var foldingInProgress = false
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    // MARK: Visual Components
    private lazy var backgroundLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.buttons.cgColor
        layer.masksToBounds = true
        
        return layer
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = image
        
        return imageView
    }()
    
    private lazy var selectionHoverLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.backgroundColor = UIColor.clear.cgColor
        let clearColor = UIColor(white: 1.0, alpha: 0.0).cgColor
        let color = UIColor.buttons.cgColor
        layer.colors = [clearColor, color, color, clearColor]
        layer.locations = [0.0, 0.25, 0.75, 1.0]
        layer.startPoint = CGPoint(x: 0.5, y: 0.0)
        layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.opacity = 0.0
        
        return layer
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
        runLongTapAnimation(forward: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + longTapThreshold) {
            guard self.longTapDetectionInProgress else { return }
            self.longTapDetectionInProgress = false
            self.longTapInProgress = true
            self.runLongTapAnimation(forward: false)
            self.expandBackground()
            self.impactGenerator.impactOccurred(intensity: 1.0)
        }
        
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        if let currentSelectionYRange, currentSelectionYRange.contains(location.y) {
            return true
        }
        
        let selectionCandidateIndex = optionViews.firstIndex { optionView in
            optionView.frame.minY < location.y && optionView.frame.maxY > location.y
        }
        
        guard let selectionCandidateIndex else {
            if location.y < optionViews[0].frame.minY {
                selectedIndex = nil
                updateSelectedViewModel()
                updateHover()
            }
            
            return true
        }
        
        selectedIndex = selectionCandidateIndex
        updateSelectedViewModel()
        updateHover()
        
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        commitGesture(sendActions: true)
    }
    
    override func cancelTracking(with event: UIEvent?) {
        commitGesture(sendActions: false)
    }
    
    // MARK: Public Methods
    func set(options: [SampleViewModel]) {
        self.options = options
        optionViews.forEach { $0.removeFromSuperview() }
        optionViews.removeAll()
        
        optionViews = options.map(\.name).map(SampleControlItemView.init(title:))
        optionViews.forEach(addSubview(_:))
        setNeedsLayout()
    }
    
    func set(selectedIndex: Int?) {
        self.selectedIndex = selectedIndex
        updateSelectedViewModel()
    }
}

// MARK: - CAAnimationDelegate
extension SampleControl: CAAnimationDelegate {
    nonisolated func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let name = anim.value(forKey: "name") as? String
        Task {
            await MainActor.run {
                if !longTapInProgress, flag, let name, name == heightExpandingKey {
                    layer.masksToBounds = true
                    foldingInProgress = false
                }
            }
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
        backgroundLayer.addSublayer(selectionHoverLayer)
    }
    
    private func expandBackground() {
        layer.masksToBounds = false
        
        animateBackgroundLayer(to: heightExpanding, color: .accent)
    }
    
    private func foldBackground() {
        animateBackgroundLayer(to: 0.0, color: .buttons)
        selectionHoverLayer.frame = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: 0.0)
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
        groupAnimation.setValue(heightExpandingKey, forKey: "name")
        backgroundLayer.bounds = finalBounds
        backgroundLayer.position = finalPosition
        backgroundLayer.backgroundColor = color.cgColor
        backgroundLayer.add(groupAnimation, forKey: heightExpandingKey)
    }
    
    private func commitGesture(sendActions: Bool) {
        if longTapInProgress {
            foldingInProgress = true
        } else {
            if !options.isEmpty {
                selectedIndex = 0
                updateSelectedViewModel()
                runHintAnimation()
            }
            
            runLongTapAnimation(forward: false)
        }
        
        longTapDetectionInProgress = false
        longTapInProgress = false
        
        if sendActions {
            self.sendActions(for: .valueChanged)
        }
        
        setHover(hidden: true)
        foldBackground()
    }
    
    private func updateSelectedViewModel() {
        guard let selectedIndex else {
            selectedViewModel = nil
            return
        }
        
        selectedViewModel = options[safe: selectedIndex]
    }
    
    private func updateHover() {
        guard let selectedIndex else {
            setHover(hidden: true)
            currentSelectionYRange = nil
            return
        }
        
        guard let selectedOpitonView = optionViews[safe: selectedIndex] else { return }
        setHover(hidden: false)
        impactGenerator.impactOccurred(intensity: 0.6)
        
        selectionHoverLayer.frame = selectedOpitonView.frame
        currentSelectionYRange = selectionHoverLayer.frame.minY...selectionHoverLayer.frame.maxY
    }
    
    private func setHover(hidden: Bool) {
        let finalOpacity: Float = hidden ? 0.0 : 1.0
        
        if finalOpacity == selectionHoverLayer.opacity { return }
        
        let initialOpacity: Float
        
        if selectionHoverLayer.animation(forKey: hoverOpacityKey) != nil,
           let presentationLayer = selectionHoverLayer.presentation() {
            initialOpacity = presentationLayer.opacity
        } else {
            initialOpacity = selectionHoverLayer.opacity
        }
        
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        animation.fromValue = initialOpacity
        animation.toValue = finalOpacity
        animation.duration = 0.2
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        selectionHoverLayer.add(animation, forKey: hoverOpacityKey)
        selectionHoverLayer.opacity = finalOpacity
    }
    
    private func runHintAnimation() {
        let keyTimes: [NSNumber] = [0.0, 0.25, 0.5, 0.75, 1.0]
        let duration = 1.0
        let colorAnimation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.backgroundColor))
        let buttonsColor = UIColor.buttons.cgColor
        let accentColor = UIColor.accent.cgColor
        colorAnimation.values = [buttonsColor, accentColor, buttonsColor, accentColor, buttonsColor]
        colorAnimation.keyTimes = keyTimes
        colorAnimation.duration = duration
        backgroundLayer.add(colorAnimation, forKey: nil)
    }
    
    private func runLongTapAnimation(forward: Bool) {
        isAnimatingScale = true
        if forward {
            UIView.animate(withDuration: longTapThreshold, delay: 0.0, options: .curveEaseOut) {
                self.transform = .init(scaleX: 0.8, y: 0.8)
            } completion: { _ in
                self.isAnimatingScale = false
            }
        } else {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseIn) {
                self.transform = .identity
            } completion: { _ in
                self.isAnimatingScale = false
            }
        }
    }
}

// MARK: - Constants
extension SampleControl {
    private struct Constants {
        let baseOptionsInset: CGFloat = 12.0
    }
}
