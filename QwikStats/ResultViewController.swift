//
//  ResultViewController.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 7/28/16.
//  Copyright © 2016 Jonathan Kerbelis. All rights reserved.
//

import UIKit
import MZFormSheetPresentationController
import AKPickerView_Swift

class ResultViewController: UIViewController, AKPickerViewDataSource, AKPickerViewDelegate {
    
    @IBOutlet var gnLsLabel: UILabel!
    @IBOutlet var ydLnLabel: UILabel!
    @IBOutlet var safetySwitch: UISwitch!
    @IBOutlet var touchdownSwitch: UISwitch!
    @IBOutlet var gnLsPicker: AKPickerView!
    @IBOutlet var ydLnPicker: AKPickerView!
    
    @IBOutlet var rightBtn: UIButton!
    @IBOutlet var leftBtn: UIButton!
    
    var play: Play!
    var gnLsData = [String]()
    var gnLsStrings = [String]()
    //var ydLnData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        safetySwitch.setOn(globalPlay.safetyFlag, animated: true)
        touchdownSwitch.setOn(globalPlay.touchdownFlag, animated: true)
        
        makeData(globalPlay.prevYdLn)
        addAKPickers()
    }
    
    func addAKPickers() {
        gnLsPicker = AKPickerView(frame: CGRect(x: 79, y: 65, width: 186, height: 41))
        ydLnPicker = AKPickerView(frame: CGRect(x: 79, y: 152, width: 186, height: 41))
        
        self.view.addSubview(gnLsPicker)
        self.view.addSubview(ydLnPicker)
        
        ydLnPicker.dataSource = self
        ydLnPicker.delegate = self
        gnLsPicker.dataSource = self
        gnLsPicker.delegate = self
        
        //gnLsPicker.center = CGPointMake(self.preferredContentSize.width/2, gnLsLabel.center.y - 20)
        //ydLnPicker.center = CGPointMake(self.preferredContentSize.width/2, ydLnLabel.center.y - 20)
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
            gnLsData.append(String(i))
            gnLsStrings.append(" \(String(i)) ")
        }
        
    }
    
    func getIndexFromYdLn(prevYdLn: Int) -> Int {
        var index = 0
        if prevYdLn <= 0 {
            index = -1 * prevYdLn
        }
        else {
            index = fieldSize - prevYdLn
        }
        return index
    }
    
    func getYdLnFromIndex(index: Int) -> Int {
        var ydLn = 0
        if index<(fieldSize/2) {
            ydLn = -1 * index
        }
        else if (index == (fieldSize+1)) {
            ydLn = 0
        }
        else {
            ydLn = fieldSize - index
        }
        return ydLn
    }
    
    @IBAction func checkMaxLength(sender: AnyObject) {
        if sender.text?.characters.count > 3 {
            sender.deleteBackward()
        }
    }
    
    func numberOfItemsInPickerView(pickerView: AKPickerView) -> Int {
        if pickerView == gnLsPicker {
            return self.gnLsData.count
        }
        else {
            return ydLnData.count
        }
    }
    
    func pickerView(pickerView: AKPickerView, titleForItem item: Int) -> String {
        if pickerView == gnLsPicker {
            return self.gnLsStrings[item]
        }
        else {
            return ydLnStrings[item]
        }
    }
    
    func pickerView(pickerView: AKPickerView, didSelectItem item: Int) {
        //this is the code for when they select an item
        if pickerView == gnLsPicker {
            //move the ydLnPicker accordingly
        }
        else {
            //move the gnLsPicker accordingly
        }
        
    }
    
    @IBAction func safetySwitchChanged(sender: UISwitch) {
        if sender.on {
            touchdownSwitch.setOn(false, animated: true)
            //ydLnTextField.text = "0"
            
            var gnLs: Int
            if globalPlay.prevYdLn < 0 {
                gnLs = globalPlay.prevYdLn
            }
            else {
                gnLs = fieldSize - globalPlay.prevYdLn
            }
            //gnLsTextField.text = String(gnLs)
        }
    }
    
    @IBAction func touchdownSwitchChanged(sender: UISwitch) {
        if sender.on {
            safetySwitch.setOn(false, animated: true)
            //ydLnTextField.text = "0"
            
            var gnLs: Int
            if globalPlay.prevYdLn < 0 {
                gnLs = globalPlay.prevYdLn + fieldSize
            }
            else {
                gnLs = globalPlay.prevYdLn
            }
            //gnLsTextField.text = String(gnLs)
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
        /*if let gnLs = Int(gnLsTextField.text!) {
            globalPlay.gnLs = gnLs
        }
        if let ydLn = Int(ydLnTextField.text!) {
            globalPlay.ydLn = ydLn
        }*/
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
