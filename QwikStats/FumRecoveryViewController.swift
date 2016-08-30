//
//  FumRecoveryViewController.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 8/6/16.
//  Copyright © 2016 Jonathan Kerbelis. All rights reserved.
//

import UIKit
import MZFormSheetPresentationController
import AKPickerView_Swift

class FumRecoveryViewController: UIViewController, AKPickerViewDataSource, AKPickerViewDelegate {
    @IBOutlet var numberTextField: UITextField!
    @IBOutlet var returnYdsPicker: AKPickerView!
    @IBOutlet var ydLnPicker: AKPickerView!
    @IBOutlet var touchdownSwitch: UISwitch!
    @IBOutlet var safetySwitch: UISwitch!
    
    var gnLsData = [Int]()
    var gnLsStrings = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberTextField.keyboardType = UIKeyboardType.NumberPad
        
        touchdownSwitch.setOn(globalPlay.touchdownFlag, animated: true)
        safetySwitch.setOn(globalPlay.safetyFlag, animated: true)
        
        makeData(globalPlay.ydLn)
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
            ydLnPicker.selectItem(fieldSize - ydLnData.indexOf(globalPlay.ydLn)!, animated: true)
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
        case touchdownSwitch:
            if sender.on {
                safetySwitch.setOn(false, animated: true)
                ydLnPicker.selectItem(ydLnData.count - 1, animated: true)
                returnYdsPicker.selectItem(gnLsData.count-1, animated: true)
            }
        case safetySwitch:
            if sender.on {
                touchdownSwitch.setOn(false, animated: true)
                ydLnPicker.selectItem(0, animated: true)
            }
            
        default: break
        }
    }
    
    @IBAction func leftBtn(sender: UIButton) {
        let formSheetController = mz_formSheetPresentingPresentationController()
        formSheetController!.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.SlideFromRight
        
        save()
        resultDialog()
    }
    
    @IBAction func rightBtn(sender: UIButton) {
        let formSheetController = mz_formSheetPresentingPresentationController()
        formSheetController!.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.SlideFromRight
        
        save()
        playTypeDialog(true)
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
            globalPlay.defNumber = num
            if globalPlay.fumbleFlag {
                globalPlay.fumbleRecFlag = true
            }
        }
        
        globalPlay.returnedYdLn = ydLnData[ydLnPicker.selectedItem]
        globalPlay.returnYds = gnLsData[returnYdsPicker.selectedItem]
        globalPlay.safetyFlag = safetySwitch.on
        globalPlay.touchdownFlag = touchdownSwitch.on
        globalPlay.returnFlag = true
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
    
    func resultDialog() {
        let navigationController = self.storyboard!.instantiateViewControllerWithIdentifier("ResultViewController")// as! UIViewController
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        //formSheetController.presentationController?.shouldApplyBackgroundBlurEffect = true
        //width is first, height is second
        formSheetController.presentationController?.contentViewSize = CGSizeMake(350, 350)
        formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.SlideFromLeft
        
        //let presentedViewController = navigationController as! PlayTypeController
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
