//
//  RunViewController.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 7/28/16.
//  Copyright © 2016 Jonathan Kerbelis. All rights reserved.
//

import UIKit
import MZFormSheetPresentationController

class RunViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var numberTextField: UITextField!
    @IBOutlet var recent1Btn: UIButton!
    @IBOutlet var recent2Btn: UIButton!
    @IBOutlet var recent3Btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var recentPlayers = [Int]()
        if (game.possFlag) {
            if globalPlay.playType == "Pass" {
                recentPlayers = game.homeTeam.recentReceivers
            }
            else {
                recentPlayers = game.homeTeam.recentRunners
            }
        }
        else {
            if globalPlay.playType == "Pass" {
                recentPlayers = game.awayTeam.recentReceivers
            }
            else {
                recentPlayers = game.awayTeam.recentRunners
            }
        }
        
        switch (recentPlayers.count) {
        case 1:
            recent2Btn.setTitle(String(recentPlayers[0]), forState: .Normal)
            recent1Btn.hidden = true
            recent3Btn.hidden = true
        case 2:
            recent2Btn.setTitle(String(recentPlayers[0]), forState: .Normal)
            recent3Btn.setTitle(String(recentPlayers[1]), forState: .Normal)
            recent1Btn.hidden = true
        case 3:
            recent1Btn.setTitle(String(recentPlayers[0]), forState: .Normal)
            recent2Btn.setTitle(String(recentPlayers[1]), forState: .Normal)
            recent3Btn.setTitle(String(recentPlayers[2]), forState: .Normal)
        default:
            recent1Btn.hidden = true
            recent2Btn.hidden = true
            recent3Btn.hidden = true
        }
        
        numberTextField.keyboardType = UIKeyboardType.NumberPad
        
        if let play = globalPlay {
            if play.playType == "Pass" {
                if play.recNumber != -1 {
                    numberTextField.text = String(play.recNumber)
                }
            }
            else {
                if play.playerNumber != -1 {
                    numberTextField.text = String(play.playerNumber)
                }
            }
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
        if globalPlay.playType == "Pass" {
            passerDialog()
        }
        else {
            playTypeDialog()
        }
    }
    
    @IBAction func rightBtn(sender: UIButton) {
        save()
        if globalPlay.playType == "Pass" && globalPlay.interceptionFlag {
            turnoverDialog()
        }
        else {
            resultDialog()
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
            if globalPlay.playType == "Pass" {
                globalPlay.recNumber = num
            }
            else {
                globalPlay.playerNumber = num
            }
        }
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
    
    func passerDialog() {
        let navigationController = self.storyboard!.instantiateViewControllerWithIdentifier("PasserViewController")// as! UIViewController
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        //formSheetController.presentationController?.shouldApplyBackgroundBlurEffect = true
        //width is first, height is second
        formSheetController.presentationController?.contentViewSize = CGSizeMake(350, 400)
        formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.SlideAndBounceFromRight
        
        
        //let presentedViewController = navigationController as! RunViewController
        //presentedViewController.play = self.play
        
        formSheetController.willPresentContentViewControllerHandler = { vc in
            let navigationController = vc
            let presentedViewController = navigationController as! PasserViewController
            presentedViewController.view?.layoutIfNeeded()
        }
        
        let parent: UIViewController! = self.presentingViewController
        
        self.dismissViewControllerAnimated(true, completion: {
            parent.presentViewController(formSheetController, animated: true, completion: nil)
        })
    }
    
    func turnoverDialog() {
        let navigationController = self.storyboard!.instantiateViewControllerWithIdentifier("FumRecoveryViewController")// as! UIViewController
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        //formSheetController.presentationController?.shouldApplyBackgroundBlurEffect = true
        //width is first, height is second
        formSheetController.presentationController?.contentViewSize = CGSizeMake(350, 450)
        formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.SlideAndBounceFromRight
        
        
        //let presentedViewController = navigationController as! RunViewController
        //presentedViewController.play = self.play
        
        formSheetController.willPresentContentViewControllerHandler = { vc in
            let navigationController = vc
            let presentedViewController = navigationController as! FumRecoveryViewController
            presentedViewController.view?.layoutIfNeeded()
        }
        
        let parent: UIViewController! = self.presentingViewController
        
        self.dismissViewControllerAnimated(true, completion: {
            parent.presentViewController(formSheetController, animated: true, completion: nil)
        })
    }
}
