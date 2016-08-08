//
//  PenaltyViewController.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 8/6/16.
//  Copyright © 2016 Jonathan Kerbelis. All rights reserved.
//

import UIKit
import MZFormSheetPresentationController
import AKPickerView_Swift

class PenaltyViewController: UIViewController, AKPickerViewDataSource, AKPickerViewDelegate {
    
    @IBOutlet var penYdsPicker: AKPickerView!
    @IBOutlet var ydLnPicker: AKPickerView!
    @IBOutlet var offenseSwitch: UISwitch!
    @IBOutlet var defenseSwitch: UISwitch!
    @IBOutlet var fiveYdBtn: UIButton!
    @IBOutlet var tenYdBtn: UIButton!
    @IBOutlet var fifteenYdBtn: UIButton!
    
    var gnLsData = [Int]()
    var gnLsStrings = [String]()
    
    var ogYdLn: Int = 0
    var ogGnLs: Int = 0
    var pickerNum: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if globalPlay.defensivePenalty {
            defenseSwitch.setOn(true, animated: true)
            offenseSwitch.setOn(false, animated: true)
        }
        else {
            offenseSwitch.setOn(true, animated: true)
            defenseSwitch.setOn(false, animated: true)
        }
        
        makeData(globalPlay.prevYdLn)
        addAKPickers()
    }
    
    func addAKPickers() {
        penYdsPicker = AKPickerView(frame: CGRect(x: 79, y: 65, width: 186, height: 41))
        ydLnPicker = AKPickerView(frame: CGRect(x: 79, y: 152, width: 186, height: 41))
        
        self.view.addSubview(penYdsPicker)
        self.view.addSubview(ydLnPicker)
        
        ydLnPicker.dataSource = self
        ydLnPicker.delegate = self
        penYdsPicker.dataSource = self
        penYdsPicker.delegate = self
        
        pickerNum = 0
        
        ogGnLs = gnLsData.indexOf(0)!
        ogYdLn = ydLnData.indexOf(globalPlay.prevYdLn)!
        penYdsPicker.selectItem(gnLsData.indexOf(abs(globalPlay.gnLs))!)
    }
    
    func makeData(prevYdLn: Int) {
        //make the gnls data
        var minIndex = 0, maxIndex = 0
        if prevYdLn < 0 {
            maxIndex = fieldSize + prevYdLn
        }
        else if prevYdLn == 0 {
            maxIndex = fieldSize
        }
        else {
            maxIndex = prevYdLn
        }
        
        for i in minIndex.stride(to: maxIndex+1, by: 1) {
            gnLsData.append(i)
            gnLsStrings.append(" \(String(i)) ")
        }
        
    }
    
    func numberOfItemsInPickerView(pickerView: AKPickerView) -> Int {
        if pickerView == penYdsPicker {
            return self.gnLsData.count
        }
        else {
            return ydLnData.count
        }
    }
    
    func pickerView(pickerView: AKPickerView, titleForItem item: Int) -> String {
        if pickerView == penYdsPicker {
            return self.gnLsStrings[item]
        }
        else {
            return ydLnStrings[item]
        }
    }
    
    func pickerView(pickerView: AKPickerView, didSelectItem item: Int) {
        //this is the code for when they select an item
        pickerNum += 1
        var i = 0
        if pickerView == penYdsPicker {
            if pickerNum == 1 {
                if offenseSwitch.on {
                    i = ogYdLn - penYdsPicker.selectedItem
                }
                else if defenseSwitch.on {
                    i = ogYdLn + penYdsPicker.selectedItem
                }
                if i<0 {
                    i=0
                }
                else if i>fieldSize-1 {
                    i = fieldSize-1
                }
                ydLnPicker.selectItem(i, animated: true)
            }
            else {
                pickerNum = 0
            }
        }
        else if pickerView == ydLnPicker{
            if pickerNum == 1{
                //we don't need to change nuthin
            }
            else {
                pickerNum = 0
            }
        }
    }
    
    @IBAction func ydBtnClicked(sender: UIButton) {
        //let prev = ydLnData.indexOf(globalPlay.prevYdLn)
        //var newYdLn: Int
        //var diff: Int = 0
        
        if sender == fiveYdBtn {
            //diff = 5
            penYdsPicker.selectItem(5, animated: true)
        }
        else if sender == tenYdBtn {
            //diff = 10
            penYdsPicker.selectItem(10, animated: true)
        }
        else if sender == fifteenYdBtn {
            //diff = 15
            penYdsPicker.selectItem(15, animated: true)
        }
    }
    
    @IBAction func leftBtn(sender: UIButton) {
        save()
        playTypeDialog()
    }
    
    @IBAction func rightBtn(sender: UIButton) {
        save()
        playTypeDialog()
    }
    
    @IBAction func saveBtn(sender: UIButton) {
        saved = true
        save()
        dismiss()
    }
    
    @IBAction func cancelBtn(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func switchChanged(sender: UISwitch) {
        if sender == offenseSwitch {
            if sender.on{
                defenseSwitch.setOn(false, animated: true)
                penYdsPicker.selectItem(penYdsPicker.selectedItem, animated: true)
            }
            else {
                if defenseSwitch.on == false {
                    defenseSwitch.setOn(true, animated: true)
                }
            }
        }
        else {
            if sender.on{
                offenseSwitch.setOn(false, animated: true)
                penYdsPicker.selectItem(penYdsPicker.selectedItem, animated: true)
            }
            else {
                if offenseSwitch.on == false {
                    offenseSwitch.setOn(true, animated: true)
                }
            }
        }
    }
    
    func save() {
        globalPlay.defensivePenalty = defenseSwitch.on
        globalPlay.ydLn = ydLnData[ydLnPicker.selectedItem]
        if globalPlay.defensivePenalty {
            globalPlay.gnLs = gnLsData[penYdsPicker.selectedItem]
        }
        else {
            globalPlay.gnLs = -gnLsData[penYdsPicker.selectedItem]
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
}