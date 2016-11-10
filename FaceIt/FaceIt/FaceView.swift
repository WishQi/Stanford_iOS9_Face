//
//  FaceView.swift
//  FaceIt
//
//  Created by 李茂琦 on 9/21/16.
//  Copyright © 2016 Li Maoqi. All rights reserved.
//

import UIKit

@IBDesignable
class FaceView: UIView {
    
    //Public API
    
    var scale: CGFloat = 0.9 { didSet{ setNeedsDisplay() } }
    
    var mouthCurvature: Double = 0 { didSet{ setNeedsDisplay() } }
    
    var eyeBrowTilt: Double = 0 { didSet{ setNeedsDisplay() } }
    
    var eyesOpen: Bool = true { didSet{ leftEye.eyesOpen = eyesOpen; rightEye.eyesOpen = eyesOpen } }
    
    var color: UIColor = UIColor.blue { didSet{ setNeedsDisplay(); leftEye.color = color; rightEye.color = color } }
    
    var lineWidth: CGFloat = 5.0 { didSet{ setNeedsDisplay(); leftEye.lineWidth = lineWidth; rightEye.lineWidth = lineWidth } }
    
    func changeScale(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
            scale *= recognizer.scale
            recognizer.scale = 1
        default:
            break
        }
    }
    
    
    //Private implementation
    
    private var skullRadius: CGFloat {
        return min(bounds.width, bounds.height) / 2 * scale
    }

    private var skullCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    private struct Ratios {
        static let SkullRadiusToEyeOffset: CGFloat = 3
        static let SkullRadiusToEyeRadius: CGFloat = 10
        static let SkullRadiusToMouthWidth: CGFloat = 1
        static let SkullRadiusToMouthHeight: CGFloat = 3
        static let SkullRadiusToMouthOffset: CGFloat = 3
        static let SkullRadiusToBrowOffset: CGFloat = 5
    }
    
    private enum Eye {
        case Left
        case Right
    }
    
    private func getEyeCenter(_ eye: Eye) -> CGPoint {
        let eyeOffset = skullRadius / Ratios.SkullRadiusToEyeOffset
        var eyeCenter = skullCenter
        eyeCenter.y -= eyeOffset
        switch eye {
        case .Left:
            eyeCenter.x -= eyeOffset
        case .Right:
            eyeCenter.x += eyeOffset
        }
        return eyeCenter
    }
    
    // create EyeView
    private lazy var leftEye: EyeView = self.createEye()
    private lazy var rightEye: EyeView = self.createEye()
    
    private func createEye() -> EyeView {
        let eye = EyeView()
        eye.isOpaque = false
        eye.color = color
        eye.lineWidth = lineWidth
        addSubview(eye)
        return eye
    }
    
    private func positionEye(eye: EyeView, center: CGPoint) {
        let diameter = skullRadius / Ratios.SkullRadiusToEyeRadius * 2
        eye.frame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize(width: diameter, height: diameter))
        eye.center = center
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        positionEye(eye: leftEye, center: getEyeCenter(.Left))
        positionEye(eye: rightEye, center: getEyeCenter(.Right))
    }
    
//    private func pathForEye(_ eye: Eye) -> UIBezierPath {
//        let eyeRadius = skullRadius / Ratios.SkullRadiusToEyeRadius
//        let eyeCenter = getEyeCenter(eye)
//        if eyesOpen {
//            return pathForCircleCenteredAtPoint(eyeCenter, withRadius: eyeRadius)
//        } else {
//            let path = UIBezierPath()
//            path.move(to: CGPoint(x: eyeCenter.x - eyeRadius, y: eyeCenter.y))
//            path.addLine(to: CGPoint(x: eyeCenter.x + eyeRadius, y: eyeCenter.y))
//            path.lineWidth = lineWidth
//            return path
//        }
//    }
    
    private func pathForCircleCenteredAtPoint(_ midPoint: CGPoint, withRadius radius: CGFloat) -> UIBezierPath {
        let path = UIBezierPath(arcCenter: midPoint, radius: radius, startAngle: 0.0, endAngle: CGFloat(2 * M_PI), clockwise: true)
        path.lineWidth = lineWidth
        return path
    }
    
    func pathForMouth() -> UIBezierPath {
        let mouthWidth = skullRadius / Ratios.SkullRadiusToMouthWidth
        let mouthHeight = skullRadius / Ratios.SkullRadiusToMouthHeight
        let mouthOffset = skullRadius / Ratios.SkullRadiusToMouthOffset
        
        let mouthRect = CGRect(x: skullCenter.x - mouthWidth / 2, y: skullCenter.y + mouthOffset, width: mouthWidth, height: mouthHeight)
        
        let smileOffset = CGFloat( max(-1, min(mouthCurvature, 1)) ) * mouthHeight
        
        let startPoint = CGPoint(x: mouthRect.minX, y: mouthRect.minY)
        let endPoint = CGPoint(x: mouthRect.maxX, y: mouthRect.minY)
        let cp1Point = CGPoint(x: startPoint.x + mouthWidth / 3, y: startPoint.y + CGFloat(smileOffset))
        let cp2Point = CGPoint(x: endPoint.x - mouthWidth / 3, y: endPoint.y + CGFloat(smileOffset))
        
        let path = UIBezierPath()
        path.lineWidth = lineWidth
        path.move(to: startPoint)
        path.addCurve(to: endPoint, controlPoint1: cp1Point, controlPoint2: cp2Point)
        return path
    }
    
    private func pathForBrow(_ eye: Eye) -> UIBezierPath {
        var tilt = eyeBrowTilt
        switch eye {
            case .Left: tilt *= -1.0
            case .Right: break
        }
        var browCenter = getEyeCenter(eye)
        browCenter.y -= skullRadius / Ratios.SkullRadiusToBrowOffset
        let eyeRadius = skullRadius / Ratios.SkullRadiusToEyeRadius
        let browTiltOffset = CGFloat( max(-0.5, min(tilt, 0.5)) ) * eyeRadius / 2
        let startPoint = CGPoint(x: browCenter.x - eyeRadius, y: browCenter.y - browTiltOffset)
        let endPoint = CGPoint(x: browCenter.x + eyeRadius, y: browCenter.y + browTiltOffset)
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        path.lineWidth = lineWidth
        return path
    }
    
    override func draw(_ rect: CGRect) {
        color.setStroke()
        pathForCircleCenteredAtPoint(skullCenter, withRadius: skullRadius).stroke()
//        pathForEye(.Left).stroke()
//        pathForEye(.Right).stroke()
        pathForMouth().stroke()
        pathForBrow(.Left).stroke()
        pathForBrow(.Right).stroke()
    }
    
}
