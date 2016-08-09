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
        
        numberTextField.keyboardType = UIKeyboardType.NumberPad
        
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
        
        returnYdsPicker.selectItem(gnLsData.indexOf(globalPlay.returnYds)!)
        
        if globalPlay.returnedYdLn != -51 {
            ydLnPicker.selectItem(ydLnData.indexOf(globalPlay.returnedYdLn)!)
        }
        else {
            if (gamePlays.count > 0) {
                if gamePlays[gamePlays.count - 1].playType == "Field Goal" {
                    ydLnPicker.selectItem(ydLnData.indexOf(0)!, animated: true)
                }
                else {
                    ydLnPicker.selectItem(ydLnData.indexOf(globalPlay.prevYdLn)!)
                }
            }
            else {
                ydLnPicker.selectItem(ydLnData.indexOf(globalPlay.prevYdLn)!)
            }
        }
    }
    
    func makeData(prevYdLn: Int) {
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
        
        for i in minIndex.stride(to: maxIndex+1, by: 1) {
            gnLsData.append(i)
            gnLsStrings.append(" \(String(i)) ")
        }
        
    }
    
    func numberOfItemsInPickerView(pickerView: AKPickerView) -> Int {
        if pickerView == returnYdsPicker {
            return self.gnLsData.count
        }
        else {
            return ydLnData.count
        }
    }
    
    func pickerView(pickerView: AKPickerView, titleForItem item: Int) -> String {
        if pickerView == returnYdsPicker {
            return self.gnLsStrings[item]
        }
        else {
            return ydLnStrings[item]
        }
    }
    
    func pickerView(pickerView: AKPickerView, didSelectItem item: Int) {
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
    
    @IBAction func checkMaxLength(sender: AnyObject) {
        if sender.text?.characters.count > 3 {
            sender.deleteBackward()
        }
    }
    
    @IBAction func switchChanged(sender: UISwitch) {
        switch(sender) {
        case noReturnSwitch:
            if sender.on {
                touchdownSwitch.setOn(false, animated: true)
                safetySwitch.setOn(false, animated: true)
                returnYdsPicker.selectItem(gnLsData.indexOf(0)!, animated: true)
            }
            else {
                touchbackSwitch.setOn(false, animated: true)
                fairCatchSwitch.setOn(false, animated: true)
            }
            
        case touchdownSwitch:
            if sender.on {
                noReturnSwitch.setOn(false, animated: true)
                fairCatchSwitch.setOn(false, animated: true)
                touchbackSwitch.setOn(false, animated: true)
                safetySwitch.setOn(false, animated: true)
                ydLnPicker.selectItem(ydLnData.count - 1, animated: true)
                returnYdsPicker.selectItem(gnLsData.count-1, animated: true)
            }
            
        case fairCatchSwitch:
            if sender.on {
                noReturnSwitch.setOn(true, animated: true)
                touchdownSwitch.setOn(false, animated: true)
                touchbackSwitch.setOn(false, animated: true)
                safetySwitch.setOn(false, animated: true)
                returnYdsPicker.selectItem(gnLsData.indexOf(0)!, animated: true)
            }
            
        case touchbackSwitch:
            if sender.on {
                noReturnSwitch.setOn(true, animated: true)
                touchdownSwitch.setOn(false, animated: true)
                fairCatchSwitch.setOn(false, animated: true)
                safetySwitch.setOn(false, animated: true)
                returnYdsPicker.selectItem(gnLsData.indexOf(0)!, animated: true)
                
                if fieldSize == 80 {
                    ydLnPicker.selectItem(ydLnData.indexOf(-15)!, animated: true)
                }
                else {
                    ydLnPicker.selectItem(ydLnData.indexOf(-25)!, animated: true)
                }
                numberTextField.text = ""
            }
            
        case safetySwitch:
            if sender.on {
                noReturnSwitch.setOn(false, animated: true)
                fairCatchSwitch.setOn(false, animated: true)
                touchbackSwitch.setOn(false, animated: true)
                touchdownSwitch.setOn(false, animated: true)
                ydLnPicker.selectItem(0, animated: true)
            }
            
        default: break
        }
    }
    
    @IBAction func leftBtn(sender: UIButton) {
        save()
        playTypeDialog()
    }
    
    @IBAction func rightBtn(sender: UIButton) {
        save()
        //tackleDialog()
    }
    
    @IBAction func saveBtn(sender: UIButton) {
        saved = true
        save()
        dismiss()
    }
    
    @IBAction func cancelBtn(sender: UIButton) {
        dismiss()
    }
    
    func save() {
        if let num = Int(numberTextField.text!) {
            globalPlay.playerNumber = num
        }
        
        globalPlay.returnedYdLn = ydLnData[ydLnPicker.selectedItem]
        globalPlay.returnYds = gnLsData[returnYdsPicker.selectedItem]
        globalPlay.safetyFlag = safetySwitch.on
        globalPlay.touchdownFlag = touchdownSwitch.on
        globalPlay.faircatchFlag = fairCatchSwitch.on
        globalPlay.returnFlag = !noReturnSwitch.on
        globalPlay.touchbackFlag = touchbackSwitch.on
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
    
}
