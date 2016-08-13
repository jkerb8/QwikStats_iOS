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
        self.navigationController?.navigationBarHidden = true
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func newGameBtn(sender: UIButton) {
        self.performSegueWithIdentifier("NewGameSegue", sender: self)
    }
    
    @IBAction func openGameBtn(sender: UIButton) {
        self.performSegueWithIdentifier("OpenGameSegue", sender: self)
        /*let vc = self.storyboard?.instantiateViewControllerWithIdentifier("GameViewController") as! GameViewController
        let navigationController = UINavigationController(rootViewController: vc)
        self.presentViewController(navigationController, animated: true, completion: nil)
        */
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "OpenGameSegue") {
            //get a reference to the destination view controller
            let destinationVC:GameViewController = segue.destinationViewController as! GameViewController
            
            //set properties on the destination view controller
            destinationVC.homeTeamName = "Auburn"
            destinationVC.awayTeamName = "Alabama"
            //etc...
        }
    }

    @IBAction func settingsBtn(sender: UIButton) {
        
    }
    
}

