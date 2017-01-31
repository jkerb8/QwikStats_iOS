//
//  SpeechInputViewController.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 1/21/17.
//  Copyright © 2017 Jonathan Kerbelis. All rights reserved.
//

import UIKit
import MZFormSheetPresentationController
import Toast_Swift

var lmPath: String!
var dicPath: String!
var words: Array<String> = []
var currentWord: String!

class SpeechInputViewController: UIViewController {
    
    @IBOutlet var numberLabel: UITextField!
    
    @IBOutlet var statusLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        saved = false
        
        numberLabel.text = txtSpeechInput
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveBtn(_ sender: UIButton) {
        saved = true
        save()
    }
    
    @IBAction func cancelBtn(_ sender: UIButton) {
        dismiss()
    }
    
    func save() {
        if (numberLabel.text?.characters.count)! > 3 && !(numberLabel.text?.contains(" "))!{
            showMessage("Say a real jersey number")
            return
        }
        else if numberLabel.text != "" {
            currentPlayerNum = Int(numberLabel.text!)
            dismiss()
            return
        }
        showMessage("Please say a number")
    }
    
    func dismiss() {
        let formSheetController = mz_formSheetPresentingPresentationController()
        formSheetController!.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.dropDown
        
        if let temp = saved {
            if temp {
                let vc = presentingViewController as! LaxGameViewController
                
                vc.addStat(num: currentPlayerNum)            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func showMessage(_ message: String) {
        self.view.makeToast(message, duration: 3.0, position: .bottom)
    }

}
