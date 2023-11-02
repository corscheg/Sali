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
    private lazy var samplesSelectionPanelView: SamplesSelectionPanelView = {
        let view = SamplesSelectionPanelView()
        view.delegate = self
        
        return view
    }()
    
    private lazy var soundControl = SoundControl()
    private lazy var analyzerView = AnalyzerView()
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
}

// MARK: - SamplesSelectionPanelViewDelegate
extension SaliView: SamplesSelectionPanelViewDelegate {
    func didSelect(viewModel: SampleViewModel) {
        delegate?.didSelect(viewModel: viewModel)
    }
}

// MARK: - ButtonsPanelViewDelegate
extension SaliView: ButtonsPanelViewDelegate {
    func didTapLayersButton() {
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
        addSubview(soundControl)
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
