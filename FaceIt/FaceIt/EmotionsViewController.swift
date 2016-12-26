//
//  EmotionsViewController.swift
//  FaceIt
//
//  Created by 李茂琦 on 9/28/16.
//  Copyright © 2016 Li Maoqi. All rights reserved.
//

import UIKit

class EmotionsViewController: UIViewController {
    
    private let emotionalFaces: [String: FacialExpression] = [
        "angry": FacialExpression(eyes: .Closed, eyeBrows: .Furrowed, mouth: .Frown),
        "happy": FacialExpression(eyes: .Open, eyeBrows: .Normal, mouth: .Smile),
        "worried": FacialExpression(eyes: .Open, eyeBrows: .Relaxed, mouth: .Smirk),
        "mischievious": FacialExpression(eyes: .Open, eyeBrows: .Furrowed, mouth: .Grin)
    ]
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationVC = segue.destination
        if let navVC = destinationVC as? UINavigationController {
            destinationVC = navVC.visibleViewController ?? destinationVC
        }
        if let faceVC = destinationVC as? FaceViewController {
            if let identifier = segue.identifier {
                if let expression = emotionalFaces[identifier] {
                    faceVC.expression = expression
                    if let senderButton = sender as? UIButton {
                        faceVC.navigationItem.title = senderButton.currentTitle
                    }
                }
            }
        }
    }
    
}
