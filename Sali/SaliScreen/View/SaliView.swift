//
//  SaliView.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 31.10.2023.
//

import UIKit

final class SaliView: UIView {
    
    private typealias DataSource = UITableViewDiffableDataSource<Section, String>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, String>
    
    // MARK: Public Properties
    weak var delegate: SaliViewDelegate?
    
    // MARK: Private Properties
    private let constants = Constants()
    private var layerViewModels: [LayerCellViewModel] = []
    private lazy var dataSource: DataSource = {
        let dataSource = DataSource(tableView: layersTableView) { [weak self] tableView, indexPath, _ in
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: LayerTableViewCell.reuseIdentifier,
                for: indexPath
            ) as! LayerTableViewCell
            
            guard let self else { return cell }
            
            cell.delegate = self
            cell.transform = .init(scaleX: 1.0, y: -1.0)
            
            cell.setup(with: layerViewModels[indexPath.row])
            
            return cell
        }
        
        dataSource.defaultRowAnimation = .left
        
        return dataSource
    }()
    
    // MARK: Visual Components
    private lazy var samplesSelectionPanelView: SamplesSelectionPanelView = {
        let view = SamplesSelectionPanelView()
        view.delegate = self
        
        return view
    }()
    
    private lazy var soundControl: SoundControl = {
        let soundControl = SoundControl()
        soundControl.addTarget(self, action: #selector(soundControlValueDidChange), for: .valueChanged)
        
        return soundControl
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var analyzerView: AnalyzerView = {
        let view = AnalyzerView()
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(analyzerTapped))
        view.addGestureRecognizer(tapRecognizer)
        
        return view
    }()
    
    private lazy var buttonsPanelView: ButtonsPanelView = {
        let view = ButtonsPanelView()
        view.delegate = self
        
        return view
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
    func populateSamples(with viewModel: SampleBankViewModel) {
        samplesSelectionPanelView.populate(with: viewModel)
    }
    
    func showLayersTable() {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut) {
            self.layersTableView.alpha = 1.0
            self.analyzerView.alpha = 0.0
        }
    }
    
    func hideLayersTable() {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut) {
            self.layersTableView.alpha = 0.0
            self.analyzerView.alpha = 1.0
        }
    }
    
    func populateLayersTable(with viewModels: [LayerCellViewModel], reload: Bool) {
        
        self.layerViewModels = viewModels
        if reload {
            var snapshot = Snapshot()
            
            snapshot.appendSections([.main])
            snapshot.appendItems(viewModels.map(\.name), toSection: .main)
            
            dataSource.apply(snapshot)
        } else {
            var snapshot = dataSource.snapshot()
            snapshot.reconfigureItems(viewModels.map(\.name))
            dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    func enableParametersControl() {
        soundControl.isEnabled = true
    }
    
    func disableParametersControl() {
        soundControl.isEnabled = false
    }
    
    func set(soundParameters: SoundParameters) {
        let controlOutput = SoundControl.Output(volume: soundParameters.volume, tempo: soundParameters.tempo)
        soundControl.set(output: controlOutput)
    }
    
    func selectLayer(atIndex index: Int?) {
        guard let index else {
            if let selectedIndexPath = layersTableView.indexPathForSelectedRow {
                layersTableView.deselectRow(at: selectedIndexPath, animated: true)
            }
            
            return
        }
        
        layersTableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .none)
    }
    
    func setPlayButtonStop() {
        buttonsPanelView.setPlayButtonStop()
    }
    
    func disablePlayButton() {
        buttonsPanelView.disablePlayButton()
    }
    
    func enablePlayButton() {
        buttonsPanelView.enablePlayButton()
    }
    
    func disableRecordingButton() {
        buttonsPanelView.disableRecordingButton()
    }
    
    func enableRecordingButton() {
        buttonsPanelView.enableRecordingButton()
    }
    
    func disableMicrophoneButton() {
        buttonsPanelView.disableMicrophoneButton()
    }
    
    func enableMicrophoneButton() {
        buttonsPanelView.enableMicrophoneButton()
    }
    
    func setMicrophoneButtonInactive() {
        buttonsPanelView.setMicrophoneButtonInactive()
    }
    
    func updateMetering(_ metering: [Float]) {
        analyzerView.updateMetering(metering)
    }
    
    func clearAnalyzer() {
        analyzerView.clear()
    }
    
    func set(title: String) {
        UIView.transition(with: titleLabel, duration: 0.3, options: .transitionCrossDissolve) {
            self.titleLabel.text = title
        }
    }
    
    // MARK: Actions
    @objc private func soundControlValueDidChange() {
        let parameters = SoundParameters(volume: soundControl.output.volume, tempo: soundControl.output.tempo)
        delegate?.didChange(parameters: parameters)
    }
    
    @objc private func analyzerTapped() {
        delegate?.didTapAnalyzer()
    }
}

