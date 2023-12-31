//
//  SignalProcessor.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 04.11.2023.
//

import Accelerate
import Foundation

final class SignalProcessor {
    
    private let transformCount: Int
    private let setup: vDSP_DFT_Setup?
    
    init(processingBufferLength: Int) {
        transformCount = processingBufferLength
        let length = vDSP_Length(transformCount)
        setup = vDSP_DFT_zop_CreateSetup(nil, length, .FORWARD)
    }
}

// MARK: - SignalProcessorProtocol
extension SignalProcessor: SignalProcessorProtocol {
    
    func getFrequencies(data: UnsafeMutablePointer<Float>, count: UInt) -> [Float] {
        let fftResult = calculateFourierTransform(of: data, count: count)
        let db = calculateDB(data: fftResult, count: transformCount / 2)
        let result = normalize(data: db, count: transformCount / 2)
        
        return result
    }
    
    func getLevel(data: UnsafeMutablePointer<Float>, count: UInt) -> Float {
        var rms: Float = 0
        let stride = vDSP_Stride(1)
        let length = vDSP_Length(count)
        vDSP_rmsqv(data, stride, &rms, length)
        
        let db = (log10f(rms) + 4.0) / 4.0
        
        return clamp(value: db, min: 0.1, max: 1.0)
    }
}

// MARK: - Private Methods
extension SignalProcessor {
    private func calculateFourierTransform(of data: UnsafeMutablePointer<Float>, count: UInt) -> [Float] {
        guard let setup else { return [] }
        
        var realIn: [Float] = .init(repeating: 0, count: transformCount)
        var imaginaryIn: [Float] = .init(repeating: 0, count: transformCount)
        var realOut: [Float]  = .init(repeating: 0, count: transformCount)
        var imaginaryOut: [Float] = .init(repeating: 0, count: transformCount)
        
        var result: [Float] = .init(repeating: 0, count: transformCount / 2)
        
        for i in 0...min(transformCount - 1, Int(count)) {
            realIn[i] = data[i]
        }
        
        vDSP_DFT_Execute(setup, &realIn, &imaginaryIn, &realOut, &imaginaryOut)
        
        realOut.withUnsafeMutableBufferPointer { realBuffer in
            guard let realPointer = realBuffer.baseAddress else { return }
            imaginaryOut.withUnsafeMutableBufferPointer { imaginaryBuffer in
                guard let imaginaryPointer = imaginaryBuffer.baseAddress else { return }
                var complexOut = DSPSplitComplex(realp: realPointer, imagp: imaginaryPointer)
                
                let stride = vDSP_Stride(1)
                let length = vDSP_Length(transformCount / 2)
                
                
                vDSP_zvabs(&complexOut, stride, &result, stride, length)
            }
        }
        
        return result
    }
    
    private func calculateDB(data: UnsafePointer<Float>, count: Int) -> [Float] {
        var result: [Float] = .init(repeating: 0.0, count: count)
        var iCount: Int32 = Int32(count)
        
        vvlog10f(&result, data, &iCount)
        
        return result
    }
    
    private func normalize(data: UnsafePointer<Float>, count: Int) -> [Float] {
        var additionResult: [Float] = .init(repeating: 0.0, count: count)
        var value: Float = 4.0
        let stride = vDSP_Stride(1)
        let length = vDSP_Length(count)
        
        vDSP_vsadd(data, stride, &value, &additionResult, stride, length)
        
        var divisionResult: [Float] = .init(repeating: 0.0, count: count)
        var divisor: Float = 6.0
        vDSP_vsdiv(additionResult, stride, &divisor, &divisionResult, stride, length)
        
        var clippedResult: [Float] = .init(repeating: 0.0, count: count)
        var lowerBound: Float = 0.0
        var upperBound: Float = 1.0
        vDSP_vclip(divisionResult, stride, &lowerBound, &upperBound, &clippedResult, stride, length)
        
        return clippedResult
    }
}
