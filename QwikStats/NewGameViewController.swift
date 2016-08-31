//
//  NewGameViewController.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 8/11/16.
//  Copyright © 2016 Jonathan Kerbelis. All rights reserved.
//

import UIKit
import Toast_Swift

class NewGameViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var homeTeamTextField: UITextField!
    @IBOutlet var awayTeamTextField: UITextField!
    @IBOutlet var divisionPicker: UIPickerView!
    @IBOutlet var fieldSizePicker: UIPickerView!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var startGameBtn: UIButton!
    
    
    var divisionData = [String]()
    var fieldSizeData = [String]()
    let radius: CGFloat = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        startGameBtn.layer.cornerRadius = radius
        startGameBtn.clipsToBounds = true
        self.title = "New Game"
        
        scrollView.contentSize = CGSizeMake(414, 672)
        divisionPicker.dataSource = self
        divisionPicker.delegate = self
        fieldSizePicker.dataSource = self
        fieldSizePicker.delegate = self
        
        makeData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    func showMessage(message: String) {
        self.view.makeToast(message, duration: 3.0, position: .Bottom)
    }

    func makeData () {
        fieldSizeData.append("100 Yards")
        fieldSizeData.append("80 Yards")
        
        divisionData.append("TINY-MITE")
        divisionData.append("MITEY-MITE")
        divisionData.append("JR PEE WEE")
        divisionData.append("PEE WEE")
        divisionData.append("JR MIDGET")
        divisionData.append("MIDGET")
        divisionData.append("FRESHMAN")
        divisionData.append("JR VARSITY")
        divisionData.append("VARSITY")
    }
    
    func numberOfComponentsInPickerView (pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == divisionPicker {
            return divisionData.count
        }
        else {
            return fieldSizeData.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == divisionPicker {
            return divisionData[row]
        }
        else {
            return fieldSizeData[row]
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "StartNewGameSegue") {
            //get a reference to the destination view controller
            let destinationVC:GameViewController = segue.destinationViewController as! GameViewController
            
            //set properties on the destination view controller
            destinationVC.homeTeamName = homeTeamTextField.text!
            destinationVC.awayTeamName = awayTeamTextField.text!
            if fieldSizePicker.selectedRowInComponent(0) == 0 {
                destinationVC.fldSize = 100
            }
            else  {
                destinationVC.fldSize = 80
            }
            var div = divisionData[divisionPicker.selectedRowInComponent(0)]
            if div == "JR PEE WEE" {
                div = "JR-PEE-WEE"
            }
            else if div == "PEE WEE" {
                div = "PEE-WEE"
            }
            else if div == "JR MIDGET" {
                div = "JR-MIDGET"
            }
            else if div == "JR VARSITY" {
                div = "JR-VARSITY"
            }
            
            destinationVC.division = div
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let date: String = formatter.stringFromDate(datePicker.date)
            let dateArray = date.characters.split{$0 == "-"}.map(String.init)
            destinationVC.year = Int(dateArray[0])!
            destinationVC.month = Int(dateArray[1])!
            destinationVC.day = Int(dateArray[2])!
            destinationVC.openingPastGame = false
        }
    }
    
    @IBAction func startGame(sender: UIButton) {
        if homeTeamTextField == "" && awayTeamTextField == "" {
            showMessage("Please input team names")
        }
        else if homeTeamTextField == "" {
            showMessage("Please input home team name")
        }
        else if awayTeamTextField == "" {
            showMessage("Please input away team name")
        }
        else {
            self.performSegueWithIdentifier("StartNewGameSegue", sender: self)
        }
    }
    
}
