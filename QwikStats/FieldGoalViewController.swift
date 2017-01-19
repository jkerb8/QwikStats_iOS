//
//  FieldGoalViewController.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 8/6/16.
//  Copyright © 2016 Jonathan Kerbelis. All rights reserved.
//

import UIKit
import MZFormSheetPresentationController
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class FieldGoalViewController: UIViewController {
    
    @IBOutlet var kickerNumText: UITextField!
    @IBOutlet var distanceText: UITextField!
    @IBOutlet var resultSwitch: UISwitch!
    @IBOutlet var resultLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultSwitch.setOn(globalPlay.fgMadeFlag, animated: true)
        kickerNumText.keyboardType = UIKeyboardType.numberPad
        distanceText.keyboardType = UIKeyboardType.numberPad
        
        if globalPlay.playerNumber != -1 {
            kickerNumText.text = String(globalPlay.playerNumber)
        }
        
        if globalPlay.fgDistance != 0 {
            distanceText.text = String(globalPlay.fgDistance)
        }
        else {
            var dist = globalPlay.prevYdLn
            if dist < 0 {
                dist += fieldSize
            }
            else if dist == 0 {
                dist = fieldSize
            }
            dist += 17
            distanceText.text = String(dist)
        }
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        if sender.isOn {
            resultLabel.text = "Good"
        }
        else {
            resultLabel.text = "No Good"
        }
    }
    
    @IBAction func numChanged(_ sender: UITextField) {
        if sender.text?.characters.count > 2 {
            sender.deleteBackward()
        }
    }
    
    @IBAction func leftBtn(_ sender: UIButton) {
        let formSheetController = mz_formSheetPresentingPresentationController()
        formSheetController!.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.slideFromRight
        
        save()
        playTypeDialog(false)
    }
    
    @IBAction func rightBtn(_ sender: UIButton) {
        let formSheetController = mz_formSheetPresentingPresentationController()
        formSheetController!.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.slideFromLeft
        
        save()
        playTypeDialog(true)
    }
    
    @IBAction func saveBtn(_ sender: UIButton) {
        saved = true
        save()
        dismiss()
    }
    
    @IBAction func cancelBtn(_ sender: UIButton) {
        let formSheetController = mz_formSheetPresentingPresentationController()
        formSheetController!.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.dropDown
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func save() {
        globalPlay.fgMadeFlag = resultSwitch.isOn
        
        if let num = Int(kickerNumText.text!) {
            globalPlay.playerNumber = num
        }
        
        if let num = Int(distanceText.text!) {
            globalPlay.fgDistance = num
        }
    }
    
    func dismiss() {
        let formSheetController = mz_formSheetPresentingPresentationController()
        formSheetController!.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.dropDown
        
        self.dismiss(animated: true, completion: nil)
        
        if let temp = saved {
            if temp {
                let vc = presentingViewController as! GameViewController
                vc.savePlay()
            }
        }
    }
    
    func playTypeDialog(_ slidingRight: Bool) {
        let navigationController = self.storyboard!.instantiateViewController(withIdentifier: "PlayTypeController")// as! UIViewController
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        //formSheetController.presentationController?.shouldApplyBackgroundBlurEffect = true
        //width is first, height is second
        formSheetController.presentationController?.contentViewSize = CGSize(width: 350, height: 300)
        if slidingRight {
            formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.slideFromRight
        }
        else {
            formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.slideFromLeft
        }
        
        //let presentedViewController = navigationController as! PlayTypeController
        //presentedViewController.play = self.play
        
        formSheetController.willPresentContentViewControllerHandler = { vc in
            let navigationController = vc
            let presentedViewController = navigationController as! PlayTypeController
            presentedViewController.view?.layoutIfNeeded()
        }
        
        let parent: UIViewController! = self.presentingViewController
        
        self.dismiss(animated: true, completion: {
            parent.present(formSheetController, animated: true, completion: nil)
        })
    }
}
