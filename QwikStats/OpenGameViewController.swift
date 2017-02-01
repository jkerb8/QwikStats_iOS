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
    var laxGames = [LaxGame]()
    var gameInfo = [String]()
    var checked = [Bool]()
    var qwikPath : String!
    var qwikURL : URL!
    var gamePaths = [String]()
    var gameURLs = [URL]()
    let radius: CGFloat = 10
    var sport: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        openGameBtn.layer.cornerRadius = radius
        deleteGameBtn.layer.cornerRadius = radius
        openGameBtn.clipsToBounds = true
        deleteGameBtn.clipsToBounds = true
        
        self.title = "Past Games"
        
        games = [Game]()
        gameInfo = [String]()
        checked = [Bool]()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        
        resetChecks()
        loadLaxGames()
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func showMessage(_ message: String) {
        self.view.makeToast(message, duration: 3.0, position: .bottom)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "LoadGameSegue") {
            //get a reference to the destination view controller
            let destinationVC:GameViewController = segue.destination as! GameViewController
            
            if let index = checked.index(of: true) {
                let thisGame = games[index]
                
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
        else if (segue.identifier == "LoadLaxGameSegue") {
            let destinationVC : LaxGameViewController = segue.destination as! LaxGameViewController
            
            if let index = checked.index(of: true) {
                let thisGame = laxGames[index]
                
                destinationVC.homeTeamName = thisGame.homeTeam.teamName
                destinationVC.awayTeamName = thisGame.awayTeam.teamName
                destinationVC.year = thisGame.year
                destinationVC.month = thisGame.month
                destinationVC.day = thisGame.day
                destinationVC.openingPastGame = true
            }
        }
    }
    
    @IBAction func deleteGameBtn(_ sender: UIButton) {
        deleteDialog()
    }
    
    func deleteDialog() {
        let alertController = UIAlertController(title: "Delete Game", message: "Are you sure you want to selete the selected game?", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "Delete", style: .default) { (action) in
            let fileManager = FileManager.default
            
            for i in (0..<self.checked.count) {
                if self.checked[i] {
                    do {
                        NSLog("deleting... \(self.gameURLs[i])")
                        try fileManager.removeItem(at: self.gameURLs[i])
                        self.checked.remove(at: i)
                        self.gamePaths.remove(at: i)
                        self.gameInfo.remove(at: i)
                        self.tableView.reloadData()
                        if (self.sport == "Football") {
                            self.games.remove(at: i)
                        }
                        else {
                            self.laxGames.remove(at: i)
                        }
                    }
                    catch let error as NSError {
                        print(error)
                    }
                    break
                }
            }
            
        }
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func openGameBtn(_ sender: UIButton) {
        var canStart: Bool = false
        for i in (0..<checked.count) {
            if checked[i] {
                canStart = true
            }
        }
        
        if canStart {
            if sport == "Football" {
                self.performSegue(withIdentifier: "LoadGameSegue", sender: self)
            }
            else {
                self.performSegue(withIdentifier: "LoadLaxGameSegue", sender: self)
            }
        }
        else {
            showMessage("Please select a game")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell!
        
        //configure cell
        cell?.textLabel?.text = gameInfo[indexPath.row]
        cell?.textLabel?.numberOfLines = 3
        cell?.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        if !checked[indexPath.row] {
            cell?.accessoryType = .none
        }
        else if checked[indexPath.row] {
            cell?.accessoryType = .checkmark
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
                checked[indexPath.row] = false
            }
            else {
                resetChecks()
                cell.accessoryType = .checkmark
                checked[indexPath.row] = true
            }
        }
        
    }
    
    func resetChecks() {
        for i in stride(from: 0, to: tableView.numberOfRows(inSection: 0), by: 1) {
            if let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) {
                cell.accessoryType = .none
                checked[i] = false
            }
        }
    }
    
    func loadFootballGames() {
        var words = [String]()
        
        let fileManager = FileManager.default
        if let dir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first {
            let qwikFolder = URL(fileURLWithPath: dir).appendingPathComponent("QwikStats").path
            let fbFolder = URL(fileURLWithPath: qwikFolder).appendingPathComponent("Football").path
            if fileManager.fileExists(atPath: fbFolder) {
                do {
                    qwikURL = URL(fileURLWithPath: fbFolder)
                    qwikPath = fbFolder
                    var dirContents = try fileManager.contentsOfDirectory(atPath: fbFolder)
                    if dirContents.contains(".DS_Store") {
                        dirContents.remove(at: dirContents.index(of: ".DS_Store")!)
                    }
                    print(dirContents)
                    
                    if dirContents.count == 0 {
                        showMessage("No saved games on this device")
                        return
                    }
            
                    //tableView.beginUpdates()
                    
                    for i in (0..<dirContents.count) {
                        words = [String]()
                        words = dirContents[i].components(separatedBy: "_")
                        let current = Game(awayName: words[7], homeName: words[5], division: words[3], day: Int(words[1])!, month: Int(words[0])!, year: Int(words[2])!, fieldSize: Int(words[4])!)
                        games.append(current)
                        gameInfo.append("\(current.homeTeam.teamName) vs. \(current.awayTeam.teamName) \n\t\t \(current.division) \n\t\t \(intToMonth(current.month)) \(current.day) \(current.year)")
                        checked.append(false)
                        gamePaths.append(URL(fileURLWithPath: qwikPath).appendingPathComponent(dirContents[i]).absoluteString)
                        gameURLs.append(qwikURL.appendingPathComponent(dirContents[i]))
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
    
    func loadLaxGames() {
        var words = [String]()
        
        let fileManager = FileManager.default
        if let dir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first {
            let qwikFolder = URL(fileURLWithPath: dir).appendingPathComponent("QwikStats").path
            let laxFolder = URL(fileURLWithPath: qwikFolder).appendingPathComponent("Lacrosse").path
            if fileManager.fileExists(atPath: laxFolder) {
                do {
                    qwikURL = URL(fileURLWithPath: laxFolder)
                    qwikPath = laxFolder
                    var dirContents = try fileManager.contentsOfDirectory(atPath: laxFolder)
                    if dirContents.contains(".DS_Store"){
                        dirContents.remove(at: dirContents.index(of: ".DS_Store")!)
                    }
                    if dirContents.count == 0 {
                        showMessage("No saved games on this device")
                        return
                    }
                    
                    //tableView.beginUpdates()
                    
                    for i in (0..<dirContents.count) {
                        words = [String]()
                        words = dirContents[i].components(separatedBy: "_")
                        if words.count != 6 {
                            dirContents.remove(at: i)
                            continue
                        }
                        let current = LaxGame(homeName: words[3], awayName: words[5], day: Int(words[1])!, month: Int(words[0])!, year: Int(words[2])!)
                        laxGames.append(current)
                        gameInfo.append("\(current.homeTeam.teamName) vs. \(current.awayTeam.teamName) \n\t\t \(intToMonth(current.month)) \(current.day) \(current.year)")
                        checked.append(false)
                        gamePaths.append(URL(fileURLWithPath: qwikPath).appendingPathComponent(dirContents[i]).absoluteString)
                        gameURLs.append(qwikURL.appendingPathComponent(dirContents[i]))
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
    
    func intToMonth(_ m: Int) -> String {
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
