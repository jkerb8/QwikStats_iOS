//
//  OpenGameViewController.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 8/14/16.
//  Copyright © 2016 Jonathan Kerbelis. All rights reserved.
//

import UIKit
import Toast_Swift

class OpenGameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var deleteGameBtn: UIButton!
    @IBOutlet var openGameBtn: UIButton!
    
    var games = [Game]()
    var gameInfo = [String]()
    var checked = [Bool]()
    var qwikPath : String!
    var qwikURL : NSURL!
    var gamePaths = [String]()
    var gameURLs = [NSURL]()
    let radius: CGFloat = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        openGameBtn.layer.cornerRadius = radius
        deleteGameBtn.layer.cornerRadius = radius
        openGameBtn.clipsToBounds = true
        deleteGameBtn.clipsToBounds = true
        
        self.title = "Past Games"
        
        games = [Game]()
        gameInfo = [String]()
        checked = [Bool]()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        
        resetChecks()
        loadGames()
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    func showMessage(message: String) {
        self.view.makeToast(message, duration: 3.0, position: .Bottom)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "LoadGameSegue") {
            //get a reference to the destination view controller
            let destinationVC:GameViewController = segue.destinationViewController as! GameViewController
            
            let index = checked.indexOf(true)
            let thisGame = games[index!]
            
            //set properties on the destination view controller
            destinationVC.homeTeamName = thisGame.homeTeam.teamName
            destinationVC.awayTeamName = thisGame.awayTeam.teamName
            destinationVC.fldSize = thisGame.fieldSize
            destinationVC.division = thisGame.division
            destinationVC.year = thisGame.year
            destinationVC.month = thisGame.month
            destinationVC.day = thisGame.day
            destinationVC.openingPastGame = true
        }
    }
    
    @IBAction func deleteGameBtn(sender: UIButton) {
        deleteDialog()
    }
    
    func deleteDialog() {
        let alertController = UIAlertController(title: "Delete Game", message: "Are you sure you want to selete the selected game?", preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "Delete", style: .Default) { (action) in
            let fileManager = NSFileManager.defaultManager()
            
            for i in 0.stride(to: self.checked.count, by: 1) {
                if self.checked[i] {
                    do {
                        print("deleting... \(self.gameURLs[i])")
                        try fileManager.removeItemAtURL(self.gameURLs[i])
                        self.checked.removeAtIndex(i)
                        self.gamePaths.removeAtIndex(i)
                        self.games.removeAtIndex(i)
                        self.gameInfo.removeAtIndex(i)
                        self.tableView.reloadData()
                    }
                    catch let error as NSError {
                        print(error)
                    }
                    break
                }
            }
            
        }
        alertController.addAction(okAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func openGameBtn(sender: UIButton) {
        var canStart: Bool = false
        for i in 0.stride(to: checked.count, by: 1) {
            if checked[i] {
                canStart = true
            }
        }
        
        if canStart {
            self.performSegueWithIdentifier("LoadGameSegue", sender: self)
        }
        else {
            showMessage("Please select a game")
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameInfo.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        
        //configure cell
        cell.textLabel?.text = gameInfo[indexPath.row]
        cell.textLabel?.numberOfLines = 3
        cell.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        if !checked[indexPath.row] {
            cell.accessoryType = .None
        }
        else if checked[indexPath.row] {
            cell.accessoryType = .Checkmark
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell.accessoryType == .Checkmark {
                cell.accessoryType = .None
                checked[indexPath.row] = false
            }
            else {
                resetChecks()
                cell.accessoryType = .Checkmark
                checked[indexPath.row] = true
            }
        }
        
    }
    
    func resetChecks() {
        for i in 0.stride(to: tableView.numberOfRowsInSection(0), by: 1) {
            if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) {
                cell.accessoryType = .None
                checked[i] = false
            }
        }
    }
    
    func loadGames() {
        var words = [String]()
        
        let fileManager = NSFileManager.defaultManager()
        if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let folder = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent("QwikStats").path!
            if fileManager.fileExistsAtPath(folder) {
                do {
                    qwikURL = NSURL(fileURLWithPath: folder)
                    qwikPath = folder
                    var dirContents = try fileManager.contentsOfDirectoryAtPath(folder)
                    if dirContents.contains(".DS_Store") {
                        dirContents.removeAtIndex(dirContents.indexOf(".DS_Store")!)
                    }
                    print(dirContents)
                    
                    if dirContents.count == 0 {
                        showMessage("No saved games on this device")
                        return
                    }
            
                    //tableView.beginUpdates()
                    
                    for i in 0.stride(to: dirContents.count, by: 1) {
                        words = [String]()
                        words = dirContents[i].componentsSeparatedByString("_")
                        let current = Game(awayName: words[7], homeName: words[5], division: words[3], day: Int(words[1])!, month: Int(words[0])!, year: Int(words[2])!, fieldSize: Int(words[4])!)
                        games.append(current)
                        gameInfo.append("\(current.homeTeam.teamName) vs. \(current.awayTeam.teamName) \n\t\t \(current.division) \n\t\t \(intToMonth(current.month)) \(current.day) \(current.year)")
                        checked.append(false)
                        gamePaths.append(NSURL(fileURLWithPath: qwikPath).URLByAppendingPathComponent(dirContents[i]).absoluteString)
                        gameURLs.append(qwikURL.URLByAppendingPathComponent(dirContents[i]))
                        print(gameInfo[i])
                    }
                    
                    tableView.reloadData()
                    
                    
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
    
    func intToMonth(m: Int) -> String {
        switch (m) {
        case 1:
            return "January"
        case 2:
            return "February"
        case 3:
            return "March"
        case 4:
            return "April"
        case 5:
            return "May"
        case 6:
            return "June"
        case 7:
            return "July"
        case 8:
            return "August"
        case 9:
            return "September"
        case 10:
            return "October"
        case 11:
            return "November"
        case 12:
            return "December"
        default:
            return ""
        }
    }
}
