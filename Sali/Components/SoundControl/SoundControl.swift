//
//  SoundControl.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 01.11.2023.
//

import UIKit

final class SoundControl: UIControl {
    
    // MARK: Public Properties
    private(set) var output: Output = .zero
    
    // MARK: Private Properties
    private let constants = Constants()
    
    // MARK: Visual Components
    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.locations = [0, 1]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.colors = [UIColor.clear.cgColor, UIColor.field.cgColor]
        
        return layer
    }()
    
    private lazy var volumeScaleView = VolumeScaleView(units: 5, subunits: 5)
    private lazy var tempoScaleView = TempoScaleView(units: 40)
    
    private lazy var volumeMarkerView: SoundControlMarkerView = {
        let view = SoundControlMarkerView(text: "volume")
        view.transform = .init(rotationAngle: 3.0 * .pi / 2.0)
        
        return view
    }()
    
    private lazy var tempoMarkerView = SoundControlMarkerView(text: "tempo")
    
    // MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
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
        
        gradientLayer.frame = bounds
        
        volumeScaleView.frame = CGRect(
            x: bounds.minX,
            y: bounds.minY,
            width: constants.volumeScaleWidth,
            height: bounds.height - constants.volumeScaleBottom
        )
        
        tempoScaleView.frame = CGRect(
            x: bounds.minX + constants.tempoScaleLeading,
            y: bounds.maxY - constants.tempoScaleHeight,
            width: bounds.width - constants.tempoScaleLeading,
            height: constants.tempoScaleHeight
        )
        
        volumeMarkerView.sizeToFit()
        tempoMarkerView.sizeToFit()
        
        updateMarkersPosition(animated: false)
    }
    
    // MARK: UIControl
    override var isEnabled: Bool {
        didSet {
            updateEnabledState()
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            volumeMarkerView.setHighlighted(isHighlighted)
            tempoMarkerView.setHighlighted(isHighlighted)
        }
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        updateOutputWith(touchLocation: location)
        updateMarkersPosition(animated: true)
        
        sendActions(for: .valueChanged)
        
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        updateOutputWith(touchLocation: location)
        updateMarkersPosition(animated: false)
        
        sendActions(for: .valueChanged)
        
        return true
    }
    
    // MARK: Public Methods
    func set(output: Output) {
        self.output = output
        updateMarkersPosition(animated: true)
    }
}

// MARK: - Output
extension SoundControl {
    struct Output {
        
        var volume: Double {
            get {
                _volume
            } set {
                _volume = clamp(value: newValue, min: 0.0, max: 1.0)
            }
        }
        
        var tempo: Double {
            get {
                _tempo
            } set {
                _tempo = clamp(value: newValue, min: 0.0, max: 1.0)
            }
        }
        
        private var _volume: Double
        private var _tempo: Double
        
        static var zero: Output {
            .init(volume: 0.0, tempo: 0.0)
        }
        
        init(volume: Double, tempo: Double) {
            _volume = volume
            _tempo = tempo
        }
    }
}

// MARK: - Private Methods
extension SoundControl {
    private func addSubviews() {
        layer.addSublayer(gradientLayer)
        addSubview(volumeScaleView)
        addSubview(tempoScaleView)
        
        addSubview(volumeMarkerView)
        addSubview(tempoMarkerView)
    }
    
    private func updateMarkersPosition(animated: Bool) {
        let positionOnScaleVolume = volumeScaleView.frame.height * (1.0 - output.volume)
        let volumeMarkerCenterY = positionOnScaleVolume + volumeScaleView.frame.minY
        let volumeMarkerCenterX = volumeScaleView.frame.midX
        
        let positionOnScaleTempo = output.tempo * tempoScaleView.frame.width
        let tempoMarkerCenterX = positionOnScaleTempo + tempoScaleView.frame.minX
        let tempoMarkerCenterY = tempoScaleView.frame.midY
        
        let updates = { [weak self] in
            self?.volumeMarkerView.center = CGPoint(x: volumeMarkerCenterX, y: volumeMarkerCenterY)
            self?.tempoMarkerView.center = CGPoint(x: tempoMarkerCenterX, y: tempoMarkerCenterY)
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut) {
                updates()
            }
        } else {
            updates()
        }
    }
    
    private func updateOutputWith(touchLocation: CGPoint) {
        let yRelativeToScale = touchLocation.y - volumeScaleView.frame.minY
        let volume = 1.0 - (yRelativeToScale / volumeScaleView.frame.height)
        
        let xRelativeToScale = touchLocation.x - tempoScaleView.frame.minX
        let tempo = xRelativeToScale / tempoScaleView.frame.width
        
        output.volume = volume
        output.tempo = tempo
    }
    
    private func animateAccessoriesAlpha(to alphaValue: CGFloat) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut) {
            self.volumeScaleView.alpha = alphaValue
            self.tempoScaleView.alpha = alphaValue
            self.volumeMarkerView.alpha = alphaValue
            self.tempoMarkerView.alpha = alphaValue
        }
    }
    
    private func updateEnabledState() {
        if isEnabled {
            UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseOut) {
                self.animateAccessoriesAlpha(to: 1.0)
                self.alpha = 1.0
            }
        } else {
            UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseOut) {
                self.animateAccessoriesAlpha(to: 0.0)
                self.alpha = 0.6
            }
        }
    }
}

// MARK: - Constants
extension SoundControl {
    private struct Constants {
        let volumeScaleBottom: CGFloat = 26.0
        let volumeScaleWidth: CGFloat = 16.0
        let tempoScaleLeading: CGFloat = 35.0
        let tempoScaleHeight: CGFloat = 14.0
    }
}
