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
import Toast_Swift

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
    var gnLsData = [Int]()
    var gnLsStrings = [String]()
    
    var ogYdLn: Int = 0
    var ogGnLs: Int = 0
    var pickerNum: Int = 0
    
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
        
        pickerNum = 0
        
        ogGnLs = gnLsData.indexOf(0)!
        ogYdLn = ydLnData.indexOf(globalPlay.ydLn)!
        gnLsPicker.selectItem(gnLsData.indexOf(globalPlay.gnLs)!)
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
        pickerNum += 1        
        if pickerView == gnLsPicker {
            if pickerNum == 1 {
                ydLnPicker.selectItem(gnLsPicker.selectedItem, animated: true)
            }
            else {
                pickerNum = 0
            }
        }
        else if pickerView == ydLnPicker{
            if pickerNum == 1{
                gnLsPicker.selectItem(ydLnPicker.selectedItem, animated: true)
            }
            else {
                pickerNum = 0
            }
        }
        
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
    
    @IBAction func switchChanged(sender: UISwitch) {
        if sender == safetySwitch {
            if sender.on{
                touchdownSwitch.setOn(false, animated: true)
                gnLsPicker.selectItem(0, animated: true)
            }
            else {
                gnLsPicker.selectItem(ogGnLs, animated: true)
            }
        }
        else if sender == touchdownSwitch {
            if sender.on{
                safetySwitch.setOn(false, animated: true)
                gnLsPicker.selectItem(gnLsData.count - 1, animated: true)
            }
            else {
                gnLsPicker.selectItem(ogGnLs, animated: true)
            }
        }
    }

    
    @IBAction func rightBtnClicked(sender: UIButton) {
        save()
    }
    
    @IBAction func leftBtnClicked(sender: UIButton) {
        save()
        if globalPlay.playType == "Pass" {
            if globalPlay.sackFlag || globalPlay.interceptionFlag {
                passerDialog()
            }
            else {
                runDialog("Receiver")
            }
        }
        else {
            runDialog("Runner")
        }
    }
    
    @IBAction func saveBtnClicked(sender: UIButton) {
        saved = true
        save()
        dismiss()
    }
    
    @IBAction func cancelBtnClicked(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func save() {
        globalPlay.ydLn = getYdLnFromIndex(ydLnPicker.selectedItem)
        globalPlay.gnLs = gnLsData[gnLsPicker.selectedItem]
        globalPlay.safetyFlag = safetySwitch.on
        globalPlay.touchdownFlag = touchdownSwitch.on
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
    
    func runDialog(text: String) {
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
            presentedViewController.titleLabel?.text = text
        }
        
        let parent: UIViewController! = self.presentingViewController
        
        self.dismissViewControllerAnimated(true, completion: {
            parent.presentViewController(formSheetController, animated: true, completion: nil)
        })
    }
    
    func showMessage(message: String) {
        self.view.makeToast(message, duration: 3.0, position: .Bottom)
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
}
