//
//  PasserViewController.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 8/6/16.
//  Copyright © 2016 Jonathan Kerbelis. All rights reserved.
//

import UIKit
import MZFormSheetPresentationController

class PasserViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var numberTextField: UITextField!
    @IBOutlet var recent1Btn: UIButton!
    @IBOutlet var recent2Btn: UIButton!
    @IBOutlet var recent3Btn: UIButton!
    
    @IBOutlet var incompleteSwitch: UISwitch!
    @IBOutlet var interceptionSwitch: UISwitch!
    @IBOutlet var sackSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var recentPassers = [Int]()
        if (game.possFlag) {
            recentPassers = game.homeTeam.recentPassers
        }
        else {
            recentPassers = game.awayTeam.recentPassers
        }
        
        switch (recentPassers.count) {
        case 1:
            recent2Btn.setTitle(String(recentPassers[0]), forState: .Normal)
            recent1Btn.hidden = true
            recent3Btn.hidden = true
        case 2:
            recent2Btn.setTitle(String(recentPassers[0]), forState: .Normal)
            recent3Btn.setTitle(String(recentPassers[1]), forState: .Normal)
            recent1Btn.hidden = true
        case 3:
            recent1Btn.setTitle(String(recentPassers[0]), forState: .Normal)
            recent2Btn.setTitle(String(recentPassers[1]), forState: .Normal)
            recent3Btn.setTitle(String(recentPassers[2]), forState: .Normal)
        default:
            recent1Btn.hidden = true
            recent2Btn.hidden = true
            recent3Btn.hidden = true
        }
        
        numberTextField.keyboardType = UIKeyboardType.NumberPad
        
        interceptionSwitch.setOn(globalPlay.interceptionFlag, animated: true)
        incompleteSwitch.setOn(globalPlay.incompleteFlag, animated: true)
        sackSwitch.setOn(globalPlay.sackFlag, animated: true)
        
        if let play = globalPlay {
            if play.playerNumber != -1 {
                numberTextField.text = String(play.playerNumber)
            }
        }
        else {
            numberTextField.text = "00"
        }
        
    }
    
    @IBAction func switchChanged(sender: UISwitch) {
        switch(sender) {
        case incompleteSwitch:
            if sender.on {
                interceptionSwitch.setOn(false, animated: true)
                sackSwitch.setOn(false, animated: true)
            }
        case interceptionSwitch:
            if sender.on {
                incompleteSwitch.setOn(false, animated: true)
                sackSwitch.setOn(false, animated: true)
            }
        case sackSwitch:
            if sender.on {
                incompleteSwitch.setOn(false, animated: true)
                interceptionSwitch.setOn(false, animated: true)
            }
        default: break
        }
    }
    
    @IBAction func recent1Btn(sender: UIButton) {
        if let text = sender.titleLabel?.text {
            numberTextField.text = text
        }
    }
    
    @IBAction func recent2Btn(sender: UIButton) {
        if let text = sender.titleLabel?.text {
            numberTextField.text = text
        }
    }
    
    @IBAction func recent3Btn(sender: UIButton) {
        if let text = sender.titleLabel?.text {
            numberTextField.text = text
        }
    }
    
    @IBAction func checkMaxLength(sender: UITextField) {
        if sender.text?.characters.count > 2 {
            sender.deleteBackward()
        }
    }
    
    @IBAction func leftBtn(sender: UIButton) {
        save()
        playTypeDialog()
    }
    
    @IBAction func rightBtn(sender: UIButton) {
        save()
        if globalPlay.sackFlag || globalPlay.interceptionFlag {
            resultDialog()
        }
        else {
            receiverDialog()
        }
    }
    
    @IBAction func saveBtn(sender: UIButton) {
        saved = true
        save()
        dismiss()
    }
    
    @IBAction func cancelBtn(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func save() {
        if let num = Int(numberTextField.text!) {
            globalPlay.playerNumber = num
        }
        globalPlay.incompleteFlag = incompleteSwitch.on
        globalPlay.interceptionFlag = interceptionSwitch.on
        globalPlay.sackFlag = sackSwitch.on
    }
    
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if let temp = saved {
            if temp {
                let vc = presentingViewController as! GameViewController
                vc.savePlay()
            }
        }
    }
    
    func playTypeDialog() {
        let navigationController = self.storyboard!.instantiateViewControllerWithIdentifier("PlayTypeController")// as! UIViewController
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        //formSheetController.presentationController?.shouldApplyBackgroundBlurEffect = true
        //width is first, height is second
        formSheetController.presentationController?.contentViewSize = CGSizeMake(350, 275)
        formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.SlideAndBounceFromLeft
        
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
    
    func receiverDialog() {
        let navigationController = self.storyboard!.instantiateViewControllerWithIdentifier("RunViewController")// as! UIViewController
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        //formSheetController.presentationController?.shouldApplyBackgroundBlurEffect = true
        //width is first, height is second
        formSheetController.presentationController?.contentViewSize = CGSizeMake(350, 275)
        formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.SlideAndBounceFromLeft
        
        //let presentedViewController = navigationController as! PlayTypeController
        //presentedViewController.play = self.play
        
        formSheetController.willPresentContentViewControllerHandler = { vc in
            let navigationController = vc
            let presentedViewController = navigationController as! RunViewController
            presentedViewController.view?.layoutIfNeeded()
            presentedViewController.titleLabel.text = "Receiver"
        }
        
        let parent: UIViewController! = self.presentingViewController
        
        self.dismissViewControllerAnimated(true, completion: {
            parent.presentViewController(formSheetController, animated: true, completion: nil)
        })
    }
    
    func resultDialog() {
        let navigationController = self.storyboard!.instantiateViewControllerWithIdentifier("ResultViewController")// as! UIViewController
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        //formSheetController.presentationController?.shouldApplyBackgroundBlurEffect = true
        //width is first, height is second
        formSheetController.presentationController?.contentViewSize = CGSizeMake(350, 350)
        formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.SlideAndBounceFromRight
        
        //let presentedViewController = navigationController as! ResultViewController
        //presentedViewController.play = self.play
        
        formSheetController.willPresentContentViewControllerHandler = { vc in
            let navigationController = vc
            let presentedViewController = navigationController as! ResultViewController
            presentedViewController.view?.layoutIfNeeded()
        }
        
        let parent: UIViewController! = self.presentingViewController
        
        self.dismissViewControllerAnimated(true, completion: {
            parent.presentViewController(formSheetController, animated: true, completion: nil)
        })
        
    }
    
}

