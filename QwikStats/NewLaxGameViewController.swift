//
//  NewGameViewController.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 8/11/16.
//  Copyright © 2016 Jonathan Kerbelis. All rights reserved.
//

import UIKit
import Toast_Swift

class NewLaxGameViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var homeTeamTextField: UITextField!
    @IBOutlet var awayTeamTextField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var startGameBtn: UIButton!
    
    let radius: CGFloat = 10
    var sport: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        startGameBtn.layer.cornerRadius = radius
        startGameBtn.clipsToBounds = true
        self.title = "New Game"
        
        let date = NSDate()
        datePicker.setDate(date as Date, animated: true)
        
        homeTeamTextField.delegate = self
        awayTeamTextField.delegate = self
        homeTeamTextField.tag = 0;
        awayTeamTextField.tag = 1;
        
        homeTeamTextField.text = DefaultPreferences.getTeamName()
        homeTeamTextField.isEnabled = false
        awayTeamTextField.becomeFirstResponder()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        return false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func showMessage(_ message: String) {
        self.view.makeToast(message, duration: 3.0, position: .bottom)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "StartNewLaxGameSegue") {
            //get a reference to the destination view controller
            let destinationVC:LaxGameViewController = segue.destination as! LaxGameViewController
            
            //set properties on the destination view controller
            destinationVC.homeTeamName = homeTeamTextField.text!
            destinationVC.awayTeamName = awayTeamTextField.text!
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let date: String = formatter.string(from: datePicker.date)
            let dateArray = date.characters.split{$0 == "-"}.map(String.init)
            destinationVC.year = Int(dateArray[0])!
            destinationVC.month = Int(dateArray[1])!
            destinationVC.day = Int(dateArray[2])!
            destinationVC.openingPastGame = false
        }
    }
    
    @IBAction func startGame(_ sender: UIButton) {
        if homeTeamTextField.text == "" && awayTeamTextField.text == "" {
            showMessage("Please input team names")
        }
        else if homeTeamTextField.text == "" {
            showMessage("Please input home team name")
        }
        else if awayTeamTextField.text == "" {
            showMessage("Please input away team name")
        }
        else {
            self.performSegue(withIdentifier: "StartNewLaxGameSegue", sender: self)
        }
    }
    
}
