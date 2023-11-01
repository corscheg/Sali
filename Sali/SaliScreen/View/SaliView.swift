//
//  SaliView.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 31.10.2023.
//

import UIKit

final class SaliView: UIView {
    
    private typealias DataSource = UITableViewDiffableDataSource<Section, LayerCellViewModel>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, LayerCellViewModel>
    
    // MARK: Public Properties
    weak var delegate: SaliViewDelegate?
    
    // MARK: Private Properties
    private let constants = Constants()
    private lazy var dataSource: DataSource = {
        let dataSource = DataSource(tableView: layersTableView) { tableView, indexPath, viewModel in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: LayerTableViewCell.reuseIdentifier,
                for: indexPath
            ) as! LayerTableViewCell
            
            cell.transform = .init(scaleX: 1.0, y: -1.0)
            cell.setup(with: viewModel)
            
            return cell
        }
        
        return dataSource
    }()
    
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
    
    private lazy var microphoneButton = MicrophoneButton()
    private lazy var recordButton = RecordButton()
    private lazy var playPauseButton = PlayStopButton()
    private lazy var layersButton: LayersButton = {
        let button = LayersButton()
        button.addTarget(self, action: #selector(layersButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var layersTableView: LayersTableView = {
        let tableView = LayersTableView(delegate: self)
        tableView.alpha = 0.0
        tableView.transform = .init(scaleX: 1.0, y: -1.0)
        tableView.rowHeight = constants.layersTableViewCellHeight
        tableView.register(LayerTableViewCell.self, forCellReuseIdentifier: LayerTableViewCell.reuseIdentifier)
        tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: safeAreaInsets.top, right: 0.0)
        
        return tableView
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
        layoutTableView()
    }
    
    override func safeAreaInsetsDidChange() {
        layersTableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: safeAreaInsets.top, right: 0.0)
    }
    
    // MARK: Public Methods
    func showLayersTable() {
        soundControl.hideAccessories()
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut) {
            self.layersTableView.alpha = 1.0
            self.analyzerView.alpha = 0.0
        }
    }
    
    func hideLayersTable() {
        soundControl.showAccessories()
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut) {
            self.layersTableView.alpha = 0.0
            self.analyzerView.alpha = 1.0
        }
    }
    
    func populateLayersTable(with viewModels: [LayerCellViewModel]) {
        var snapshot = Snapshot()
        
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModels, toSection: .main)
        
        dataSource.apply(snapshot)
    }
    
    // MARK: Actions
    @objc private func layersButtonTapped() {
        delegate?.didTapLayersButton()
    }
}

// MARK: - UITableViewDelegate
extension SaliView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
        
        addSubview(layersTableView)
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
        
        layersButton.sizeToFit()
        
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
    
    private func layoutTableView() {
        let tableViewFrame = CGRect(
            x: bounds.minX + directionalLayoutMargins.leading,
            y: bounds.minY,
            width: bounds.width - directionalLayoutMargins.leading - directionalLayoutMargins.trailing,
            height: layersButton.frame.minY - bounds.minY - constants.layersButtonTableViewSpacing
        )
        
        layersTableView.bounds.size = tableViewFrame.size
        layersTableView.center = tableViewFrame.center
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
        let layersTableViewCellHeight: CGFloat = 51.0
        let layersButtonTableViewSpacing: CGFloat = 21
    }
}

// MARK: - Section
extension SaliView {
    private enum Section {
        case main
    }
}
