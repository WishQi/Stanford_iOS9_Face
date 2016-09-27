//
//  ViewController.swift
//  FaceIt
//
//  Created by 李茂琦 on 9/21/16.
//  Copyright © 2016 Li Maoqi. All rights reserved.
//

import UIKit

class FaceViewController: UIViewController {
    // Model
    
    var expression = FacialExpression(eyes: .Open, eyeBrows: .Relaxed, mouth: .Smirk) {
        didSet {
            updateUI()
        }
    }
    
    // View
    
    @IBOutlet weak var faceView: FaceView! {
        didSet {
            faceView.addGestureRecognizer(UIPinchGestureRecognizer(target: faceView, action: #selector( faceView.changeScale(_:) ) ))
            
            let happierSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector( increaseHappiness))
            happierSwipeGestureRecognizer.direction = .Up
            faceView.addGestureRecognizer(happierSwipeGestureRecognizer)
            
            let sadderSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(decreaseHappiness))
            sadderSwipeGestureRecognizer.direction = .Down
            faceView.addGestureRecognizer(sadderSwipeGestureRecognizer)
            
//            faceView.addGestureRecognizer(UITapGestureRecognizer(target: faceView, action: #selector(FaceViewController.toggleEyes(_:)) ))
            
            faceView.addGestureRecognizer(UIRotationGestureRecognizer( target: self, action: #selector(changeBrows(_:)) ))
            
            updateUI()
        }
    }
    
    var mouthCurvatures = [FacialExpression.Mouth.Frown: -1.0, .Smirk: -0.5, .Neutral: 0.0, .Grin: 0.5, .Smile: 1.0]
    var eyeBrowTilts = [FacialExpression.EyeBrows.Furrowd: -0.5, .Normal: 0.0, .Relaxed: 0.5]
    
    func updateUI() {
        switch expression.eyes {
        case .Open: faceView.eyesOpen = true
        case .Closed: faceView.eyesOpen = false
        case .Squinting: faceView.eyesOpen = false
        }
        
        faceView.mouthCurvature = mouthCurvatures[expression.mouth] ?? 0.0
        faceView.eyeBrowTilt = eyeBrowTilts[expression.eyeBrows] ?? 0.0
    }
    
    func increaseHappiness() {
        expression.mouth = expression.mouth.happierMouth()
    }
    
    func decreaseHappiness() {
        expression.mouth = expression.mouth.sadderMouth()
    }
    
    func toggleEyes(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .Ended {
            switch expression.eyes {
            case .Open: expression.eyes = .Closed
            case .Closed: expression.eyes = .Open
            case .Squinting: break
            }
        }
    }
    
    func changeBrows(recognizer: UIRotationGestureRecognizer) {
        switch recognizer.state {
        case .Changed, .Ended:
            if recognizer.rotation > CGFloat(M_PI / 4) {
                expression.eyeBrows = expression.eyeBrows.moreRelaxedBrow()
                recognizer.rotation = 0
            } else if recognizer.rotation < -CGFloat(M_PI / 4) {
                expression.eyeBrows = expression.eyeBrows.moreFurrowedBrow()
                recognizer.rotation = 0
            }
        default:
            break
        }
    }
}

