//
//  PresentedTableViewController.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 7/24/16.
//  Copyright © 2016 Jonathan Kerbelis. All rights reserved.
//

import UIKit

class PresentedTableViewController: UITableViewController {
    
    @IBOutlet weak var textField: UITextField!
    var textFieldBecomeFirstResponder: Bool = false
    var passingString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(PresentedTableViewController.close))
        
        if let text = self.passingString {
            self.textField.text = text;
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if textFieldBecomeFirstResponder {
            self.textField.becomeFirstResponder()
        }
    }
    
    func close() -> Void {
        self.dismiss(animated: true, completion: nil)
    }
    
}