// MARK: - SamplesSelectionPanelViewDelegate
extension SaliView: SamplesSelectionPanelViewDelegate {
    func didSelect(viewModel: SampleViewModel, type: LayerType) {
        delegate?.didSelectSample(withIdentifier: viewModel.identifier, type: type)
    }
}

// MARK: - ButtonsPanelViewDelegate
extension SaliView: ButtonsPanelViewDelegate {
    func didTapLayersButton() {
        delegate?.didTapLayersButton()
    }
    
    func didTapMicrophoneButton() {
        delegate?.didTapMicrophoneButton()
    }
    
    func didTapRecordingButton() {
        delegate?.didTapRecordingButton()
    }
    
    func didTapPlayButton() {
        delegate?.didTapPlayButton()
    }
}

// MARK: - LayerTableViewCellDelegate
extension SaliView: LayerTableViewCellDelegate {
    func layerCellDidTapPlay(_ layerCell: LayerTableViewCell) {
        guard let indexPath = layersTableView.indexPath(for: layerCell) else { return }
        delegate?.didSelectPlay(atIndex: indexPath.row)
    }
    
    func layerCellDidTapMute(_ layerCell: LayerTableViewCell) {
        guard let indexPath = layersTableView.indexPath(for: layerCell) else { return }
        delegate?.didSelectMute(atIndex: indexPath.row)
    }
    
    func layerCellDidTapDelete(_ layerCell: LayerTableViewCell) {
        guard let indexPath = layersTableView.indexPath(for: layerCell) else { return }
        delegate?.didSelectDelete(atIndex: indexPath.row)
    }
}

// MARK: - UITableViewDelegate
extension SaliView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectLayer(atIndex: indexPath.row)
    }
}

// MARK: - Private Methods
extension SaliView {
    private func setupView() {
        backgroundColor = .background
        
        directionalLayoutMargins = NSDirectionalEdgeInsets(all: constants.margin)
    }
    
    private func addSubviews() {
        addSubview(soundControl)
        addSubview(titleLabel)
        addSubview(analyzerView)
        addSubview(buttonsPanelView)
        addSubview(samplesSelectionPanelView)
        addSubview(layersTableView)
    }
    
    private func layoutInstrumentsSelection() {
        
        let size = samplesSelectionPanelView.sizeThatFits(
            CGSize(
                width: bounds.width - directionalLayoutMargins.leading - directionalLayoutMargins.trailing,
                height: .greatestFiniteMagnitude
            )
        )
        
        samplesSelectionPanelView.frame = CGRect(
            origin: CGPoint(x: bounds.minX + directionalLayoutMargins.leading, y: bounds.minY + directionalLayoutMargins.top),
            size: size
        )
    }
    
    private func layoutSoundControl() {
        let y = samplesSelectionPanelView.frame.maxY + constants.instrumentsSoundControlSpacing
        soundControl.frame = CGRect(
            x: bounds.minX + directionalLayoutMargins.leading,
            y: y,
            width: bounds.width - directionalLayoutMargins.leading - directionalLayoutMargins.trailing,
            height: analyzerView.frame.minY - constants.soundControlAnalyzerSpacing - y
        )
        
        titleLabel.frame = CGRect(
            x: soundControl.frame.minX,
            y: soundControl.frame.minY,
            width: soundControl.frame.width,
            height: soundControl.frame.height * 0.1
        )
    }
    
    private func layoutAnalyzer() {
        analyzerView.frame = CGRect(
            x: bounds.minX + directionalLayoutMargins.leading,
            y: buttonsPanelView.frame.minY - constants.buttonsAnalyzerSpacing - constants.analyzerHeight,
            width: bounds.width - directionalLayoutMargins.leading - directionalLayoutMargins.trailing,
            height: constants.analyzerHeight
        )
    }
    
    private func layoutButtons() {
        let size = buttonsPanelView.sizeThatFits(
            CGSize(
                width: bounds.width - directionalLayoutMargins.leading - directionalLayoutMargins.trailing,
                height: .greatestFiniteMagnitude
            )
        )
        
        buttonsPanelView.frame = CGRect(
            origin: CGPoint(
                x: bounds.minX + directionalLayoutMargins.leading,
                y: bounds.maxY - directionalLayoutMargins.bottom - size.height
            ),
            size: size
        )
    }
    
    private func layoutTableView() {
        let tableViewFrame = CGRect(
            x: bounds.minX + directionalLayoutMargins.leading,
            y: bounds.minY,
            width: bounds.width - directionalLayoutMargins.leading - directionalLayoutMargins.trailing,
            height: buttonsPanelView.frame.minY - bounds.minY - constants.layersButtonTableViewSpacing
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
        let layersTableViewCellHeight: CGFloat = 51.0
        let layersButtonTableViewSpacing: CGFloat = 21
        let analyzerHeight: CGFloat = 44.0
    }
}

// MARK: - Section
extension SaliView {
    private enum Section {
        case main
    }
}
