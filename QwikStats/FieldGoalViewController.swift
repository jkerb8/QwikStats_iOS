//
//  FieldGoalViewController.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 8/6/16.
//  Copyright © 2016 Jonathan Kerbelis. All rights reserved.
//

import UIKit
import MZFormSheetPresentationController

class FieldGoalViewController: UIViewController {
    
    @IBOutlet var kickerNumText: UITextField!
    @IBOutlet var distanceText: UITextField!
    @IBOutlet var resultSwitch: UISwitch!
    @IBOutlet var resultLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultSwitch.setOn(globalPlay.fgMadeFlag, animated: true)
        kickerNumText.keyboardType = UIKeyboardType.NumberPad
        distanceText.keyboardType = UIKeyboardType.NumberPad
        
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
    
    @IBAction func switchChanged(sender: UISwitch) {
        if sender.on {
            resultLabel.text = "Good"
        }
        else {
            resultLabel.text = "No Good"
        }
    }
    
    @IBAction func numChanged(sender: UITextField) {
        if sender.text?.characters.count > 2 {
            sender.deleteBackward()
        }
    }
    
    @IBAction func leftBtn(sender: UIButton) {
        let formSheetController = mz_formSheetPresentingPresentationController()
        formSheetController!.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.SlideFromRight
        
        save()
        playTypeDialog(false)
    }
    
    @IBAction func rightBtn(sender: UIButton) {
        let formSheetController = mz_formSheetPresentingPresentationController()
        formSheetController!.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.SlideFromLeft
        
        save()
        playTypeDialog(true)
    }
    
    @IBAction func saveBtn(sender: UIButton) {
        saved = true
        save()
        dismiss()
    }
    
    @IBAction func cancelBtn(sender: UIButton) {
        let formSheetController = mz_formSheetPresentingPresentationController()
        formSheetController!.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.DropDown
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func save() {
        globalPlay.fgMadeFlag = resultSwitch.on
        
        if let num = Int(kickerNumText.text!) {
            globalPlay.playerNumber = num
        }
        
        if let num = Int(distanceText.text!) {
            globalPlay.fgDistance = num
        }
    }
    
    func dismiss() {
        let formSheetController = mz_formSheetPresentingPresentationController()
        formSheetController!.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.DropDown
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if let temp = saved {
            if temp {
                let vc = presentingViewController as! GameViewController
                vc.savePlay()
            }
        }
    }
    
    func playTypeDialog(slidingRight: Bool) {
        let navigationController = self.storyboard!.instantiateViewControllerWithIdentifier("PlayTypeController")// as! UIViewController
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        //formSheetController.presentationController?.shouldApplyBackgroundBlurEffect = true
        //width is first, height is second
        formSheetController.presentationController?.contentViewSize = CGSizeMake(350, 300)
        if slidingRight {
            formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.SlideFromRight
        }
        else {
            formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.SlideFromLeft
        }
        
        //let presentedViewController = navigationController as! PlayTypeController
        //presentedViewController.play = self.play
        
        formSheetController.willPresentContentViewControllerHandler = { vc in
            let navigationController = vc
            let presentedViewController = navigationController as! PlayTypeController
            presentedViewController.view?.layoutIfNeeded()
        }
        
        let parent: UIViewController! = self.presentingViewController
        
        self.dismissViewControllerAnimated(true, completion: {
            parent.presentViewController(formSheetController, animated: true, completion: nil)
        })
    }
}
