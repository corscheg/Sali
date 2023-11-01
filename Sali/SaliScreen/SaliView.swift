//
//  SaliView.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 31.10.2023.
//

import UIKit

final class SaliView: UIView {
    
    // MARK: Private Properties
    private let constants = Constants()
    
    // MARK: Visual Components
    private lazy var guitarSelectView: SampleSelectView = {
        let view = SampleSelectView(image: .instrumentGuitar, imageOffset: CGSize(width: 0, height: 10), text: "guitar")
        
        return view
    }()
    
    private lazy var drumsSelectView: SampleSelectView = {
        let view = SampleSelectView(image: .instrumentDrums, text: "drums")
        
        return view
    }()
    
    private lazy var brassSelectView: SampleSelectView = {
        let view = SampleSelectView(image: .instrumentBrass, imageOffset: CGSize(width: -1, height: 1), text: "brass")
        
        return view
    }()
    
    private lazy var soundControl = SoundControl()
    
    private lazy var analyzerView = AnalyzerView()
    
    private lazy var layersButton = LayersButton()
    private lazy var microphoneButton = MicrophoneButton()
    private lazy var recordButton = RecordButton()
    private lazy var playPauseButton = PlayStopButton()
    
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
        
        layoutInstrumentsSelection()
        layoutButtons()
        layoutAnalyzer()
        layoutSoundControl()
    }
}

// MARK: - Private Methods
extension SaliView {
    private func setupView() {
        backgroundColor = .background
        
        directionalLayoutMargins = NSDirectionalEdgeInsets(all: constants.margin)
    }
    
    private func addSubviews() {
        addSubview(guitarSelectView)
        addSubview(drumsSelectView)
        addSubview(brassSelectView)
        
        addSubview(soundControl)
        
        addSubview(analyzerView)
        
        addSubview(layersButton)
        addSubview(microphoneButton)
        addSubview(recordButton)
        addSubview(playPauseButton)
    }
    
    private func layoutInstrumentsSelection() {
        let instrumentSelectWidth = (bounds.width - directionalLayoutMargins.leading - directionalLayoutMargins.trailing) / 5
        let instrumentSelectPadding = instrumentSelectWidth
        let instrumentSelectY = bounds.minY + directionalLayoutMargins.top
        
        #warning("BAD")
        let instrumentSelectHeight = [guitarSelectView, drumsSelectView, brassSelectView]
            .map { $0.sizeThatFits(CGSize(width: instrumentSelectWidth, height: .greatestFiniteMagnitude)) }
            .map(\.height)
            .max()
        
        guard let instrumentSelectHeight else { return }
        
        let instrumentSelectSize = CGSize(width: instrumentSelectWidth, height: instrumentSelectHeight)
        
        guitarSelectView.frame = CGRect(
            origin: CGPoint(x: bounds.minX + directionalLayoutMargins.leading, y: instrumentSelectY),
            size: instrumentSelectSize
        )
        
        drumsSelectView.frame = CGRect(
            origin: CGPoint(x: guitarSelectView.frame.maxX + instrumentSelectPadding, y: instrumentSelectY),
            size: instrumentSelectSize
        )
        
        brassSelectView.frame = CGRect(
            origin: CGPoint(x: drumsSelectView.frame.maxX + instrumentSelectPadding, y: instrumentSelectY),
            size: instrumentSelectSize
        )
    }
    
    private func layoutSoundControl() {
        let y = guitarSelectView.frame.maxY + constants.instrumentsSoundControlSpacing
        soundControl.frame = CGRect(
            x: bounds.minX + directionalLayoutMargins.leading,
            y: y,
            width: bounds.width - directionalLayoutMargins.leading - directionalLayoutMargins.trailing,
            height: analyzerView.frame.minY - constants.soundControlAnalyzerSpacing - y
        )
    }
    
    private func layoutAnalyzer() {
        analyzerView.frame = CGRect(
            x: bounds.minX + directionalLayoutMargins.leading,
            y: layersButton.frame.minY - constants.buttonsAnalyzerSpacing - constants.buttonSize,
            width: bounds.width - directionalLayoutMargins.leading - directionalLayoutMargins.trailing,
            height: constants.buttonSize
        )
    }
    
    private func layoutButtons() {
        let buttonsY = bounds.maxY - directionalLayoutMargins.bottom - constants.buttonSize
        layersButton.frame = CGRect(
            x: bounds.minX + directionalLayoutMargins.leading,
            y: buttonsY,
            width: constants.layersButtonWidth,
            height: constants.buttonSize
        )
        
        let buttonSize = CGSize(width: constants.buttonSize, height: constants.buttonSize)
        playPauseButton.frame = CGRect(
            origin: CGPoint(x: bounds.maxX - directionalLayoutMargins.trailing - constants.buttonSize, y: buttonsY),
            size: buttonSize
        )
        
        recordButton.frame = CGRect(
            origin: CGPoint(x: playPauseButton.frame.minX - constants.buttonPadding - constants.buttonSize, y: buttonsY),
            size: buttonSize
        )
        
        microphoneButton.frame = CGRect(
            origin: CGPoint(x: recordButton.frame.minX - constants.buttonPadding - constants.buttonSize, y: buttonsY),
            size: buttonSize
        )
    }
}

// MARK: - Constants
extension SaliView {
    private struct Constants {
        let margin: CGFloat = 15.0
        let instrumentsSoundControlSpacing: CGFloat = 38.0
        let soundControlAnalyzerSpacing: CGFloat = 13.0
        let buttonsAnalyzerSpacing: CGFloat = 10.0
        let buttonSize: CGFloat = 44.0
        let layersButtonWidth: CGFloat = 74.0
        let buttonPadding: CGFloat = 5.0
    }
}
