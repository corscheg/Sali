//
//  UIBezierPath+.swift
//  Sali
//
//  Created by Aleksandr Kazak-Kazakevich on 01.11.2023.
//

import UIKit

extension UIBezierPath {
    static func makePlayIcon(size: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        
        let squareSideWithTriangle = cos(.pi / 6.0) * size
        let squareSideWithoutTriangle = size - squareSideWithTriangle
        
        path.move(to: CGPoint(x: squareSideWithoutTriangle, y: 0.0))
        path.addLine(to: CGPoint(x: size, y: size / 2.0))
        path.addLine(to: CGPoint(x: size, y: size / 2.0))
        path.addLine(to: CGPoint(x: squareSideWithoutTriangle, y: size))
        path.close()
        
        return path
    }
    
    static func makeStopIcon(size: CGFloat) -> UIBezierPath {
        UIBezierPath(rect: CGRect(origin: .zero, size: CGSize(width: size, height: size)))
    }
    
    static func makeMicrophoneIcon(width: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 6, y: 3))
        
        path.addCurve(
            to: CGPoint(x: 6.9, y: 0.9),
            controlPoint1: CGPoint(x: 6, y: 2.2),
            controlPoint2: CGPoint(x: 6.3, y: 1.4)
        )
        
        path.addCurve(
            to: CGPoint(x: 9, y: 0),
            controlPoint1: CGPoint(x: 7.4, y: 0.3),
            controlPoint2: CGPoint(x: 8.2, y: 0)
        )
        
        path.addCurve(
            to: CGPoint(x: 11.1, y: 0.9),
            controlPoint1: CGPoint(x: 9.8, y: 0),
            controlPoint2: CGPoint(x: 10.6, y: 0.3)
        )
        
        path.addCurve(
            to: CGPoint(x: 12, y: 3),
            controlPoint1: CGPoint(x: 11.7, y: 1.4),
            controlPoint2: CGPoint(x: 12, y: 2.2)
        )
        
        path.addLine(to: CGPoint(x: 12, y: 7.8))
        path.addCurve(
            to: CGPoint(x: 11.1, y: 9.9),
            controlPoint1: CGPoint(x: 12, y: 8.6),
            controlPoint2: CGPoint(x: 11.7, y: 9.4)
        )
        
        path.addCurve(
            to: CGPoint(x: 9, y: 10.8),
            controlPoint1: CGPoint(x: 10.6, y: 10.5),
            controlPoint2: CGPoint(x: 9.8, y: 10.8)
        )
        
        path.addCurve(
            to: CGPoint(x: 6.9, y: 9.9),
            controlPoint1: CGPoint(x: 8.2, y: 10.8),
            controlPoint2: CGPoint(x: 7.4, y: 10.5)
        )
        
        path.addCurve(
            to: CGPoint(x: 6, y: 7.8),
            controlPoint1: CGPoint(x: 6.3, y: 9.4),
            controlPoint2: CGPoint(x: 6, y: 8.6)
        )
        
        path.addLine(to: CGPoint(x: 6, y: 3))
        path.close()
        path.move(to: CGPoint(x: 2.4, y: 4.8))
        path.addLine(to: CGPoint(x: 2.4, y: 7.8))
        
        path.addCurve(
            to: CGPoint(x: 4.1, y: 12.3),
            controlPoint1: CGPoint(x: 2.4, y: 9.4),
            controlPoint2: CGPoint(x: 3, y: 11)
        )
        
        path.addCurve(
            to: CGPoint(x: 8.4, y: 14.4),
            controlPoint1: CGPoint(x: 5.2, y: 13.5),
            controlPoint2: CGPoint(x: 6.8, y: 14.2)
        )
        
        path.addLine(to: CGPoint(x: 8.4, y: 16.8))
        path.addLine(to: CGPoint(x: 6, y: 16.8))
        path.addLine(to: CGPoint(x: 6, y: 18))
        path.addLine(to: CGPoint(x: 12, y: 18))
        path.addLine(to: CGPoint(x: 12, y: 16.8))
        path.addLine(to: CGPoint(x: 9.6, y: 16.8))
        path.addLine(to: CGPoint(x: 9.6, y: 14.4))
        
        path.addCurve(
            to: CGPoint(x: 13.9, y: 12.3),
            controlPoint1: CGPoint(x: 11.2, y: 14.2),
            controlPoint2: CGPoint(x: 12.8, y: 13.5)
        )
        
        path.addCurve(
            to: CGPoint(x: 15.6, y: 7.8),
            controlPoint1: CGPoint(x: 15, y: 11),
            controlPoint2: CGPoint(x: 15.6, y: 9.4)
        )
        
        path.addLine(to: CGPoint(x: 15.6, y: 4.8))
        path.addLine(to: CGPoint(x: 14.4, y: 4.8))
        path.addLine(to: CGPoint(x: 14.4, y: 7.8))
        
        path.addCurve(
            to: CGPoint(x: 12.8, y: 11.6),
            controlPoint1: CGPoint(x: 14.4, y: 9.2),
            controlPoint2: CGPoint(x: 13.8, y: 10.6)
        )
        
        path.addCurve(
            to: CGPoint(x: 9, y: 13.2),
            controlPoint1: CGPoint(x: 11.8, y: 12.6),
            controlPoint2: CGPoint(x: 10.4, y: 13.2)
        )
        
        path.addCurve(
            to: CGPoint(x: 5.2, y: 11.6),
            controlPoint1: CGPoint(x: 7.6, y: 13.2),
            controlPoint2: CGPoint(x: 6.2, y: 12.6)
        )
        
        path.addCurve(
            to: CGPoint(x: 3.6, y: 7.8),
            controlPoint1: CGPoint(x: 4.2, y: 10.6),
            controlPoint2: CGPoint(x: 3.6, y: 9.2)
        )
        
        path.addLine(to: CGPoint(x: 3.6, y: 4.8))
        path.addLine(to: CGPoint(x: 2.4, y: 4.8))
        path.close()
        
        normalize(path: path, width: width)
        
        return path
    }
    
    static func makeChevronDown(size: CGSize) -> UIBezierPath {
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        path.addLine(to: CGPoint(x: size.width / 2, y: size.height))
        path.addLine(to: CGPoint(x: size.width, y: 0.0))
        
        let filledPath = path.cgPath.copy(
            strokingWithWidth: 2.0,
            lineCap: .round,
            lineJoin: .bevel,
            miterLimit: 1.0
        )
        
        return UIBezierPath(cgPath: filledPath)
    }
    
    static func makeChevronUp(size: CGSize) -> UIBezierPath {
        let path = makeChevronDown(size: size)
        path.apply(.init(scaleX: 1.0, y: -1.0))
        path.apply(.init(translationX: 0.0, y: path.cgPath.boundingBoxOfPath.height / 2.0))
        
        return path
    }
    
    static func makeXMark(size: CGSize) -> UIBezierPath {
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        path.addLine(to: CGPoint(x: size.width, y: size.height))
        path.move(to: CGPoint(x: 0.0, y: size.height))
        path.addLine(to: CGPoint(x: size.width, y: 0.0))
        
        let filledPath = path.cgPath.copy(
            strokingWithWidth: 2.0,
            lineCap: .round,
            lineJoin: .bevel,
            miterLimit: 1.0
        )
        
        return UIBezierPath(cgPath: filledPath)
    }
    
    static func makeMuteLine(size: CGSize) -> UIBezierPath {
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: 0.0, y: size.height))
        path.addLine(to: CGPoint(x: size.width, y: 0.0))
        
        return path
    }
    
    private static func normalize(path: UIBezierPath, width: CGFloat) {
        let pathWidth = path.bounds.width
        let scale = width / pathWidth
        
        path.apply(.init(scaleX: scale, y: scale))
        
        translateToZeroOrigin(path: path)
    }
    
    private static func normalize(path: UIBezierPath, height: CGFloat) {
        let pathHeight = path.bounds.height
        let scale = height / pathHeight
        
        path.apply(.init(scaleX: scale, y: scale))
        
        translateToZeroOrigin(path: path)
    }
    
    private static func translateToZeroOrigin(path: UIBezierPath) {
        let pathBox = path.cgPath.boundingBox
        let translateX = -pathBox.minX
        let translateY = -pathBox.minY
        
        path.apply(.init(translationX: translateX, y: translateY))
    }
}
