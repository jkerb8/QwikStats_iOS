//
//  ViewController.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 6/27/16.
//  Copyright © 2016 Jonathan Kerbelis. All rights reserved.
//

import UIKit
import Toast_Swift
import QuartzCore

class ViewController: UIViewController {
    @IBOutlet var settingsBtn: UIButton!
    @IBOutlet var newGameBtn: UIButton!
    @IBOutlet var openGameBtn: UIButton!
    @IBOutlet var logoutBtn: UIButton!
    
    let radius: CGFloat = 10
    var sport: String = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        if !DefaultPreferences.getNotFirstTime() {
            DefaultPreferences.setUserName(username: "")
            DefaultPreferences.setPassword(password: "")
            DefaultPreferences.setId(id: "")
            DefaultPreferences.setTeamName(teamname: "")
            //let uuid = "82c5ea27-d30e-4b13-8ed7-9151b7c61bff"
            //generate UUID
            let uuid = UUID().uuidString
            DefaultPreferences.setUUID(uuid: uuid)
            DefaultPreferences.setNotFirstTime(firsttime: true)
            
        }
        
        if DefaultPreferences.getUserName() == "" {
            //go to login screen
            self.performSegue(withIdentifier: "LoginSegue", sender: self)
        }
        
        settingsBtn.layer.cornerRadius = radius
        newGameBtn.layer.cornerRadius = radius
        openGameBtn.layer.cornerRadius = radius
        logoutBtn.layer.cornerRadius = radius
        settingsBtn.clipsToBounds = true
        newGameBtn.clipsToBounds = true
        openGameBtn.clipsToBounds = true
        logoutBtn.clipsToBounds = true
        
        makeDirectory()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showMessage(_ message: String) {
        self.view.makeToast(message, duration: 3.0, position: .bottom)
    }
    
    @IBAction func newGameBtn(_ sender: UIButton) {
        //newGameDialog()
        self.sport = "Lacrosse"
        self.performSegue(withIdentifier: "NewLaxGameSegue", sender: self)
    }
    
    @IBAction func logoutBtn(_ sender: UIButton) {
        logoutDialog()
    }
    
    func logoutDialog(){
        let alertController = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        let confirmAction = UIAlertAction(title: "Log Out", style: .default) { (action) in
            DefaultPreferences.setUserName(username: "")
            DefaultPreferences.setPassword(password: "")
            DefaultPreferences.setId(id: "")
            DefaultPreferences.setTeamName(teamname: "")
            
            self.performSegue(withIdentifier: "LoginSegue", sender: self)
        }
        alertController.addAction(confirmAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func newGameDialog() {
        let alertController = UIAlertController(title: "Select Sport", message: "Select the sport being played", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        /*let footballAction = UIAlertAction(title: "Football", style: .default) { (action) in
            self.sport = "Football"
            self.performSegue(withIdentifier: "NewFootballGameSegue", sender: self)
        }
        alertController.addAction(footballAction)*/
        
        let laxAction = UIAlertAction(title: "Lacrosse", style: .default) { (action) in
            self.sport = "Lacrosse"
            self.performSegue(withIdentifier: "NewLaxGameSegue", sender: self)
        }
        alertController.addAction(laxAction)
        
        let soccerAction = UIAlertAction(title: "Soccer", style: .default) { (action) in
            self.sport = "Soccer"
            self.performSegue(withIdentifier: "NewLaxGameSegue", sender: self)
        }
        alertController.addAction(soccerAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func openGameBtn(_ sender: UIButton) {
        
        
        let fileManager = FileManager.default
        if let dir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first {
            let qwikFolder = URL(fileURLWithPath: dir).appendingPathComponent("QwikStats").path
            let folder = URL(fileURLWithPath: qwikFolder).appendingPathComponent("Lacrosse").path
            if fileManager.fileExists(atPath: folder) {
                do {
                    let dirContents = try fileManager.contentsOfDirectory(atPath: folder)
                    
                    if dirContents.count == 0 {
                        showMessage("No saved games on this device")
                        return
                    }
                    sport = "Lacrosse"
                    self.performSegue(withIdentifier: "OpenGameSegue", sender: self)
                    
                }
                catch let error as NSError {
                    NSLog(error.localizedDescription)
                }
            }
            else {
                showMessage("No saved games on this device")
                return
            }
        }

    }
    
    func openGameDialog() {
        let alertController = UIAlertController(title: "Select Sport", message: "Select the sport being played", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        /*let footballAction = UIAlertAction(title: "Football", style: .default) { (action) in
            self.sport = "Football"
            self.performSegue(withIdentifier: "OpenGameSegue", sender: self)
        }
        alertController.addAction(footballAction)*/
        
        let laxAction = UIAlertAction(title: "Lacrosse", style: .default) { (action) in
            self.sport = "Lacrosse"
            self.performSegue(withIdentifier: "OpenGameSegue", sender: self)
        }
        alertController.addAction(laxAction)
        
        let soccerAction = UIAlertAction(title: "Soccer", style: .default) { (action) in
            self.sport = "Soccer"
            self.performSegue(withIdentifier: "OpenGameSegue", sender: self)
        }
        alertController.addAction(soccerAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "NewLaxGameSegue" {
            let destinationVC:NewLaxGameViewController = segue.destination as! NewLaxGameViewController
            destinationVC.sport = sport
        }
        else if segue.identifier == "OpenGameSegue" {
            let destinationVC:OpenGameViewController = segue.destination as! OpenGameViewController
            destinationVC.sport = sport
        }
        
    }

    @IBAction func settingsBtn(_ sender: UIButton) {
        showMessage("Settings coming soon...")
    }
    
    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        
    }
    
    func makeDirectory() {
        if let dir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first {
            let folder = URL(fileURLWithPath: dir).appendingPathComponent("QwikStats").path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: folder) {
                NSLog("QwikStats folder exists...")
                return
            }
            else {
                do {
                    NSLog("Creating QwikStats folder...")
                    try fileManager.createDirectory(atPath: folder, withIntermediateDirectories: false, attributes: nil)
                    return
                }
                catch let error as NSError{
                    NSLog("Failed to create Qwikstats folder")
                    NSLog(error.localizedDescription)
                }
            }
        }
        return
    }
    
}

