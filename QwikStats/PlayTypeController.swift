//
//  PlayTypeController.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 7/24/16.
//  Copyright © 2016 Jonathan Kerbelis. All rights reserved.
//

import UIKit
import MZFormSheetPresentationController

class PlayTypeController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var playTypeLabel: UILabel!
    @IBOutlet var playTypePicker: UIPickerView!
    var pickerData: [String] = ["Run", "Pass", "Penalty", "Kickoff", "Punt", "Field Goal", "PAT", "2 Pt. Conversion"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.playTypePicker.dataSource = self
        self.playTypePicker.delegate = self
        
        if globalPlay.playType != "" {
            self.playTypePicker.selectRow(pickerData.indexOf(globalPlay.playType)!, inComponent: 0, animated: true)
        }
        
        //self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: #selector(NSStream.close))

    }
    
    func numberOfComponentsInPickerView (pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        globalPlay.playType = pickerData[row]
        return pickerData[row]
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }


    @IBAction func leftBtn(sender: UIButton) {
        save()
    }

    @IBAction func rightBtn(sender: UIButton) {
        save()
        runDialog()
    }

    @IBAction func saveBtn(sender: UIButton) {
        saved = true
        save()
        dismiss()
    }

    @IBAction func cancelBtn(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
    
    func save() {
        globalPlay.playType = pickerData[playTypePicker.selectedRowInComponent(0)]
    }
    
    func runDialog() {
        let navigationController = self.storyboard!.instantiateViewControllerWithIdentifier("RunViewController")// as! UIViewController
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        //formSheetController.presentationController?.shouldApplyBackgroundBlurEffect = true
        //width is first, height is second
        formSheetController.presentationController?.contentViewSize = CGSizeMake(350, 275)
        formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.SlideAndBounceFromRight
        
        
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