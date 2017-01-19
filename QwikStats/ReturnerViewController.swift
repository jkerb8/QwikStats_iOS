//
//  ReturnerViewController.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 8/6/16.
//  Copyright © 2016 Jonathan Kerbelis. All rights reserved.
//

import UIKit
import MZFormSheetPresentationController
import AKPickerView_Swift
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


class ReturnerViewController: UIViewController, AKPickerViewDataSource, AKPickerViewDelegate {
    
    @IBOutlet var numberTextField: UITextField!
    @IBOutlet var returnYdsPicker: AKPickerView!
    @IBOutlet var ydLnPicker: AKPickerView!
    @IBOutlet var noReturnSwitch: UISwitch!
    @IBOutlet var touchdownSwitch: UISwitch!
    @IBOutlet var fairCatchSwitch: UISwitch!
    @IBOutlet var touchbackSwitch: UISwitch!
    @IBOutlet var safetySwitch: UISwitch!
    
    var gnLsData = [Int]()
    var gnLsStrings = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberTextField.keyboardType = UIKeyboardType.numberPad
        
        noReturnSwitch.setOn(globalPlay.returnFlag, animated: true)
        touchdownSwitch.setOn(globalPlay.touchdownFlag, animated: true)
        fairCatchSwitch.setOn(globalPlay.faircatchFlag, animated: true)
        touchbackSwitch.setOn(globalPlay.touchbackFlag, animated: true)
        safetySwitch.setOn(globalPlay.safetyFlag, animated: true)
        
