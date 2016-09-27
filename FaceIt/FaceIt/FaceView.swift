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
    
    var eyesOpen: Bool = true { didSet{ setNeedsDisplay() } }
    
    var color: UIColor = UIColor.blueColor() { didSet{ setNeedsDisplay() } }
    
    var lineWidth: CGFloat = 5.0 { didSet{ setNeedsDisplay() } }
    
    func changeScale(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .Changed, .Ended:
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
    
    private func getEyeCenter(eye: Eye) -> CGPoint {
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
    
    private func pathForEye(eye: Eye) -> UIBezierPath {
        let eyeRadius = skullRadius / Ratios.SkullRadiusToEyeRadius
        let eyeCenter = getEyeCenter(eye)
        if eyesOpen {
            return pathForCircleCenteredAtPoint(eyeCenter, withRadius: eyeRadius)
        } else {
            let path = UIBezierPath()
            path.moveToPoint(CGPoint(x: eyeCenter.x - eyeRadius, y: eyeCenter.y))
            path.addLineToPoint(CGPoint(x: eyeCenter.x + eyeRadius, y: eyeCenter.y))
            path.lineWidth = lineWidth
            return path
        }
    }
    
    private func pathForCircleCenteredAtPoint(midPoint: CGPoint, withRadius radius: CGFloat) -> UIBezierPath {
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
        path.moveToPoint(startPoint)
        path.addCurveToPoint(endPoint, controlPoint1: cp1Point, controlPoint2: cp2Point)
        return path
    }
    
    private func pathForBrow(eye: Eye) -> UIBezierPath {
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
        path.moveToPoint(startPoint)
        path.addLineToPoint(endPoint)
        path.lineWidth = lineWidth
        return path
    }
    
    override func drawRect(rect: CGRect) {
        color.setStroke()
        pathForCircleCenteredAtPoint(skullCenter, withRadius: skullRadius).stroke()
        pathForEye(.Left).stroke()
        pathForEye(.Right).stroke()
        pathForMouth().stroke()
        pathForBrow(.Left).stroke()
        pathForBrow(.Right).stroke()
    }
    
}
