//
//  TackleViewController.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 8/6/16.
//  Copyright © 2016 Jonathan Kerbelis. All rights reserved.
//

import UIKit
import MZFormSheetPresentationController
import Toast_Swift

class TackleViewController: UIViewController {
    @IBOutlet var numberTextField: UITextField!
    @IBOutlet var addTacklerBtn: UIButton!
    var additionalTacklers = [UITextField]()
    
    let textHeight: CGFloat = 30
    let textWidth: CGFloat = 100
    var textYPos: CGFloat = 83
    let textXPos: CGFloat = 125
    let btnHeight: CGFloat = 30
    let btnWidth: CGFloat = 46
    var btnYPos: CGFloat = 128
    let btnXPos: CGFloat = 152
    let plusY: CGFloat = 45
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberTextField.keyboardType = UIKeyboardType.NumberPad
        
        if globalPlay.tacklers.count > 0 {
            numberTextField.text = String(globalPlay.tacklers[0])
            for i in 1.stride(to: globalPlay.tacklers.count, by: 1) {
                addTackler(i)
            }
        }
    }
    
    @IBAction func addTacklerBtn(sender: UIButton) {
        addTackler(additionalTacklers.count + 1)
    }
    
    func addTackler(id: Int) {
        if additionalTacklers.count >= 4 {
            showMessage("Max number of tacklers is 5")
        }
        else if numberTextField.text == ""{
            showMessage("Please input first tackler")
        }
        else {
            textYPos += plusY
            btnYPos += plusY
            
            let textField = UITextField.init(frame: CGRectMake(textXPos, textYPos, textWidth, textHeight))
            textField.addTarget(self, action: #selector(checkMaxLength(_:)), forControlEvents: UIControlEvents.EditingChanged)
            textField.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
            textField.tag = id
            
            if globalPlay.tacklers.count > id {
                textField.text = String(globalPlay.tacklers[id])
            }
            
            additionalTacklers.append(textField)
            addTacklerBtn.frame = CGRectMake(btnXPos, btnYPos, btnWidth, btnHeight)
            
            //self.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height + plusY)
            self.view.addSubview(textField)
        }
    }
    
    @IBAction func checkMaxLength(sender: UITextField) {
        if sender.text?.characters.count > 2 {
            sender.deleteBackward()
        }
    }
    
    @IBAction func leftBtn(sender: UIButton) {
        save()
        if globalPlay.playType == "Kickoff" || globalPlay.playType == "Punt" {
            returnerDialog()
        }
        else {
            resultDialog()
        }
    }
    
    @IBAction func rightBtn(sender: UIButton) {
        save()
        //hashDirDialog()
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
            globalPlay.tacklers = [Int]()
            globalPlay.tacklers.append(num)
            globalPlay.tackleFlag = true
            
            for i in 0.stride(to: additionalTacklers.count, by: 1) {
                if let num = Int(additionalTacklers[i].text!) {
                    if !globalPlay.tacklers.contains(num) {
                        globalPlay.tacklers.append(num)
                    }
                }
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
    
    func showMessage(message: String) {
        self.view.makeToast(message, duration: 3.0, position: .Bottom)
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
    
    func hashDirDialog() {
        let navigationController = self.storyboard!.instantiateViewControllerWithIdentifier("HashDirViewController")// as! UIViewController
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
            let presentedViewController = navigationController as! HashDirViewController
            presentedViewController.view?.layoutIfNeeded()
        }
        
        let parent: UIViewController! = self.presentingViewController
        
        self.dismissViewControllerAnimated(true, completion: {
            parent.presentViewController(formSheetController, animated: true, completion: nil)
        })
    }
    
    func returnerDialog() {
        let navigationController = self.storyboard!.instantiateViewControllerWithIdentifier("ReturnerViewController")// as! UIViewController
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        //formSheetController.presentationController?.shouldApplyBackgroundBlurEffect = true
        //width is first, height is second
        formSheetController.presentationController?.contentViewSize = CGSizeMake(350, 520)
        formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.SlideAndBounceFromRight
        
        
        //let presentedViewController = navigationController as! RunViewController
        //presentedViewController.play = self.play
        
        formSheetController.willPresentContentViewControllerHandler = { vc in
            let navigationController = vc
            let presentedViewController = navigationController as! ReturnerViewController
            presentedViewController.view?.layoutIfNeeded()
        }
        
        let parent: UIViewController! = self.presentingViewController
        
        self.dismissViewControllerAnimated(true, completion: {
            parent.presentViewController(formSheetController, animated: true, completion: nil)
        })
    }

}
