//
//  SamplesSelectionPanelView.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 02.11.2023.
//

import UIKit

final class SamplesSelectionPanelView: UIView {
    
    // MARK: Public Properties
    weak var delegate: SamplesSelectionPanelViewDelegate?
    
    // MARK: Visual Components
    private lazy var guitarSelectView: SampleSelectView = {
        let view = SampleSelectView(image: .instrumentGuitar, imageOffset: CGSize(width: 0, height: 10), text: "guitar")
        view.delegate = self
        
        return view
    }()
    
    private lazy var drumsSelectView: SampleSelectView = {
        let view = SampleSelectView(image: .instrumentDrums, text: "drums")
        view.delegate = self
        
        return view
    }()
    
    private lazy var brassSelectView: SampleSelectView = {
        let view = SampleSelectView(image: .instrumentBrass, imageOffset: CGSize(width: -1, height: 1), text: "brass")
        view.delegate = self
        
        return view
    }()
    
    // MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIView
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let controlWidth = bounds.width / 5.0
        let controlHeight = bounds.height
        let controlSize = CGSize(width: controlWidth, height: controlHeight)
        
        let controlPadding = controlWidth
        
        guitarSelectView.frame = CGRect(
            origin: CGPoint(x: bounds.minX, y: bounds.minY),
            size: controlSize
        )
        
        drumsSelectView.frame = CGRect(
            origin: CGPoint(x: guitarSelectView.frame.maxX + controlPadding, y: bounds.minY),
            size: controlSize
        )
        
        brassSelectView.frame = CGRect(
            origin: CGPoint(x: drumsSelectView.frame.maxX + controlPadding, y: bounds.minY),
            size: controlSize
        )
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let width = size.width
        let controlWidth = width / 5.0
        
        let height = [guitarSelectView, drumsSelectView, brassSelectView]
            .map { $0.sizeThatFits(CGSize(width: controlWidth, height: .greatestFiniteMagnitude)) }
            .map(\.height)
            .max()
        
        guard let height else { return .zero }
        
        return CGSize(width: width, height: height)
    }
    
    // MARK: Public Methods
    func populate(with viewModel: SampleBankViewModel) {
        guitarSelectView.populate(with: viewModel.guitarSamples)
        drumsSelectView.populate(with: viewModel.drumSamples)
        brassSelectView.populate(with: viewModel.brassSamples)
    }
}

// MARK: - SampleSelectViewDelegate
extension SamplesSelectionPanelView: SampleSelectViewDelegate {
    func sampleSelectView(_ sampleSelectView: SampleSelectView, didSelect viewModel: SampleViewModel) {
        delegate?.didSelect(viewModel: viewModel)
    }
}

// MARK: - Private Methods
extension SamplesSelectionPanelView {
    private func addSubviews() {
        addSubview(guitarSelectView)
        addSubview(drumsSelectView)
        addSubview(brassSelectView)
    }
}