        makeData(globalPlay.prevYdLn)
        addAKPickers()
    }
    
    func addAKPickers() {
        returnYdsPicker = AKPickerView(frame: CGRect(x: 79, y: 140, width: 186, height: 41))
        ydLnPicker = AKPickerView(frame: CGRect(x: 79, y: 225, width: 186, height: 41))
        
        self.view.addSubview(returnYdsPicker)
        self.view.addSubview(ydLnPicker)
        
        ydLnPicker.dataSource = self
        ydLnPicker.delegate = self
        returnYdsPicker.dataSource = self
        returnYdsPicker.delegate = self
        
        returnYdsPicker.selectItem(gnLsData.index(of: globalPlay.returnYds)!)
        
        if globalPlay.returnedYdLn != -51 {
            ydLnPicker.selectItem(ydLnData.index(of: globalPlay.returnedYdLn)!)
        }
        else {
            if (gamePlays.count > 0) {
                if gamePlays[gamePlays.count - 1].playType == "Field Goal" {
                    ydLnPicker.selectItem(ydLnData.index(of: 0)!, animated: true)
                }
                else {
                    ydLnPicker.selectItem(ydLnData.index(of: globalPlay.prevYdLn)!)
                }
            }
            else {
                ydLnPicker.selectItem(ydLnData.index(of: globalPlay.prevYdLn)!)
            }
        }
    }
    
    func makeData(_ prevYdLn: Int) {
        //make the gnls data
        var minIndex = 0, maxIndex = 0
        if prevYdLn < 0 {
            minIndex = prevYdLn
            maxIndex = fieldSize + prevYdLn
        }
        else if prevYdLn == 0 {
            minIndex = prevYdLn
            maxIndex = fieldSize
        }
        else {
            minIndex = -1*(fieldSize - prevYdLn)
            maxIndex = prevYdLn
        }
        
        for i in stride(from: minIndex, to: maxIndex+1, by: 1) {
            gnLsData.append(i)
            gnLsStrings.append(" \(String(i)) ")
        }
        
    }
    
    func numberOfItemsInPickerView(_ pickerView: AKPickerView) -> Int {
        if pickerView == returnYdsPicker {
            return self.gnLsData.count
        }
        else {
            return ydLnData.count
        }
    }
    
    func pickerView(_ pickerView: AKPickerView, titleForItem item: Int) -> String {
        if pickerView == returnYdsPicker {
            return self.gnLsStrings[item]
        }
        else {
            return ydLnStrings[item]
        }
    }
    
    func pickerView(_ pickerView: AKPickerView, didSelectItem item: Int) {
        //this is the code for when they select an item
        if pickerView == returnYdsPicker {
            if gnLsData[pickerView.selectedItem] != 0 {
                noReturnSwitch.setOn(false, animated: true)
                fairCatchSwitch.setOn(false, animated: true)
                touchbackSwitch.setOn(false, animated: true)
            }
        }
        else {
            if pickerView.selectedItem == (ydLnData.count - 1) {
                touchdownSwitch.setOn(true, animated: true)
            }
            else {
                touchdownSwitch.setOn(false, animated: true)
            }
            
            if pickerView.selectedItem == 0 {
                safetySwitch.setOn(true, animated: true)
            }
            else {
                safetySwitch.setOn(false, animated: true)
            }
        }
    }
    
    @IBAction func checkMaxLength(_ sender: AnyObject) {
        if sender.text?.characters.count > 3 {
            sender.deleteBackward()
        }
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        switch(sender) {
        case noReturnSwitch:
            if sender.isOn {
                touchdownSwitch.setOn(false, animated: true)
                safetySwitch.setOn(false, animated: true)
                returnYdsPicker.selectItem(gnLsData.index(of: 0)!, animated: true)
            }
            else {
                touchbackSwitch.setOn(false, animated: true)
                fairCatchSwitch.setOn(false, animated: true)
            }
            
        case touchdownSwitch:
            if sender.isOn {
                noReturnSwitch.setOn(false, animated: true)
                fairCatchSwitch.setOn(false, animated: true)
                touchbackSwitch.setOn(false, animated: true)
                safetySwitch.setOn(false, animated: true)
                ydLnPicker.selectItem(ydLnData.count - 1, animated: true)
                returnYdsPicker.selectItem(gnLsData.count-1, animated: true)
            }
            
        case fairCatchSwitch:
            if sender.isOn {
                noReturnSwitch.setOn(true, animated: true)
                touchdownSwitch.setOn(false, animated: true)
                touchbackSwitch.setOn(false, animated: true)
                safetySwitch.setOn(false, animated: true)
                returnYdsPicker.selectItem(gnLsData.index(of: 0)!, animated: true)
            }
            
        case touchbackSwitch:
            if sender.isOn {
                noReturnSwitch.setOn(true, animated: true)
                touchdownSwitch.setOn(false, animated: true)
                fairCatchSwitch.setOn(false, animated: true)
                safetySwitch.setOn(false, animated: true)
                returnYdsPicker.selectItem(gnLsData.index(of: 0)!, animated: true)
                
                if fieldSize == 80 {
                    ydLnPicker.selectItem(ydLnData.index(of: -15)!, animated: true)
                }
                else {
                    ydLnPicker.selectItem(ydLnData.index(of: -25)!, animated: true)
                }
                numberTextField.text = ""
            }
            
        case safetySwitch:
            if sender.isOn {
                noReturnSwitch.setOn(false, animated: true)
                fairCatchSwitch.setOn(false, animated: true)
                touchbackSwitch.setOn(false, animated: true)
                touchdownSwitch.setOn(false, animated: true)
                ydLnPicker.selectItem(0, animated: true)
            }
            
        default: break
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
        if globalPlay.returnFlag && !globalPlay.touchdownFlag{
            tackleDialog()
        }
        else {
            playTypeDialog(true)
        }
    }
    
    @IBAction func saveBtn(_ sender: UIButton) {
        saved = true
        save()
        dismiss()
    }
    
    @IBAction func cancelBtn(_ sender: UIButton) {
        dismiss()
    }
    
    func save() {
        if let num = Int(numberTextField.text!) {
            globalPlay.playerNumber = num
        }
        
        globalPlay.returnedYdLn = ydLnData[ydLnPicker.selectedItem]
        globalPlay.returnYds = gnLsData[returnYdsPicker.selectedItem]
        globalPlay.safetyFlag = safetySwitch.isOn
        globalPlay.touchdownFlag = touchdownSwitch.isOn
        globalPlay.faircatchFlag = fairCatchSwitch.isOn
        globalPlay.returnFlag = !noReturnSwitch.isOn
        globalPlay.touchbackFlag = touchbackSwitch.isOn
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
    
    func tackleDialog() {
        let navigationController = self.storyboard!.instantiateViewController(withIdentifier: "TackleViewController")// as! UIViewController
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        //formSheetController.presentationController?.shouldApplyBackgroundBlurEffect = true
        //width is first, height is second
        formSheetController.presentationController?.contentViewSize = CGSize(width: 350, height: 200)
        formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.slideFromRight
        
        
        //let presentedViewController = navigationController as! RunViewController
        //presentedViewController.play = self.play
        
        formSheetController.willPresentContentViewControllerHandler = { vc in
            let navigationController = vc
            let presentedViewController = navigationController as! TackleViewController
            presentedViewController.view?.layoutIfNeeded()
        }
        
        let parent: UIViewController! = self.presentingViewController
        
        self.dismiss(animated: true, completion: {
            parent.present(formSheetController, animated: true, completion: nil)
        })
    }
}
