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
        
        ogGnLs = gnLsData.index(of: 0)!
        ogYdLn = ydLnData.index(of: globalPlay.ydLn)!
        gnLsPicker.selectItem(gnLsData.index(of: globalPlay.gnLs)!)
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
        if pickerView == gnLsPicker {
            return self.gnLsData.count
        }
        else {
            return ydLnData.count
        }
    }
    
    func pickerView(_ pickerView: AKPickerView, titleForItem item: Int) -> String {
        if pickerView == gnLsPicker {
            return self.gnLsStrings[item]
        }
        else {
            return ydLnStrings[item]
        }
    }
    
    func pickerView(_ pickerView: AKPickerView, didSelectItem item: Int) {
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
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        if sender == safetySwitch {
            if sender.isOn{
                touchdownSwitch.setOn(false, animated: true)
                gnLsPicker.selectItem(0, animated: true)
            }
            else {
                gnLsPicker.selectItem(ogGnLs, animated: true)
            }
        }
        else if sender == touchdownSwitch {
            if sender.isOn{
                safetySwitch.setOn(false, animated: true)
                gnLsPicker.selectItem(gnLsData.count - 1, animated: true)
            }
            else {
                print("TOUCHDOWN, TRYING TO MOVE SWITCH")
                gnLsPicker.selectItem(ogGnLs, animated: true)
            }
        }
    }

    
    @IBAction func rightBtnClicked(_ sender: UIButton) {
        let formSheetController = mz_formSheetPresentingPresentationController()
        formSheetController!.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.slideFromLeft
        
        save()
        if globalPlay.interceptionFlag || globalPlay.fumbleFlag {
            turnoverDialog()
        }
        else {
            tackleDialog()
        }
    }
    
    @IBAction func leftBtnClicked(_ sender: UIButton) {
        let formSheetController = mz_formSheetPresentingPresentationController()
        formSheetController!.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.slideFromRight
        
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
    
    @IBAction func saveBtnClicked(_ sender: UIButton) {
        saved = true
        save()
        dismiss()
    }
    
    @IBAction func cancelBtnClicked(_ sender: UIButton) {
        let formSheetController = mz_formSheetPresentingPresentationController()
        formSheetController!.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.dropDown
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func save() {
        globalPlay.ydLn = ydLnData[ydLnPicker.selectedItem]
        globalPlay.gnLs = gnLsData[gnLsPicker.selectedItem]
        globalPlay.safetyFlag = safetySwitch.isOn
        globalPlay.touchdownFlag = touchdownSwitch.isOn
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
    
    func runDialog(_ text: String) {
        let navigationController = self.storyboard!.instantiateViewController(withIdentifier: "RunViewController")// as! UIViewController
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        //formSheetController.presentationController?.shouldApplyBackgroundBlurEffect = true
        //width is first, height is second
        formSheetController.presentationController?.contentViewSize = CGSize(width: 350, height: 300)
        formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.slideFromLeft
        
        //let presentedViewController = navigationController as! RunViewController
        //presentedViewController.play = self.play
        
        formSheetController.willPresentContentViewControllerHandler = { vc in
            let navigationController = vc
            let presentedViewController = navigationController as! RunViewController
            presentedViewController.view?.layoutIfNeeded()
            presentedViewController.titleLabel?.text = text
        }
        
        let parent: UIViewController! = self.presentingViewController
        
        self.dismiss(animated: true, completion: {
            parent.present(formSheetController, animated: true, completion: nil)
        })
    }
    
    func showMessage(_ message: String) {
        self.view.makeToast(message, duration: 3.0, position: .bottom)
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
