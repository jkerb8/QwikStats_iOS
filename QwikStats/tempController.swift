//
//  tempController.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 7/27/16.
//  Copyright © 2016 Jonathan Kerbelis. All rights reserved.
//

import UIKit

class tempController: UITableViewController {
    @IBOutlet var textField: UILabel!
    
    var passingString: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let text = self.passingString {
            self.textField.text = text
        }
    }
}
