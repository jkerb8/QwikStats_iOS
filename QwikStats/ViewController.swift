//
//  ViewController.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 6/27/16.
//  Copyright © 2016 Jonathan Kerbelis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func newGameBtn(sender: UIButton) {
        
    }
    
    @IBAction func openGameBtn(sender: UIButton) {
        
        self.performSegueWithIdentifier("mainToGame", sender: self)
        
    }

    @IBAction func settingsBtn(sender: UIButton) {
        
    }
    
}

