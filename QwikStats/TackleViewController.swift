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


class TackleViewController: UIViewController {
    @IBOutlet var numberTextField: UITextField!
    @IBOutlet var addTacklerBtn: UIButton!
    @IBOutlet var saveBtn: UIButton!
    @IBOutlet var cancelBtn: UIButton!
    
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
    let windowX: CGFloat = 350
    var windowY: CGFloat = 200
    let saveWidth: CGFloat = 89
    let saveHeight: CGFloat = 30
    var saveY: CGFloat = 166
    let saveX: CGFloat = 199
    let cancelX: CGFloat = 62
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberTextField.keyboardType = UIKeyboardType.numberPad
        self.view.superview?.translatesAutoresizingMaskIntoConstraints = true
        
        if globalPlay.tacklers.count > 0 {
            numberTextField.text = String(globalPlay.tacklers[0])
            for i in stride(from: 1, to: globalPlay.tacklers.count, by: 1) {
                addTackler(i)
            }
        }
    }
    
    @IBAction func addTacklerBtn(_ sender: UIButton) {
        addTackler(additionalTacklers.count + 1)
    }
    
    func addTackler(_ id: Int) {
        if additionalTacklers.count >= 4 {
            showMessage("Max number of tacklers is 5")
        }
        else if numberTextField.text == ""{
            showMessage("Please input first tackler")
        }
        else {
            textYPos += plusY
            btnYPos += plusY
            windowY += plusY
            saveY += plusY
            
            self.view.superview?.bounds = CGRect(x: 0, y: 0, width: windowX, height: windowY)
            self.preferredContentSize = CGSize(width: windowX, height: windowY   )
            
            let textField = UITextField.init(frame: CGRect(x: textXPos, y: textYPos, width: textWidth, height: textHeight))
            textField.addTarget(self, action: #selector(checkMaxLength(_:)), for: UIControlEvents.editingChanged)
            textField.addTarget(self, action: #selector(textFieldTouched(_:)), for: UIControlEvents.allEvents)
            textField.textAlignment = .center
            textField.tag = id
            textField.keyboardType = UIKeyboardType.numberPad
            
            if globalPlay.tacklers.count > id {
                textField.text = String(globalPlay.tacklers[id])
            }
            
            additionalTacklers.append(textField)
            addTacklerBtn.translatesAutoresizingMaskIntoConstraints = true
            saveBtn.translatesAutoresizingMaskIntoConstraints = true
            cancelBtn.translatesAutoresizingMaskIntoConstraints = true
            addTacklerBtn.frame = CGRect(x: btnXPos, y: btnYPos, width: btnWidth, height: btnHeight)
            saveBtn.frame = CGRect(x: saveX, y: saveY, width: saveWidth, height: saveHeight)
            cancelBtn.frame = CGRect(x: cancelX, y: saveY, width: saveWidth, height: saveHeight)
            
            self.view.addSubview(textField)
            self.view.translatesAutoresizingMaskIntoConstraints = true
        }
    }
    
    @IBAction func checkMaxLength(_ sender: UITextField) {
        if sender.text?.characters.count > 2 {
            sender.deleteBackward()
        }
    }
    
    @IBAction func textFieldTouched(_ sender: UITextField) {
        self.view.superview?.bounds = CGRect(x: 0, y: 0, width: windowX, height: windowY)
    }
    
    @IBAction func leftBtn(_ sender: UIButton) {
        let formSheetController = mz_formSheetPresentingPresentationController()
        formSheetController!.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.slideFromRight
        
        save()
        if globalPlay.playType == "Kickoff" || globalPlay.playType == "Punt" {
            returnerDialog()
        }
        else {
            resultDialog()
        }
    }
    
    @IBAction func rightBtn(_ sender: UIButton) {
        let formSheetController = mz_formSheetPresentingPresentationController()
        formSheetController!.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.slideFromLeft
        
        save()
        playTypeDialog(true)
        //hashDirDialog() once it's available
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
            globalPlay.tacklers = [Int]()
            globalPlay.tacklers.append(num)
            globalPlay.tackleFlag = true
            
            for i in stride(from: 0, to: additionalTacklers.count, by: 1) {
                if let num = Int(additionalTacklers[i].text!) {
                    if !globalPlay.tacklers.contains(num) {
                        globalPlay.tacklers.append(num)
                    }
                }
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
    
    func showMessage(_ message: String) {
        self.view.makeToast(message, duration: 3.0, position: .bottom)
    }
    
    func resultDialog() {
        let navigationController = self.storyboard!.instantiateViewController(withIdentifier: "ResultViewController")// as! UIViewController
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        //formSheetController.presentationController?.shouldApplyBackgroundBlurEffect = true
        //width is first, height is second
        formSheetController.presentationController?.contentViewSize = CGSize(width: 350, height: 350)
        formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.slideFromLeft
        
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
    
    func hashDirDialog() {
        let navigationController = self.storyboard!.instantiateViewController(withIdentifier: "HashDirViewController")// as! UIViewController
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
            let presentedViewController = navigationController as! HashDirViewController
            presentedViewController.view?.layoutIfNeeded()
        }
        
        let parent: UIViewController! = self.presentingViewController
        
        self.dismiss(animated: true, completion: {
            parent.present(formSheetController, animated: true, completion: nil)
        })
    }
    
    func returnerDialog() {
        let navigationController = self.storyboard!.instantiateViewController(withIdentifier: "ReturnerViewController")// as! UIViewController
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        //formSheetController.presentationController?.shouldApplyBackgroundBlurEffect = true
        //width is first, height is second
        formSheetController.presentationController?.contentViewSize = CGSize(width: 350, height: 520)
        formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.slideFromLeft
        
        
        //let presentedViewController = navigationController as! RunViewController
        //presentedViewController.play = self.play
        
        formSheetController.willPresentContentViewControllerHandler = { vc in
            let navigationController = vc
            let presentedViewController = navigationController as! ReturnerViewController
            presentedViewController.view?.layoutIfNeeded()
        }
        
        let parent: UIViewController! = self.presentingViewController
        
        self.dismiss(animated: true, completion: {
            parent.present(formSheetController, animated: true, completion: nil)
        })
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
