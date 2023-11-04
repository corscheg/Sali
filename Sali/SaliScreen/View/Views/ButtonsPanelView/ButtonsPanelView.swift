//
//  ButtonsPanelView.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.11.2023.
//

import UIKit

final class ButtonsPanelView: UIView {
    
    // MARK: Public Properties
    weak var delegate: ButtonsPanelViewDelegate?
    
    // MARK: Private Properties
    private let constants = Constants()
    
    // MARK: Visual Components
    private lazy var microphoneButton: MicrophoneButton = {
        let button = MicrophoneButton()
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var recordButton = RecordButton()
    private lazy var playPauseButton: PlayStopButton = {
        let button = PlayStopButton()
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var layersButton: LayersButton = {
        let button = LayersButton()
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        return button
    }()
    
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
        layersButton.frame = CGRect(
            x: bounds.minX,
            y: bounds.minY,
            width: constants.layersButtonWidth,
            height: constants.buttonSize
        )
        
        layersButton.sizeToFit()
        
        let buttonSize = CGSize(width: constants.buttonSize, height: constants.buttonSize)
        playPauseButton.frame = CGRect(
            origin: CGPoint(x: bounds.maxX - constants.buttonSize, y: bounds.minY),
            size: buttonSize
        )
        
        recordButton.frame = CGRect(
            origin: CGPoint(x: playPauseButton.frame.minX - constants.buttonPadding - constants.buttonSize, y: bounds.minY),
            size: buttonSize
        )
        
        microphoneButton.frame = CGRect(
            origin: CGPoint(x: recordButton.frame.minX - constants.buttonPadding - constants.buttonSize, y: bounds.minY),
            size: buttonSize
        )
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        CGSize(width: size.width, height: constants.buttonSize)
    }
    
    // MARK: Public Methods
    func setPlayButtonStop() {
        playPauseButton.set(active: false)
    }
    
    // MARK: Actions
    @objc private func buttonTapped(_ sender: UIButton) {
        if sender === layersButton {
            delegate?.didTapLayersButton()
        } else if sender === playPauseButton {
            delegate?.didTapPlayButton()
        } else if sender === microphoneButton {
            delegate?.didTapMicrophoneButton()
        }
    }
}

// MARK: - Private Methods
extension ButtonsPanelView {
    private func addSubviews() {
        addSubview(layersButton)
        addSubview(microphoneButton)
        addSubview(recordButton)
        addSubview(playPauseButton)
    }
}

// MARK: - Constants
extension ButtonsPanelView {
    private struct Constants {
        let buttonSize: CGFloat = 44.0
        let layersButtonWidth: CGFloat = 74.0
        let buttonPadding: CGFloat = 5.0
    }
}
