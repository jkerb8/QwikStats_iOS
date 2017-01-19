//
//  RunViewController.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 7/28/16.
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


class RunViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var numberTextField: UITextField!
    @IBOutlet var recent1Btn: UIButton!
    @IBOutlet var recent2Btn: UIButton!
    @IBOutlet var recent3Btn: UIButton!
    @IBOutlet var fumbleSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fumbleSwitch.setOn(globalPlay.fumbleFlag, animated: true)
        
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
            recent2Btn.setTitle(String(recentPlayers[0]), for: UIControlState())
            recent1Btn.isHidden = true
            recent3Btn.isHidden = true
        case 2:
            recent2Btn.setTitle(String(recentPlayers[0]), for: UIControlState())
            recent3Btn.setTitle(String(recentPlayers[1]), for: UIControlState())
            recent1Btn.isHidden = true
        case 3:
            recent1Btn.setTitle(String(recentPlayers[0]), for: UIControlState())
            recent2Btn.setTitle(String(recentPlayers[1]), for: UIControlState())
            recent3Btn.setTitle(String(recentPlayers[2]), for: UIControlState())
        default:
            recent1Btn.isHidden = true
            recent2Btn.isHidden = true
            recent3Btn.isHidden = true
        }
        
        numberTextField.keyboardType = UIKeyboardType.numberPad
        
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
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        
    }
    
    @IBAction func recent1Btn(_ sender: UIButton) {
        if let text = sender.titleLabel?.text {
            numberTextField.text = text
        }
    }
    
    @IBAction func recent2Btn(_ sender: UIButton) {
        if let text = sender.titleLabel?.text {
            numberTextField.text = text
        }
    }
    
    @IBAction func recent3Btn(_ sender: UIButton) {
        if let text = sender.titleLabel?.text {
            numberTextField.text = text
        }
    }
    
    @IBAction func checkMaxLength(_ sender: UITextField) {
        if sender.text?.characters.count > 2 {
            sender.deleteBackward()
        }
    }
    
    @IBAction func leftBtn(_ sender: UIButton) {
        let formSheetController = mz_formSheetPresentingPresentationController()
        formSheetController!.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.slideFromRight
        
        save()
        if globalPlay.playType == "Pass" {
            passerDialog()
        }
        else {
            playTypeDialog()
        }
    }
    
    @IBAction func rightBtn(_ sender: UIButton) {
        let formSheetController = mz_formSheetPresentingPresentationController()
        formSheetController!.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.slideFromLeft
        
        save()
        if (globalPlay.playType == "Pass" && globalPlay.interceptionFlag) {
            turnoverDialog()
        }
        else {
            resultDialog()
        }
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
        if let num = Int(numberTextField.text!) {
            globalPlay.fumbleFlag = fumbleSwitch.isOn
            if globalPlay.playType == "Pass" {
                globalPlay.recNumber = num
            }
            else {
                globalPlay.playerNumber = num
            }
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

    func playTypeDialog() {
        let navigationController = self.storyboard!.instantiateViewController(withIdentifier: "PlayTypeController")// as! UIViewController
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        //formSheetController.presentationController?.shouldApplyBackgroundBlurEffect = true
        //width is first, height is second
        formSheetController.presentationController?.contentViewSize = CGSize(width: 350, height: 300)
        formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.slideFromLeft
        
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
    
    func resultDialog() {
        let navigationController = self.storyboard!.instantiateViewController(withIdentifier: "ResultViewController")// as! UIViewController
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        //formSheetController.presentationController?.shouldApplyBackgroundBlurEffect = true
        //width is first, height is second
        formSheetController.presentationController?.contentViewSize = CGSize(width: 350, height: 350)
        formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.slideFromRight
        
        //let presentedViewController = navigationController as! ResultViewController
        //presentedViewController.play = self.play
        
        formSheetController.willPresentContentViewControllerHandler = { vc in
            let navigationController = vc
            let presentedViewController = navigationController as! ResultViewController
            presentedViewController.view?.layoutIfNeeded()
        }
        
        let parent: UIViewController! = self.presentingViewController
        
        self.dismiss(animated: true, completion: {
            parent.present(formSheetController, animated: true, completion: nil)
        })
        
    }
    
    func passerDialog() {
        let navigationController = self.storyboard!.instantiateViewController(withIdentifier: "PasserViewController")// as! UIViewController
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        //formSheetController.presentationController?.shouldApplyBackgroundBlurEffect = true
        //width is first, height is second
        formSheetController.presentationController?.contentViewSize = CGSize(width: 350, height: 400)
        formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.slideFromLeft
        
        
        //let presentedViewController = navigationController as! RunViewController
        //presentedViewController.play = self.play
        
        formSheetController.willPresentContentViewControllerHandler = { vc in
            let navigationController = vc
            let presentedViewController = navigationController as! PasserViewController
            presentedViewController.view?.layoutIfNeeded()
        }
        
        let parent: UIViewController! = self.presentingViewController
        
        self.dismiss(animated: true, completion: {
            parent.present(formSheetController, animated: true, completion: nil)
        })
    }
    
    func turnoverDialog() {
        let navigationController = self.storyboard!.instantiateViewController(withIdentifier: "FumRecoveryViewController")// as! UIViewController
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        //formSheetController.presentationController?.shouldApplyBackgroundBlurEffect = true
        //width is first, height is second
        formSheetController.presentationController?.contentViewSize = CGSize(width: 350, height: 450)
        formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.slideFromRight
        
        
        //let presentedViewController = navigationController as! RunViewController
        //presentedViewController.play = self.play
        
        formSheetController.willPresentContentViewControllerHandler = { vc in
            let navigationController = vc
            let presentedViewController = navigationController as! FumRecoveryViewController
            presentedViewController.view?.layoutIfNeeded()
        }
        
        let parent: UIViewController! = self.presentingViewController
        
        self.dismiss(animated: true, completion: {
            parent.present(formSheetController, animated: true, completion: nil)
        })
    }
}
