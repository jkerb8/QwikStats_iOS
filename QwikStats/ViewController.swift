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
    
    let radius: CGFloat = 10
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        
        settingsBtn.layer.cornerRadius = radius
        newGameBtn.layer.cornerRadius = radius
        openGameBtn.layer.cornerRadius = radius
        settingsBtn.clipsToBounds = true
        newGameBtn.clipsToBounds = true
        openGameBtn.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showMessage(message: String) {
        self.view.makeToast(message, duration: 3.0, position: .Bottom)
    }
    
    @IBAction func newGameBtn(sender: UIButton) {
        self.performSegueWithIdentifier("NewGameSegue", sender: self)
    }
    
    @IBAction func openGameBtn(sender: UIButton) {
        
        
        let fileManager = NSFileManager.defaultManager()
        if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let folder = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent("QwikStats").path!
            if fileManager.fileExistsAtPath(folder) {
                do {
                    let dirContents = try fileManager.contentsOfDirectoryAtPath(folder)
                    print(dirContents)
                    
                    if dirContents.count == 0 {
                        showMessage("No saved games on this device")
                        return
                    }
                    
                    self.performSegueWithIdentifier("OpenGameSegue", sender: self)
                    
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
            else {
                showMessage("No saved games on this device")
                return
            }
        }

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {

    }

    @IBAction func settingsBtn(sender: UIButton) {
        showMessage("Settings coming soon...")
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    
}

