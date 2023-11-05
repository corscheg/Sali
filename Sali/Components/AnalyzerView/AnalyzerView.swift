//
//  AnalyzerView.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 01.11.2023.
//

import MetalKit
import UIKit

final class AnalyzerView: UIView {
    
    // MARK: Private Properties
    private let constants = Constants()
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let pipelineState: MTLComputePipelineState
    private var meteringBuffer: MTLBuffer?
    private var meteringCount: Int?
    private let replacementBuffer: MTLBuffer
    private let replacementCount: Int
    
    // MARK: Visual Components
    private lazy var metalView: MTKView = {
        let view = MTKView(frame: .zero, device: device)
        view.delegate = self
        view.framebufferOnly = false
        
        return view
    }()
    
    // MARK: Initializers
    override init(frame: CGRect) {
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device.makeCommandQueue()!
        let library = device.makeDefaultLibrary()!
        let function = library.makeFunction(name: "draw_metering")!
        pipelineState = try! device.makeComputePipelineState(function: function)
        
        replacementBuffer = device.makeBuffer(length: MemoryLayout<Float>.size * constants.frequencyBucketsCount)!
        replacementCount = constants.frequencyBucketsCount
        
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
        metalView.frame = bounds
    }
    
    // MARK: Public Methods
    func updateMetering(_ metering: [Float]) {
        meteringBuffer = device.makeBuffer(length: MemoryLayout<Float>.size * metering.count)
        memcpy(meteringBuffer?.contents(), metering, MemoryLayout<Float>.size * metering.count)
        meteringCount = metering.count
    }
    
    func clear() {
        meteringCount = nil
        meteringBuffer = nil
    }
}

// MARK: - MTKViewDelegate
extension AnalyzerView: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        guard let commandEncoder = commandBuffer.makeComputeCommandEncoder() else { return }
        guard let drawable = view.currentDrawable else { return }
        
        var bucketsCount = constants.frequencyBucketsCount
        commandEncoder.setComputePipelineState(pipelineState)
        commandEncoder.setTexture(drawable.texture, index: 0)
        
        if let meteringBuffer, let meteringCount {
            commandEncoder.setBuffer(meteringBuffer, offset: 0, index: 0)
            var count = meteringCount
            commandEncoder.setBytes(&count, length: MemoryLayout<Int>.stride, index: 1)
        } else {
            commandEncoder.setBuffer(replacementBuffer, offset: 0, index: 0)
            var replacedCount = replacementCount
            commandEncoder.setBytes(&replacedCount, length: MemoryLayout<Int>.stride, index: 1)
        }
        
        commandEncoder.setBytes(&bucketsCount, length: MemoryLayout<Int>.stride, index: 2)
        let width = pipelineState.threadExecutionWidth
        let height = pipelineState.maxTotalThreadsPerThreadgroup / width
        
        let threadsPerGroup = MTLSize(width: width, height: height, depth: 1)
        let threadGroupsPerGrid = MTLSize(width: Int(view.drawableSize.width) / width, height: Int(view.drawableSize.height) / height, depth: 1)
//        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        commandEncoder.dispatchThreadgroups(threadGroupsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        commandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

// MARK: Private Methods
extension AnalyzerView {
    private func setupView() {
        backgroundColor = .accent
        layer.cornerRadius = 8
        layer.cornerCurve = .continuous
    }
    
    private func addSubviews() {
        addSubview(metalView)
    }
}

// MARK: Constants
extension AnalyzerView {
    private struct Constants {
        let frequencyBucketsCount = 32
    }
}
