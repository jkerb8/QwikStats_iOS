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
    
    var games = [Game]()
    var gameInfo = [String]()
    var checked = [Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
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
        }
    }
    
    @IBAction func deleteGameBtn(sender: UIButton) {
    }
    
    @IBAction func openGameBtn(sender: UIButton) {
        var canStart: Bool = false
        for i in 0.stride(to: checked.count, by: 1) {
            if checked[i] {
                canStart = true
            }
        }
        
        if canStart {
            self.performSegueWithIdentifier("StartNewGameSegue", sender: self)
        }
        else {
            showMessage("Please select a game")
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return gameInfo.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        
        //configure cell
        cell.textLabel?.text = gameInfo[indexPath.row]
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
        for i in 0.stride(to: tableView.numberOfSections, by: 1) {
            if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: i)) {
                cell.accessoryType = .None
                checked[i] = false
            }
        }
    }
    
    func loadGames() {
        var words = [String]()
        var current: Game
        
        let fileManager = NSFileManager.defaultManager()
        if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let folder = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent("QwikStats").path!
            if fileManager.fileExistsAtPath(folder) {
                do {
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
                        current = Game(awayName: words[7], homeName: words[5], division: words[3], day: Int(words[1])!, month: Int(words[0])!, year: Int(words[2])!, fieldSize: Int(words[4])!)
                        games.append(current)
                        gameInfo.append("\(current.homeTeam.teamName) vs. \(current.awayTeam.teamName) \n\t\t \(current.division) \n\t\t \(intToMonth(current.month)) \(current.day) \(current.year)")
                        checked.append(false)
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
