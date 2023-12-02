//
//  PlaybackControlView.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.12.2023.
//

import UIKit

final class PlaybackControlView: UIStackView {
    
    // MARK: Public Properties
    weak var delegate: PlaybackControlViewDelegate?
    
    // MARK: Visual Components
    private lazy var rewindButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setImage(.rewindIcon, for: .normal)
        button.addTarget(self, action: #selector(rewindTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var playButton: PlayStopButton = {
        let button = PlayStopButton()
        button.backgroundColor = .clear
        button.playStopIconLayer.fillColor = UIColor.accent.cgColor
        button.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var toEndButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setImage(.toEndIcon, for: .normal)
        button.addTarget(self, action: #selector(toEndTapped), for: .touchUpInside)
        
        return button
    }()
    
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
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Public Methods
    func set(enabled: Bool) {
        rewindButton.isEnabled = enabled
        playButton.isEnabled = enabled
        toEndButton.isEnabled = enabled
    }
    
    func setPlayInactive() {
        playButton.set(active: false)
    }
    
    // MARK: Actions
    @objc private func rewindTapped() {
        delegate?.didTapRewind()
    }
    
    @objc private func playPauseTapped() {
        delegate?.didTapPlayPause()
    }
    
    @objc private func toEndTapped() {
        delegate?.didTapToEnd()
    }
}

// MARK: - Private Methods
extension PlaybackControlView {
    private func setupView() {
        axis = .horizontal
        spacing = 0
        distribution = .fillEqually
        alignment = .fill
    }
    
    private func addSubviews() {
        addArrangedSubview(rewindButton)
        addArrangedSubview(playButton)
        addArrangedSubview(toEndButton)
    }
}
