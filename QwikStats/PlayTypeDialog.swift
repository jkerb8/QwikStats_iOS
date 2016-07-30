//
//  playTypeDialog.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 7/15/16.
//  Copyright © 2016 Jonathan Kerbelis. All rights reserved.
//

import MZFormSheetPresentationController
import UIKit

class PlayTypeDialog: UITableViewController {
    
    @IBOutlet var playTypeLabel: UILabel!
    @IBOutlet var playTypePicker: UIPickerView!
    var playTypes: [String] = ["Run", "Pass", "Penalty", "Kickoff", "Punt", "Field Goal", "PAT", "2 Pt. Conversion"]
    var passingString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: #selector(NSStream.close))
        
        //just testing passing info to this controller
        if let text = self.passingString {
            playTypeLabel.text = text
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    @IBAction func leftBtn(sender: UIButton) {
    }
    
    @IBAction func rightBtn(sender: UIButton) {
    }
    
    func pickerView (pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return playTypes[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent componenet: Int) {
        
    }
    
    @IBAction func saveBtn(sender: UIButton) {
    }
    
    @IBAction func cancelBtn(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}