//
//  VisualView.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.12.2023.
//

import UIKit

final class VisualView: UIView {
    
    // MARK: Public Properties
    weak var delegate: VisualViewDelegate?
    
    // MARK: Private Properties
    private let constants = Constants()
    
    // MARK: Visual Components
    private lazy var backButton: IconSaliButton<CALayer, CGFloat> = {
        let button = IconSaliButton<CALayer, CGFloat>()
        button.backgroundColor = .field
        button.setImage(.backIcon, for: .normal)
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var titleTextField: UITextField = {
        let field = UITextField()
        field.font = .systemFont(ofSize: 16.0)
        field.textColor = .buttons
        field.textAlignment = .natural
        field.text = "Recording title"
        field.translatesAutoresizingMaskIntoConstraints = false
        field.tintColor = .accent
        field.addTarget(self, action: #selector(titleChanged), for: .editingDidEnd)
        
        return field
    }()
    
    private lazy var saveButton: IconSaliButton<CALayer, CGFloat> = {
        let button = IconSaliButton<CALayer, CGFloat>()
        button.backgroundColor = .accent
        button.setImage(.saveIcon, for: .normal)
        button.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var unitsView: UnitsView = {
        let view = UnitsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapRecognizer)
        
        return view
    }()
    
    private lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14.0)
        label.textColor = .buttons
        label.textAlignment = .natural
        label.numberOfLines = 1
        label.text = "-:--"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14.0)
        label.textColor = .buttons
        label.textAlignment = .right
        label.numberOfLines = 1
        label.text = "-:--"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var playbackControlView: PlaybackControlView = {
        let view = PlaybackControlView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    // MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        addSubviews()
        makeConstraints()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func setCurrentTime(text: String) {
        currentTimeLabel.text = text
    }
    
    func setDuration(text: String) {
        durationLabel.text = text
    }
    
    func setRecording(title: String?) {
        titleTextField.text = title
    }
    
    func disableTitle() {
        titleTextField.isEnabled = false
    }
    
    func disableSaveButton() {
        saveButton.isEnabled = false
    }
    
    func disablePlaybackControl() {
        playbackControlView.set(enabled: false)
    }
    
    func setPlayInactive() {
        playbackControlView.setPlayInactive()
    }
    
    func updateVisual(frequencies: [Float], level: Float) {
        unitsView.set(level: level)
        unitsView.set(frequencies: frequencies)
    }
    
    // MARK: Actions
    @objc private func didTapBackButton() {
        delegate?.backButtonTapped()
    }
    
    @objc private func didTapSaveButton() {
        delegate?.saveButtonTapped()
    }
    
    @objc private func hideKeyboard() {
        titleTextField.resignFirstResponder()
    }
    
    @objc private func titleChanged() {
        delegate?.titleChanged(to: titleTextField.text ?? "")
    }
}

// MARK: - PlaybackControlViewDelegate
extension VisualView: PlaybackControlViewDelegate {
    func didTapRewind() {
        delegate?.rewindTapped()
    }
    
    func didTapPlayPause() {
        delegate?.playTapped()
    }
    
    func didTapToEnd() {
        delegate?.toEndTapped()
    }
}

// MARK: - Private Methods
extension VisualView {
    private func setupView() {
        backgroundColor = .background
    }
    
    private func addSubviews() {
        addSubview(backButton)
        addSubview(titleTextField)
        addSubview(saveButton)
        addSubview(unitsView)
        addSubview(currentTimeLabel)
        addSubview(durationLabel)
        addSubview(playbackControlView)
    }
    
    private func makeConstraints() {
        let constraints = [
            backButton.widthAnchor.constraint(equalToConstant: constants.buttonSize),
            backButton.heightAnchor.constraint(equalToConstant: constants.buttonSize),
            backButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: constants.topSectionInset),
            backButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: constants.topSectionInset),
            
            saveButton.widthAnchor.constraint(equalToConstant: constants.buttonSize),
            saveButton.heightAnchor.constraint(equalToConstant: constants.buttonSize),
            saveButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -constants.topSectionInset),
            saveButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: constants.topSectionInset),
            
            unitsView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            unitsView.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: constants.unitsInset),
            unitsView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            unitsView.bottomAnchor.constraint(equalTo: currentTimeLabel.topAnchor, constant: -constants.unitsInset),
            
            titleTextField.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: constants.topSectionInset),
            titleTextField.trailingAnchor.constraint(equalTo: saveButton.leadingAnchor, constant: -constants.topSectionInset),
            titleTextField.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            
            currentTimeLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: constants.bottomHorizontalInset),
            currentTimeLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -constants.bottomLabelsInset),
            
            durationLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -constants.bottomHorizontalInset),
            durationLabel.bottomAnchor.constraint(equalTo: currentTimeLabel.bottomAnchor),
            
            playbackControlView.centerXAnchor.constraint(equalTo: centerXAnchor),
            playbackControlView.centerYAnchor.constraint(equalTo: currentTimeLabel.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - Constants
extension VisualView {
    private struct Constants {
        let buttonSize: CGFloat = 44.0
        let topSectionInset: CGFloat = 15.0
        let bottomHorizontalInset: CGFloat = 14.0
        let bottomLabelsInset: CGFloat = 27.0
        let unitsInset: CGFloat = 19.0
    }
}
