//
//  ResultViewController.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 7/28/16.
//  Copyright © 2016 Jonathan Kerbelis. All rights reserved.
//

import UIKit
import MZFormSheetPresentationController

class ResultViewController: UIViewController {
    
    @IBOutlet var gnLsTextField: UITextField!
    @IBOutlet var ydLnTextField: UITextField!
    @IBOutlet var safetySwitch: UISwitch!
    @IBOutlet var touchdownSwitch: UISwitch!
    
    var play: Play!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        safetySwitch.setOn(globalPlay.safetyFlag, animated: true)
        touchdownSwitch.setOn(globalPlay.touchdownFlag, animated: true)
        gnLsTextField.text = String(globalPlay.gnLs)
        ydLnTextField.text = String(globalPlay.ydLn)
        
        gnLsTextField.keyboardType = UIKeyboardType.NumbersAndPunctuation
        ydLnTextField.keyboardType = UIKeyboardType.NumbersAndPunctuation
    }
    
    @IBAction func checkMaxLength(sender: AnyObject) {
        if sender.text?.characters.count > 3 {
            sender.deleteBackward()
        }
    }
    
    @IBAction func safetySwitchChanged(sender: UISwitch) {
        if sender.on {
            touchdownSwitch.setOn(false, animated: true)
            ydLnTextField.text = "0"
            
            var gnLs: Int
            if globalPlay.prevYdLn < 0 {
                gnLs = globalPlay.prevYdLn
            }
            else {
                gnLs = fieldSize - globalPlay.prevYdLn
            }
            gnLsTextField.text = String(gnLs)
        }
    }
    
    @IBAction func touchdownSwitchChanged(sender: UISwitch) {
        if sender.on {
            safetySwitch.setOn(false, animated: true)
            ydLnTextField.text = "0"
            
            var gnLs: Int
            if globalPlay.prevYdLn < 0 {
                gnLs = globalPlay.prevYdLn + fieldSize
            }
            else {
                gnLs = globalPlay.prevYdLn
            }
            gnLsTextField.text = String(gnLs)
        }
    }
    
    @IBAction func rightBtnClicked(sender: UIButton) {
        save()
    }
    
    @IBAction func leftBtnClicked(sender: UIButton) {
        save()
        runDialog()
    }
    
    @IBAction func saveBtnClicked(sender: UIButton) {
        save()
        dismiss()
    }
    
    @IBAction func cancelBtnClicked(sender: UIButton) {
        dismiss()
    }
    
    func save() {
        if let gnLs = Int(gnLsTextField.text!) {
            globalPlay.gnLs = gnLs
        }
        if let ydLn = Int(ydLnTextField.text!) {
            globalPlay.ydLn = ydLn
        }
        globalPlay.safetyFlag = safetySwitch.on
        globalPlay.touchdownFlag = touchdownSwitch.on
    }
    
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func runDialog() {
        let navigationController = self.storyboard!.instantiateViewControllerWithIdentifier("RunViewController")// as! UIViewController
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        //formSheetController.presentationController?.shouldApplyBackgroundBlurEffect = true
        //width is first, height is second
        formSheetController.presentationController?.contentViewSize = CGSizeMake(350, 275)
        formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.SlideAndBounceFromLeft
        
        //let presentedViewController = navigationController as! RunViewController
        //presentedViewController.play = self.play
        
        formSheetController.willPresentContentViewControllerHandler = { vc in
            let navigationController = vc
            let presentedViewController = navigationController as! RunViewController
            presentedViewController.view?.layoutIfNeeded()
            presentedViewController.titleLabel?.text = "Runner"
        }
        
        let parent: UIViewController! = self.presentingViewController
        
        self.dismissViewControllerAnimated(true, completion: {
            parent.presentViewController(formSheetController, animated: true, completion: nil)
        })
    }
}
