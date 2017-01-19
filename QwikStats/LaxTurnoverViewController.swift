//
//  LaxDialogViewController.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 1/17/17.
//  Copyright © 2017 Jonathan Kerbelis. All rights reserved.
//

import UIKit
import MZFormSheetPresentationController
import Toast_Swift

class LaxTurnoverViewController: UIViewController {
    
    @IBOutlet var numberTextField: UITextField!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var turnoverSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        forcedTurnover = false
        turnoverSwitch.setOn(forcedTurnover, animated: true)
        
        titleLabel.text = currentTitle
        numberTextField.text = String(txtSpeechInput)
        saved = false
        
        self.view.layer.cornerRadius = 10
        self.view.backgroundColor = UIColor.white.withAlphaComponent(0)
        
        numberTextField.borderStyle = .roundedRect
        numberTextField.becomeFirstResponder()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SaveBtn(_ sender: UIButton) {
        saved = true
        save()
    }
    
    @IBAction func CancelBtn(_ sender: UIButton) {
        dismiss()
    }
    
    func save() {
        if (numberTextField.text?.characters.count)! > 3 {
            showMessage("Enter a real jersey number")
            return
        }
        else if numberTextField.text != "" {
            currentPlayerNum = Int(numberTextField.text!)
            forcedTurnover = turnoverSwitch.isOn
            dismiss()
            return
        }
        showMessage("Please input a number")
        
    }
    
    func dismiss() {
        let formSheetController = mz_formSheetPresentingPresentationController()
        formSheetController!.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.dropDown
        
        if let temp = saved {
            if temp {
                let vc = presentingViewController as! LaxGameViewController
                vc.addStat(num: currentPlayerNum)
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func showMessage(_ message: String) {
        self.view.makeToast(message, duration: 3.0, position: .bottom)
    }
    
}
