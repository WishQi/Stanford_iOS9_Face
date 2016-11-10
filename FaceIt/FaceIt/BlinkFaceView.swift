//
//  BlinkFaceView.swift
//  FaceIt
//
//  Created by 李茂琦 on 08/11/2016.
//  Copyright © 2016 Li Maoqi. All rights reserved.
//

import UIKit

class BlinkFaceViewController: FaceViewController {

    var blinking: Bool = false {
        didSet {
            startBlink()
        }
    }
    
    private struct BlinkRate {
        static let ClosedDuration = 0.5
        static let OpenDuration = 2.0
    }
    
    @objc private func startBlink() {
        if blinking {
            faceView.eyesOpen = false;
            // after a moment, open them again
            Timer.scheduledTimer(timeInterval: BlinkRate.ClosedDuration, target: self, selector: #selector(endBlink), userInfo: nil, repeats: false)
        }
    }
    
    @objc private func endBlink() {
        faceView.eyesOpen = true
        Timer.scheduledTimer(timeInterval: BlinkRate.OpenDuration, target: self, selector: #selector(startBlink), userInfo: nil, repeats: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        blinking = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        blinking = false
    }
}
