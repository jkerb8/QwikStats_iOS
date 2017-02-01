//
//  LoginViewController.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 1/31/17.
//  Copyright © 2017 Jonathan Kerbelis. All rights reserved.
//

import UIKit
import Toast_Swift
import Alamofire

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var signInBtn: UIButton!
    
    let radius: CGFloat = 10
    var email: String = ""
    var password: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInBtn.layer.cornerRadius = radius
        signInBtn.clipsToBounds = true
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.tag = 0;
        passwordTextField.tag = 1;
        emailTextField.becomeFirstResponder()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
            signInBtn.sendActions(for: UIControlEvents.touchUpInside)
        }
        return false
    }
    
    @IBAction func signInBtn(_ sender: UIButton) {
        email = emailTextField.text!
        password = passwordTextField.text!
        
        if !(email.characters.count > 5 && email.contains("@")) {
            //invalid email
            showMessage("Invalid Email")
            shakeView(shakeView: emailTextField)
            return
        }
        else if password.characters.count < 5 {
            showMessage("Invalid Password")
            shakeView(shakeView: passwordTextField)
            return
        }
        
        let url = "http://qwikcut-stats.cloudapp.net/api/v1.0/login"
        
        let p = ["username": email, "password": password]
        
        Alamofire.request(url, method: .post, parameters: p, encoding: URLEncoding.default, headers: nil).responseString {
            response in
            NSLog("RESPONSE: \(response.description)")
            if (response.description.contains(self.email)) {
                DefaultPreferences.setUserName(username: self.email)
                DefaultPreferences.setPassword(password: self.password)
                self.getUserIdAndTeamName(response: response.description)
                self.performSegue(withIdentifier: "LoginUnwindSegue", sender: self)
            }
            else {
                //authentication failed
                self.showMessage("Incorrect Email or Password")
                self.shakeView(shakeView: self.emailTextField)
                self.shakeView(shakeView: self.passwordTextField)
                return
            }
        }
        
    }
    
    func getUserIdAndTeamName(response: String) {
        var idString = ""
        var teamName = ""
        var nameStrings = [String]()
        var words = response.components(separatedBy: " ")
        
        for var i in (0..<words.count) {
            if words[i].contains("font-weight:bold;font-size:36px") {
                nameStrings.append(words[i].components(separatedBy: ">")[1])
                i += 1
                var temp = words[i]
                while !temp.contains("</h1>") {
                    nameStrings.append(temp)
                    i += 1
                    temp = words[i]
                }
                nameStrings.append(words[i].components(separatedBy: "<")[0])
            }
            else if words[i] == "ID:" {
                i += 1
                idString = words[i].components(separatedBy: "<")[0]
                break
            }
        }
        DefaultPreferences.setId(id: idString)
        
        for i in (0..<nameStrings.count) {
            teamName += nameStrings[i]
            if i != (nameStrings.count - 1) {
                teamName += " "
            }
        }
        
        DefaultPreferences.setTeamName(teamname: teamName)
    }
    
    func shakeView(shakeView: UIView) {
        let shake = CABasicAnimation(keyPath: "position")
        let xDelta = CGFloat(5)
        shake.duration = 0.15
        shake.repeatCount = 2
        shake.autoreverses = true
        
        let from_point = CGPoint(x: shakeView.center.x - xDelta, y: shakeView.center.y)
        let from_value = NSValue(cgPoint: from_point)
        
        let to_point = CGPoint(x: shakeView.center.x + xDelta, y: shakeView.center.y)
        let to_value = NSValue(cgPoint: to_point)
        
        shake.fromValue = from_value
        shake.toValue = to_value
        shake.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        shakeView.layer.add(shake, forKey: "position")
    }
    
    func showMessage(_ message: String) {
        self.view.makeToast(message, duration: 3.0, position: .bottom)
    }

}
