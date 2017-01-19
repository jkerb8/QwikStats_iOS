//
//  GameViewController.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 7/25/16.
//  Copyright © 2016 Jonathan Kerbelis. All rights reserved.
//

import UIKit
import Toast_Swift
import MZFormSheetPresentationController
import MessageUI

var game: Game!
var globalPlay: Play!
var saved: Bool!
var flow: Bool!
var fieldSize: Int!
var ydLnData = [Int]()
var ydLnStrings = [String]()
var gamePlays = [Play]()

class GameViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet var awayTeamNameView: UILabel!
    @IBOutlet var homeTeamNameView: UILabel!
    @IBOutlet var awayScoreLabel: UILabel!
    @IBOutlet var homeScoreLabel: UILabel!
    @IBOutlet var downLabel: UILabel!
    @IBOutlet var distLabel: UILabel!
    @IBOutlet var ydLnLabel: UILabel!
    @IBOutlet var qtrLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!

    @IBOutlet var awayPossImageView: UIImageView!
    @IBOutlet var homePossImageView: UIImageView!
    
    @IBOutlet var playScrollView: UIScrollView!
    @IBOutlet var newPlayBtn: UIButton!
    @IBOutlet var undoPlayBtn: UIButton!
    
    var buttonList = [UIButton]()
    var gameDataList = [String]()
    var statsList = [String]()
    
    var gameFolder = "", gameName = "", matchupName = ""
    var csvPlayList = "play_list.csv"
    var csvGameData = "game_data.csv"
    var csvOffHomeStats = "home_offensive_stats_list.csv"
    var csvOffAwayStats = "away_offensive_stats_list.csv"
    var csvDefHomeStats = "home_defensive_stats_list.csv"
    var csvDefAwayStats = "away_defensive_stats_list.csv"
    var themeColor = "#6d9e31"
    var projDir: FILE!
    var flow=true, saved=false, canceled=false, homeTeamStart=false, updateFlag = false
    var buttonWidth: CGFloat = 394
    var buttonHeight: CGFloat = 50
    
    var homeTeamName: String = ""
    var awayTeamName: String = ""
    var division: String = ""
    var day = 1
    var month = 1
    var year = 2016
    var fldSize = 0
    var openingPastGame = false
    
    var scrollWidth: CGFloat = 414
    var scrollHeight: CGFloat = 10
    let radius: CGFloat = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newPlayBtn.layer.cornerRadius = radius
        undoPlayBtn.layer.cornerRadius = radius
        newPlayBtn.clipsToBounds = true
        undoPlayBtn.clipsToBounds = true
        
        updateFlag = false
        
        scrollWidth = playScrollView.contentSize.width
        playScrollView.contentSize = CGSize(width: scrollWidth, height: scrollHeight)
        //playScrollView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        
        self.navigationController?.isNavigationBarHidden = true
        
        for i in stride(from: 0, to: -50, by: -1){
            ydLnData.append(i)
            ydLnStrings.append(" \(String(i)) ")
        }
        
        for i in stride(from: 50, to: -1, by: -1) {
            ydLnData.append(i)
            ydLnStrings.append(" \(String(i)) ")
        }
        
        fieldSize = self.fldSize
        if fldSize == 0 {
            fieldSize = 100
        }
        game = Game(awayName: awayTeamName, homeName: homeTeamName, division: division, day: day, month: month, year: year, fieldSize: fieldSize)
        gamePlays = [Play]()
        
        globalPlay = Play(currentGame: game)
        
        awayTeamNameView.text = awayTeamName
        homeTeamNameView.text = homeTeamName
        
        gameName = "\(month)_\(day)_\(year)_\(division)_\(fieldSize)_\(homeTeamName)_vs_\(awayTeamName)"
        matchupName = "\(awayTeamName) vs. \(homeTeamName)"
        
        updateVisuals()
        
        let dir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first
        let folder = URL(fileURLWithPath: dir!).appendingPathComponent("QwikStats").absoluteString
        gameFolder = URL(fileURLWithPath: folder).appendingPathComponent(gameName).absoluteString
    

        //set scoreboard font stuff
        
        if openingPastGame {
            print("Opening Game..")
            openGame()
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !openingPastGame {
            openingKickoffDialog()
        }
    }
    
    func showMessage(_ message: String) {
        self.view.makeToast(message, duration: 3.0, position: .bottom)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func newPlayBtn(_ sender: UIButton) {
        saved = false
        globalPlay = nil
        globalPlay = Play(currentGame: game)
        if statusLabel.text == "Halftime" {
            globalPlay.playType = "Kickoff"
        }
        playTypeDialog()
        
    }
    
    @IBAction func undoBtn(_ sender: UIButton) {
        if statusLabel.text == "End of Game" {
            returnToFourthDialog()
        }
        else if statusLabel.text == "Halftime" {
            returnToSecondDialog()
        }
        else if buttonList.count > 0 {
            undoPlayDialog()
        }
        else {
            showMessage("No plays to undo...")
            openingKickoffDialog()
        }
        
    }
    
    func undoPlayDialog() {
        let alertController = UIAlertController(title: "Undo Play", message: "Are you sure you want to undo the last play?", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            if !self.updateFlag {
                self.showMessage("Play Deleted")
            }
            
            if (self.buttonList.count > 1) {
                self.updateGameData(gamePlays[gamePlays.count - 2])
                self.undoStats(gamePlays[gamePlays.count - 1])
            }
            else {
                game.completeReset()
            }
            
            self.removeButton(gamePlays[gamePlays.count - 1])
            gamePlays.remove(at: gamePlays.count - 1)
            self.gameDataList.remove(at: self.gameDataList.count - 1)
            self.updateVisuals()
            
        }
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func returnToFourthDialog() {
        let alertController = UIAlertController(title: "Undo Play", message: "Return to the 4th Quarter?", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.newPlayBtn.isEnabled = true
            self.statusLabel.text = ""
            self.updateGameData(gamePlays[gamePlays.count - 1])
            self.updateVisuals()
        }
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func returnToSecondDialog() {
        let alertController = UIAlertController(title: "Undo Play", message: "Return to the 2nd Quarter?", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.statusLabel.text = ""
            game.qtr = 2
            self.updateGameData(gamePlays[gamePlays.count - 1])
            self.updateVisuals()
        }
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func menuBtn(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Game Menu", message: "Choose an option", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        let saveGameAction = UIAlertAction(title: "Save Game", style: .default) { (action) in
            self.saveGame()
        }
        alertController.addAction(saveGameAction)
        
        let exitAction = UIAlertAction(title: "Exit Game", style: .default) { (action) in
            self.exitGameDialog()
        }
        alertController.addAction(exitAction)
        
        let nextQtrAction = UIAlertAction(title: "Next Qtr", style: .default) { (action) in
            var qtr = game.qtr
            qtr += 1
            if qtr > 4 {
                self.qtrLabel.text = ""
                self.statusLabel.text = "End of Game"
                self.newPlayBtn.isEnabled = false
            }
            else if qtr == 3 {
                if self.homeTeamStart {
                    if game.possFlag {
                        self.changePossession()
                    }
                }
                else {
                    if !game.possFlag {
                        self.changePossession()
                    }
                }
                
                self.updateVisuals()
                self.qtrLabel.text = ""
                self.statusLabel.text = "Halftime"
                game.qtr = qtr
            }
            else {
                game.qtr = qtr
                self.updateVisuals()
            }
        }
        alertController.addAction(nextQtrAction)
        
        let exportAction = UIAlertAction(title: "Export", style: .default) { (action) in
            self.export()
        }
        alertController.addAction(exportAction)
        
        let manualUpdateAction = UIAlertAction(title: "Manual Update", style: .default) { (action) in
            //manualUpdate()
        }
        alertController.addAction(manualUpdateAction)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (action) in
            //settings()
        }
        alertController.addAction(settingsAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func exitGameDialog() {
        let alertController = UIAlertController(title: "Exiting Game", message: "Would you like to save?", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        let exitAction = UIAlertAction(title: "Save and Exit", style: .default) { (action) in
            self.saveGame()
            self.performSegue(withIdentifier: "unwindToViewController", sender: self)
        }
        alertController.addAction(exitAction)
        
        let nextQtrAction = UIAlertAction(title: "Exit Without Saving", style: .default) { (action) in
            self.performSegue(withIdentifier: "unwindToViewController", sender: self)
        }
        alertController.addAction(nextQtrAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func openingKickoffDialog() {
        let alertController = UIAlertController(title: "Opening Kickoff", message: "Which team is kicking off to begin the game?", preferredStyle: UIAlertControllerStyle.alert)
        
        let homTeamAction = UIAlertAction(title: game.homeTeam.teamName, style: .default) { (action) in
            if !game.possFlag {
                self.changePossession()
            }
            self.homeTeamStart = true
            self.showMessage("\(game.homeTeam.teamName) will kick to \(game.awayTeam.teamName) to begin the game")
        }
        alertController.addAction(homTeamAction)
        
        let awayTeamAction = UIAlertAction(title: game.awayTeam.teamName, style: .default) { (action) in
            if game.possFlag {
                self.changePossession()
            }
            self.homeTeamStart = false
            self.showMessage("\(game.awayTeam.teamName) will kick to \(game.homeTeam.teamName) to begin the game")
        }
        alertController.addAction(awayTeamAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func playTypeDialog() {
        
        let navigationController = self.storyboard!.instantiateViewController(withIdentifier: "PlayTypeController")// as! UIViewController
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        //formSheetController.presentationController?.shouldApplyBackgroundBlurEffect = true
        //width is first, height is second
        formSheetController.presentationController?.contentViewSize = CGSize(width: 350, height: 300)
        formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.slideAndBounceFromBottom
        
        //let presentedViewController = navigationController as! PlayTypeController
        //presentedViewController.play = globalPlay
        
        formSheetController.willPresentContentViewControllerHandler = { vc in
            let navigationController = vc
            let presentedViewController = navigationController as! PlayTypeController
            presentedViewController.view?.layoutIfNeeded()
            //presentedViewController.playTypeLabel?.text = "Play Type"
        }
        
        self.present(formSheetController, animated: true, completion: nil)

    }
    
    func savePlay() {
        if updateFlag {
            //removeButton(gamePlays[gamePlays.count - 1])
            gamePlays.remove(at: gamePlays.count - 1)
            gameDataList.remove(at: gameDataList.count - 1)
        }
        
        if (statusLabel.text) != ""{
            if statusLabel.text == "Halftime" {
                statusLabel.text = ""
                game.qtr = 3
            }
        }
        
        globalPlay.playCount = gamePlays.count + 1
        globalPlay.offensiveTeam = getOffensiveTeam()
        globalPlay = getResult(globalPlay)
        updateFlag = false
        updateGameData(globalPlay)
        updateVisuals()
        addButton(globalPlay)
        gamePlays.append(globalPlay)
        updateStats(globalPlay)
        
        if globalPlay.possFlag {
            game.homeTeam.addRecent(globalPlay)
        }
        else {
            game.awayTeam.addRecent(globalPlay)
        }
        
        var output: String = "\(globalPlay.prevDist),\(globalPlay.prevDown),\(globalPlay.downNum),\(globalPlay.dist),\(globalPlay.fgDistance),\(globalPlay.fgMadeFlag),\(globalPlay.fieldPos),\(globalPlay.ydLn),\(globalPlay.gnLs),\(globalPlay.incompleteFlag),\(globalPlay.playCount),\(globalPlay.playerNumber),\(globalPlay.playType),\(globalPlay.qtr),\(globalPlay.recNumber),\(globalPlay.returnFlag),\(globalPlay.touchdownFlag),\(globalPlay.defNumber),\(globalPlay.fumbleFlag),\(globalPlay.interceptionFlag),\(globalPlay.touchbackFlag),\(globalPlay.faircatchFlag),\(globalPlay.returnYds),\(globalPlay.fumbleRecFlag),\(globalPlay.tackleFlag),\(globalPlay.sackFlag),\(globalPlay.possFlag),\(globalPlay.safetyFlag),\(globalPlay.defensivePenalty),\(globalPlay.returnedYdLn),\(globalPlay.prevYdLn),\(globalPlay.firstDn),\(globalPlay.playCall),\(globalPlay.formation),\(globalPlay.hash),\(globalPlay.playDir),\(globalPlay.offensiveTeam)"
        
        if globalPlay.tacklers.count > 0 {
            for i in stride(from: 0, to: globalPlay.tacklers.count, by: 1){
                output += "," + String(globalPlay.tacklers[i])
            }
        }
        
        output += "\n"
        
        gameDataList.append(output)
        
        saved = false
        //playList data here if needed
    }
    
    func openGame() {
        if makeDirectory() {
            let file = csvGameData
            //let fileManager = NSFileManager.defaultManager()
            let path = URL(fileURLWithPath: gameFolder).appendingPathComponent(file)
            var text = ""
            var lines = [String]()
            var line = ""
            var cntr = 0
            
            print(path.absoluteString)
            
            do {
                try text = NSString(contentsOf: path, encoding: String.Encoding.utf8.rawValue) as String
                print("File Length: \(text.characters.count)")
                lines = text.components(separatedBy: "\n")
                
                var max = lines.count
                for i in stride(from: 0, to: max, by: 1) {
                    if i < lines.count {
                        if lines[i] == "" {
                            lines.remove(at: i)
                            max -= 1
                        }
                    }
                }
                text = ""
            }
            catch {
                showMessage("Could not open file")
                return
            }
            
            while cntr < lines.count {
                line = lines[cntr]
                if line != "" {
                    if line == "END" {
                        updateVisuals()
                        statusLabel.text = "End of Game"
                        qtrLabel.text = ""
                        newPlayBtn.isEnabled = false
                        game.qtr = 4
                        homeTeamStart = !gamePlays[0].possFlag
                    }
                    else if line == "HALF" {
                        updateVisuals()
                        statusLabel.text = "Halftime"
                        qtrLabel.text = ""
                        game.qtr = 3
                        homeTeamStart = !gamePlays[0].possFlag
                    }
                    else if line.characters.count == 1 {
                        statusLabel.text = ""
                        game.qtr = Int(line)!
                        updateVisuals()
                        homeTeamStart = !gamePlays[0].possFlag
                    }
                    else {
                        let words = line.components(separatedBy: ",")
                        
                        var play = Play(currentGame: game)
                        
                        play.prevDist = Int(words[0])!
                        play.prevDown = Int(words[1])!
                        play.downNum = Int(words[2])!
                        play.dist = Int(words[3])!
                        play.fgDistance = Int(words[4])!
                        play.fgMadeFlag = words[5].toBool()!
                        play.fieldPos = Int(words[6])!
                        play.ydLn = Int(words[7])!
                        play.gnLs = Int(words[8])!
                        play.incompleteFlag = words[9].toBool()!
                        play.playCount = Int(words[10])!
                        play.playerNumber = Int(words[11])!
                        play.playType = words[12]
                        play.qtr = Int(words[13])!
                        play.recNumber = Int(words[14])!
                        play.returnFlag = words[15].toBool()!
                        play.touchdownFlag = words[16].toBool()!
                        play.defNumber = Int(words[17])!
                        play.fumbleFlag = words[18].toBool()!
                        play.interceptionFlag = words[19].toBool()!
                        play.touchbackFlag = words[20].toBool()!
                        play.faircatchFlag = words[21].toBool()!
                        play.returnYds = Int(words[22])!
                        play.fumbleRecFlag = words[23].toBool()!
                        play.tackleFlag = words[24].toBool()!
                        play.sackFlag = words[25].toBool()!
                        play.possFlag = words[26].toBool()!
                        play.safetyFlag = words[27].toBool()!
                        play.defensivePenalty = words[28].toBool()!
                        play.returnedYdLn = Int(words[29])!
                        play.prevYdLn = Int(words[30])!
                        play.firstDn = Int(words[31])!
                        play.playCall = words[32]
                        play.formation = words[33]
                        play.hash = words[34]
                        play.playDir = words[35]
                        play.offensiveTeam = words[36]
                        
                        for i in stride(from: 37, to: words.count, by: 1) {
                            play.tacklers.append(Int(words[i])!)
                        }
                        
                        game.qtr = play.qtr
                        
                        let poss = play.possFlag
                        if play.interceptionFlag || play.fumbleRecFlag || play.playType == "Kickoff" || play.playType == "Punt" {
                            play.possFlag = !play.possFlag
                        }
                        play = getResult(play)
                        play.possFlag = poss
                        
                        updateGameData(play)
                        gamePlays.append(play)
                        updateStats(play)
                        if play.possFlag {
                            game.homeTeam.addRecent(play)
                        }
                        else {
                            game.awayTeam.addRecent(play)
                        }
                        
                        addButton(play)
                        
                        gameDataList.append(line + "\n")
                        
                        print(play.result)
                        
                        //playList crap if needed
                    }
                    cntr += 1
                }
            }
            updateVisuals()
            homeTeamStart = !gamePlays[0].possFlag
            
        }
    }
    
    func makeDirectory() -> Bool {
        if let dir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first {
            let folder = URL(fileURLWithPath: dir).appendingPathComponent("QwikStats").path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: folder) {
                print("QwikStats folder exists...")
                return createGameFolder(folder)
            }
            else {
                do {
                    print("Creating QwikStats folder...")
                    try fileManager.createDirectory(atPath: folder, withIntermediateDirectories: false, attributes: nil)
                    return createGameFolder(folder)
                }
                catch let error as NSError{
                    print("Failed to create Qwikstats folder")
                    print(error.localizedDescription)
                }
            }
        }
        return false
    }
    
    func createGameFolder(_ dir: String) -> Bool {
        let fileManager = FileManager.default
        let folder = URL(fileURLWithPath: dir).appendingPathComponent(gameName).path
        if fileManager.fileExists(atPath: folder) {
            print("Game Directory exists")
            return true
        }
        else {
            do {
                print("creating game folder...")
                try fileManager.createDirectory(atPath: folder, withIntermediateDirectories: false, attributes: nil)
                return true
            }
            catch let error as NSError{
                print("Failed to create Game folder")
                print(error.localizedDescription)
            }
        }
        return false
    }

    func saveGame() {
        if gameDataList.count == 0 {
            showMessage("At least one play must be inputted before a save")
            return
        }
        
        if makeDirectory() {
            var failed = false
            let file = csvGameData
            let fileManager = FileManager.default
            let path = URL(fileURLWithPath: gameFolder).appendingPathComponent(file)
            //var isDir: ObjCBool = false
            
            //if fileManager.fileExistsAtPath(path){
                
                //let pathString = path.absoluteString
                /*if fileManager.fileExistsAtPath(pathString, isDirectory: &isDir) {
                    if isDir {
                        do {
                            try fileManager.removeItemAtPath(pathString)
                        }
                        catch let error as NSError {
                            showMessage("Error Saving: could not overwrite old file")
                            print(error.localizedDescription)
                        }
                    }
                }*/
            let temp = gameDataList[0]
            do {
                try temp.write(to: path, atomically: false, encoding: String.Encoding.utf8)
                self.showMessage("Game Saved")
                print("Game Saved")
            }
            catch {
                if !failed {
                    showMessage("There was a problem writing data to your device")
                    failed = true
                }
            }
            
            if let fileHandle  = try? FileHandle(forWritingTo: path) {
                defer {
                    fileHandle.closeFile()
                }
            
                for i in stride(from: 1, to: gameDataList.count, by: 1) {
                    let text = gameDataList[i]
        
                    let data = text.data(using: String.Encoding.utf8)
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data!)
                }
                
                if statusLabel.text == "End of Game" {
                    let text = "END"
                    let data = text.data(using: String.Encoding.utf8)
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data!)
                }
                else if statusLabel.text == "Halftime" {
                    let text = "HALF"
                    let data = text.data(using: String.Encoding.utf8)
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data!)
                }
                else {
                    let text = qtrLabel.text
                    let data = text!.data(using: String.Encoding.utf8)
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data!)
                }
            }
            else {
                print("fileHandle not working - game file")
            }
            //}
        }
        print(gameFolder)
        exportLocally()
    }
    
    func exportLocally() {
        if (gamePlays.count == 0) {
            showMessage("Minimum of one play must occur before exporting")
            return
        }
        
        let fileManager = FileManager.default
        let offLabelList = ["Number", "Pass Attempts", "Pass Completions", "Pass Yards", "Pass Touchdowns", "Interceptions", "Rush Attempts", "Rush Yards", "Rush Touchdowns", "Receptions", "Receiving Yards", "Receiving Touchdowns"]
        let defLabelList = ["Number", "Tackles", "TFL", "Sacks", "Forced Fumbles", "Fumble Recoveries", "Interceptions", "Defensive TDs"]
        let playLabelList = ["Play Number", "Offensive Team", "Down", "Distance", "Hash", "Yard Line", "Play Type", "Play Result", "Gain/Loss", "OFF STR", "Play Direction", "Gap", "Pass Zone", "Defensive Front", "Coverage", "Qtr", "Penalty", "Passer", "Receiver", "Rusher"]
        
        var cntr = 0
        var labels = ""
        var labelList = [String]()
        var playerList = [Player]()
        var fileName = ""
        
        
        for k in stride(from: 0, to: 5, by: 1) {
            switch k {
            case 0:
                fileName = csvOffHomeStats
                labelList = offLabelList
                playerList = game.homeTeam.players
            case 1:
                fileName = csvOffAwayStats
                labelList = offLabelList
                playerList = game.awayTeam.players
            case 2:
                fileName = csvDefHomeStats
                labelList = defLabelList
                playerList = game.homeTeam.players
            case 3:
                fileName = csvDefAwayStats
                labelList = defLabelList
                playerList = game.awayTeam.players
            case 4:
                fileName = csvPlayList
                labelList = playLabelList
            default:
                break
            }
            
            cntr = 0
            labels = ""
            
            for j in stride(from: 0, to: labelList.count, by: 1) {
                cntr += 1
                labels += labelList[j]
                if cntr < labelList.count {
                    labels += ", "
                }
                else {
                    labels += "\n"
                }
            }
            
            let path = URL(fileURLWithPath: gameFolder).appendingPathComponent(fileName)
            
            do {
                try labels.write(to: path, atomically: false, encoding: String.Encoding.utf8)
            }
            catch {
                print("There was a problem writing data to your device")
            }
            
            if k < 4 {
                var temp = " "
                for m in stride(from: 0, to: playerList.count, by: 1) {
                    let player = playerList[m]
                    
                    if k < 2 {
                        if player.offensive {
                            temp = "\(player.number), \(player.passatmpts), \(player.passcomps), \(player.passyds), \(player.passtds), \(player.ints), \(player.runatmpts), \(player.runyds), \(player.runtds), \(player.catches), \(player.recyds), \(player.rectds)\n"
                        }
                        else {
                            continue
                        }
                    }
                    else {
                        if !player.offensive {
                            temp = "\(player.number), \(player.tackles), \(player.tfls), \(player.sacks), \(player.forcedfums), \(player.fumblerecs), \(player.ints), \(player.deftds)\n"
                        }
                        else {
                            continue
                        }
                    }
                    
                    if let fileHandle  = try? FileHandle(forWritingTo: path) {
                        
                        defer {
                            fileHandle.closeFile()
                        }
                                
                        let data = temp.data(using: String.Encoding.utf8)
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(data!)
                    }
                    else {
                        print("fileHandle not working - \(fileName)")
                    }
                }
                
            }
            else {
                var temp = " "
                
                for n in stride(from: 0, to: gamePlays.count, by: 1) {
                    let play = gamePlays[n]
                    temp = "\(play.playCount), \(play.offensiveTeam), \(play.downNum), \(play.dist), \(play.hash), \(play.ydLn), \(play.playType), \(play.result), \(play.gnLs), , \(play.playDir), , , , , \(play.qtr), \(isPenalty(play)), "
                    if play.playType == "Pass" {
                        temp += "\(play.playerNumber), "
                        if play.recNumber != -1 {
                            temp += "\(play.recNumber), "
                        }
                        else {
                            temp += ", "
                        }
                    }
                    else if play.playType == "Run" || play.playType == "Kickoff" || play.playType == "Punt" {
                        if play.playerNumber != -1 {
                            temp += "\(play.playerNumber)"
                        }
                    }
                    temp += "\n"
                    
                    if let fileHandle  = try? FileHandle(forWritingTo: path) {
                        
                        defer {
                            fileHandle.closeFile()
                        }
                        
                        let data = temp.data(using: String.Encoding.utf8)
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(data!)
                    }
                    else {
                        print("fileHandle not working - \(fileName)")
                    }
                }
            }
        }        
    }
    
    func isPenalty(_ play: Play) -> String {
        if play.playType == "Penalty" {
            return "Yes"
        }
        else {
            return "No"
        }
    }
    
    func addButton(_ play: Play) {
        let prevNum = buttonList.count
        
        var margin: CGFloat = 55
        scrollHeight += margin
        playScrollView.contentSize = CGSize(width: scrollWidth, height: scrollHeight)
        for i in stride(from: (buttonList.count-1), to: -1, by: -1) {
            buttonList[i].frame = CGRect(x: 10, y: margin, width: buttonWidth, height: buttonHeight)
            margin += 55
        }
        
        let button = UIButton.init(type: UIButtonType.system) as UIButton
            button.frame = CGRect(x: 10, y: 5, width: buttonWidth, height: buttonHeight)
            button.backgroundColor = UIColor.clear
            button.setTitle("Play \(prevNum+1) - \(play.result)", for: UIControlState())
            button.setTitleColor(UIColor.white, for: UIControlState())
            button.addTarget(self, action: #selector(playBtnPressed(_:)), for: UIControlEvents.touchUpInside)
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
            button.tag = prevNum
            button.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
            self.playScrollView.addSubview(button)
        
        buttonList.append(button)
    }
    
    func removeButton(_ play: Play) {
        buttonList[buttonList.count - 1].isHidden = true
        buttonList.remove(at: buttonList.count - 1)
        
        scrollHeight -= 55
        playScrollView.contentSize = CGSize(width: scrollWidth, height: scrollHeight)
        
        var margin: CGFloat = 5
        for i in stride(from: (buttonList.count - 1), to: -1, by: -1) {
            buttonList[i].frame = CGRect(x: 10, y: margin, width: buttonWidth, height: buttonHeight)
            margin += 55
        }
        
    }
    
    func playBtnPressed(_ sender: UIButton) {
        if sender.tag == (buttonList.count-1) {
            showMessage("Editing feature coming soon...")
        }
        else {
            showMessage("Only the most recent play can be edited")
        }
    }
    
    func updateGameData(_ play: Play) {
        game.qtr = play.qtr
        game.dist = play.dist
        game.down = play.downNum
        game.firstDn = play.firstDn
        game.hash = play.hash
        
        if play.returnedYdLn == -51 {
            game.ydLn = play.ydLn
        }
        else {
            game.ydLn = play.returnedYdLn
        }
        
        game.possFlag = play.possFlag
        game.homeTeam.teamScore = play.homeScore
        game.awayTeam.teamScore = play.awayScore
    }
    
    func updateVisuals() {
        if game.down == 0 {
            downLabel.text = " "
            distLabel.text = " "
        }
        else {
            downLabel.text = String(game.down)
            distLabel.text = String(game.dist)
        }
        
        ydLnLabel.text = String(game.ydLn)
        awayScoreLabel.text = String(game.awayTeam.teamScore)
        homeScoreLabel.text = String(game.homeTeam.teamScore)
        qtrLabel.text = String(game.qtr)
        
        if game.possFlag {
            homePossImageView.isHidden = false
            awayPossImageView.isHidden = true
        }
        else {
            homePossImageView.isHidden = true
            awayPossImageView.isHidden = false
        }
    }
    
    func getOffensiveTeam() -> String{
        if game.possFlag {
            return game.homeTeam.teamName
        }
        else {
            return game.awayTeam.teamName
        }
    }
    
    func getResult(_ currentPlay: Play) -> Play {
        var playResult: String = ""
        var play: Play = currentPlay
        
        switch (play.playType) {
            case "Pass":
                if !play.incompleteFlag && !play.interceptionFlag && !play.sackFlag {
                    playResult = "Number \(play.playerNumber) pass completed to number \(play.recNumber) for \(play.gnLs) yards"
                }
                else if (play.interceptionFlag) {
                    playResult = "Number \(play.playerNumber) pass"
                    if play.recNumber != -1 {
                        playResult += " intended for number \(play.recNumber)"
                    }
                    playResult += " intercepted by number \(play.defNumber)"
                    play.possFlag = !play.possFlag
                    play.downNum = 1
                    play.dist = 10
                }
                else if (play.incompleteFlag) {
                    if (play.recNumber == -1) {
                        playResult = "Number \(play.playerNumber) pass incomplete"
                    }
                    else {
                        playResult = "Number \(play.playerNumber) pass incomplete to number \(play.recNumber)"
                    }
                }
                else {
                    playResult = "Number \(play.playerNumber)"
                }
            
            case "Run":
                playResult = "Number \(play.playerNumber) ran for \(play.gnLs) yards"
            case "Kickoff":
                if play.returnFlag && !play.touchdownFlag && !play.safetyFlag {
                    playResult = "Number \(play.playerNumber) returned the kickoff \(play.returnYds) yards to the \(play.returnedYdLn) yardline"
                    play.downNum =  1
                    play.dist = 10
                }
                else if play.returnFlag && play.touchdownFlag {
                    playResult = "Number \(play.playerNumber) returned the kickoff \(play.returnYds) yards"
                }
                else if play.safetyFlag {
                    playResult = "Number \(play.playerNumber) returned the kickoff"
                }
                else {
                    play.downNum = 1
                    play.dist = 10
                    if play.touchbackFlag {
                        playResult = "Kickoff goes for a touchback"
                        play.ydLn = -25
                    }
                    else if play.faircatchFlag {
                        playResult = "Kickoff caught for a fair catch at the \(play.returnedYdLn) yardline"
                    }
                }
                play.possFlag = !play.possFlag
            case "Punt":
                if play.returnFlag && !play.touchdownFlag && !play.safetyFlag {
                    playResult = "Number \(play.playerNumber) returned the punt \(play.returnYds) yards to the \(play.returnedYdLn) yardline"
                    play.downNum =  1
                    play.dist = 10
                }
                else if play.returnFlag && play.touchdownFlag {
                    playResult = "Number \(play.playerNumber) returned the punt \(play.returnYds) yards"
                }
                else if play.safetyFlag {
                    playResult = "Number \(play.playerNumber) returned the punt"
                }
                else {
                    play.downNum = 1
                    play.dist = 10
                    if play.touchbackFlag {
                        playResult = "Punt goes for a touchback"
                        play.ydLn = -25
                    }
                    else if play.faircatchFlag {
                        playResult = "Punt caught for a fair catch at the \(play.returnedYdLn) yardline"
                    }
                    else {
                        playResult = "Punt downed at the \(play.returnedYdLn) yardline"
                    }
                }
                play.possFlag = !play.possFlag
            case "Field Goal":
                if play.fgMadeFlag {
                    playResult = "The \(play.fgDistance)-yard field goal was good"
                    play = addScore(play, score: 3)
                    
                    if fieldSize == 80 {
                        play.downNum - 1
                        play.dist = 10
                        play.ydLn = -15
                        play.possFlag = !play.possFlag
                    }
                    else {
                        play.downNum = 0
                        play.dist = 0
                    }
                }
                else {
                    playResult = "The \(play.fgDistance)-yard field goal was no good"
                    play.possFlag = !play.possFlag
                    play.ydLn = -25
                    play.downNum = 1
                    play.dist = 10
                }
            case "PAT":
                if play.fgMadeFlag {
                    playResult = "The PAT was good"
                    play = addScore(play, score: 1)
                }
                else {
                    playResult = "The PAT was no good"
                }
            
                if fieldSize == 80 {
                    play.downNum = 1
                    play.dist = 10
                    play.ydLn = -15
                    play.possFlag = !play.possFlag
                }
                else  {
                    play.downNum = 0
                    play.dist = 0
                    play.ydLn = 0
                }
            case "2 Pt. Conversion":
                playResult = "2 Pt. Conversion is "
                if play.fgMadeFlag {
                    play = addScore(play, score: 2)
                    playResult += "good"
                }
                else {
                    playResult += "no good"
                }
            
                if fieldSize == 80 {
                    play.downNum = 1
                    play.dist = 10
                    play.ydLn = -15
                    play.possFlag = !play.possFlag
                }
                else {
                    play.downNum = 0
                    play.dist = 0
                    play.ydLn = 0
                }
            case "Penalty":
                if play.safetyFlag {
                    playResult = "Penalty in endzone"
                    break
                }
                playResult = "\(play.gnLs) yard penalty"
                if !play.defensivePenalty {
                    playResult += " on the offense"
                }
                else {
                    playResult += " on the defense"
                }
                
                var change = 0
                if (play.ydLn * play.prevYdLn) < 0 {
                    change = fieldSize - abs(play.ydLn) - play.prevYdLn
                    if play.ydLn > 0 {
                        change *= -1
                    }
                }
                else {
                    change = play.ydLn - play.prevYdLn
                }
                play.dist = play.prevDist + change
            
            // case "End" shouldn't need to exist anymore
            default:
                play.invalidPlay = true
        }
        
        if (play.playType == "Pass" || play.playType == "Run") && !play.interceptionFlag && !play.fumbleRecFlag {
            play.downNum = play.prevDown + 1
            play.dist = play.prevDist - play.gnLs
        }
        
        if play.dist <= 0 {
            play.downNum = 1
            play.dist = 10
        }
        
        if play.downNum > 4 {
            play.possFlag = !play.possFlag
            if (!updateFlag) {
                play.ydLn *= -1
            }
            play.downNum = 1
            play.dist = 10
        }
        
        if play.sackFlag {
            playResult += " sacked"
            if play.tacklers.count > 0 {
                playResult += " by number \(play.tacklers[0])"
                switch (play.tacklers.count) {
                case 1: break
                case 2:
                    playResult += " and \(play.tacklers[1])"
                default:
                    for i in stride(from: 1, to: play.tacklers.count, by: 1) {
                        if i == (play.tacklers.count - 1) {
                            playResult += " and \(play.tacklers[i])"
                        }
                        else {
                            playResult += " \(play.tacklers[i])"
                        }
                    }
                }
            }
            playResult += " for \(play.gnLs) yards"
        }
        else if play.tackleFlag {
            playResult += " tackled by number \(play.tacklers[0])"
            switch (play.tacklers.count) {
            case 1: break
            case 2:
                playResult += " and \(play.tacklers[1])"
            default:
                for i in stride(from: 1, to: play.tacklers.count, by: 1) {
                    if i == (play.tacklers.count - 1) {
                        playResult += " and \(play.tacklers[i])"
                    }
                    else {
                        playResult += " \(play.tacklers[i])"
                    }
                }
            }
        }
        
        if play.fumbleFlag && !play.fumbleRecFlag {
            playResult += " fumble recovered by the offense"
        }
        else if play.fumbleRecFlag {
            playResult += " fumble recovered by number \(play.defNumber)"
            play.possFlag = !play.possFlag
            play.downNum = 1
            play.dist = 10
        }
        
        if play.returnFlag && !(play.playType == "Kickoff" || play.playType == "Punt") {
            playResult += " returned for \(play.returnYds) yards"
            if !play.touchdownFlag {
                playResult += " to the \(play.returnedYdLn) yardline"
            }
        }
        
        if play.touchdownFlag {
            play.ydLn = 0
            play.downNum = 0
            play.dist = 3
            playResult += " for a TOUCHDOWN!"
            play = addScore(play, score: 6)
        }
        
        if play.safetyFlag {
            playResult += " result is a SAFETY!"
            play.possFlag = !play.possFlag
            play = addScore(play, score: 2)
            
            if fieldSize == 80 {
                play.downNum = 1
                play.dist = 10
                play.ydLn = -15
            }
            else {
                play.downNum = 0
                play.dist = 0
                play.ydLn = 0
            }
        }
        
        if (play.ydLn > 0) && (play.ydLn < 10) && (play.dist > play.ydLn) {
            play.dist = play.ydLn
        }
        
        if (play.gnLs > 100) || (play.returnYds > 100) || (play.playerNumber > 99) || (play.recNumber > 99) {
            play.invalidPlay = true
        }
        
        play.result = playResult
        
        return play
    }
    
    func changePossession() {
        if game.possFlag {
            awayPossImageView.isHidden = false
            homePossImageView.isHidden = true
            game.homeTeam.onOffense = false
            game.awayTeam.onOffense = true
            game.possFlag = false
        }
        else {
            awayPossImageView.isHidden = true
            homePossImageView.isHidden = false
            game.homeTeam.onOffense = true
            game.awayTeam.onOffense = false
            game.possFlag = true
        }
    }
    
    func addScore (_ play: Play, score: Int) -> Play {
        //var current: Play = play
        if play.possFlag {
            play.homeScore += score
        }
        else {
            play.awayScore += score
        }
        return play
    }
    
    func updateStats(_ play: Play) {
        var currentPlayer: Player, recPlayer: Player, defPlayer: Player, tacklerPlayer: Player
        var tempOffTeam: Team, tempDefTeam: Team
        
        if play.possFlag {
            tempOffTeam = game.homeTeam
            tempDefTeam = game.awayTeam
        }
        else {
            tempOffTeam = game.awayTeam
            tempDefTeam = game.homeTeam
        }
        
        if play.playerNumber != -1 {
            if let player = tempOffTeam.getPlayer(play.playerNumber, offensive: true) {
                currentPlayer = player
            }
            else {
                currentPlayer = Player(offensive: true, number: play.playerNumber)
                tempOffTeam.addPlayer(currentPlayer)
            }
            
            if play.recNumber != -1 {
                if let player = tempOffTeam.getPlayer(play.recNumber, offensive: true) {
                    recPlayer = player
                }
                else {
                    recPlayer = Player(offensive: true, number: play.recNumber)
                    tempOffTeam.addPlayer(recPlayer)
                }
            }
            
            if play.defNumber != -1 {
                if let player = tempDefTeam.getPlayer(play.defNumber, offensive: false) {
                    defPlayer = player
                }
                else {
                    defPlayer = Player(offensive: false, number: play.defNumber)
                    tempDefTeam.addPlayer(defPlayer)
                }
            }
        }
        
        switch play.playType {
        case "Pass":
            tempOffTeam.getPlayer(play.playerNumber, offensive: true)?.updatePassStats(play.gnLs, pic: play.interceptionFlag, incompletion: play.incompleteFlag, td: play.touchdownFlag, fum: play.fumbleFlag)
            if play.tackleFlag && play.tacklers.count > 0 {
                var group = false
                if play.tacklers.count > 1 {
                    group = true
                }
                
                for i in stride(from: 0, to: play.tacklers.count, by: 1) {
                    if let player = tempDefTeam.getPlayer(play.tacklers[i], offensive: false) {
                        tacklerPlayer = player
                    }
                    else {
                        tacklerPlayer = Player(offensive: false, number: play.tacklers[i])
                        tempDefTeam.addPlayer(tacklerPlayer)
                    }
                    tempDefTeam.getPlayer(play.tacklers[i], offensive: false)?.updateDefStats(false, tackle: play.tackleFlag, loss: play.lossFlag, fumblerec: false, forcedfum: play.fumbleFlag, sack: play.sackFlag, td: false, group: group)
                }
            }
            if !play.interceptionFlag && !play.incompleteFlag && play.recNumber != -1 {
                tempOffTeam.getPlayer(play.recNumber, offensive: true)?.updateRecStats(play.gnLs, fumb: play.fumbleFlag, td: play.touchdownFlag)
            }
            if (play.interceptionFlag || play.fumbleRecFlag) && play.defNumber != -1 {
                tempDefTeam.getPlayer(play.defNumber, offensive: false)?.updateDefStats(play.interceptionFlag, tackle: false, loss: play.lossFlag, fumblerec: play.fumbleRecFlag, forcedfum: false, sack: false, td: play.touchdownFlag, group: false)
            }

        case "Run" :
            tempOffTeam.getPlayer(play.playerNumber, offensive: true)?.updateRunStats(play.gnLs, fumb: play.fumbleFlag, td: play.touchdownFlag)
            if play.tackleFlag && play.tacklers.count > 0 {
                var group = false
                if play.tacklers.count > 1 {
                    group = true
                }
                
                for i in stride(from: 0, to: play.tacklers.count, by: 1) {
                    if let player = tempDefTeam.getPlayer(play.tacklers[i], offensive: false) {
                        tacklerPlayer = player
                    }
                    else {
                        tacklerPlayer = Player(offensive: false, number: play.tacklers[i])
                        tempDefTeam.addPlayer(tacklerPlayer)
                    }
                    tempDefTeam.getPlayer(play.tacklers[i], offensive: false)?.updateDefStats(false, tackle: play.tackleFlag, loss: play.lossFlag, fumblerec: false, forcedfum: play.fumbleFlag, sack: play.sackFlag, td: false, group: group)
                }
            }
            if play.fumbleRecFlag && play.defNumber != -1 {
                tempDefTeam.getPlayer(play.defNumber, offensive: false)?.updateDefStats(false, tackle: false, loss: play.lossFlag, fumblerec: play.fumbleRecFlag, forcedfum: false, sack: false, td: play.touchdownFlag, group: false)
            }
        
        case "Field Goal":
            break
        
        case "Kickoff":
            tempOffTeam.getPlayer(play.playerNumber, offensive: true)?.updateKickRetStats(play.returnYds, fumb: play.fumbleFlag, td: play.touchdownFlag)
            if play.tackleFlag && play.tacklers.count > 0 {
                var group = false
                if play.tacklers.count > 1 {
                    group = true
                }
                
                for i in stride(from: 0, to: play.tacklers.count, by: 1) {
                    if let player = tempDefTeam.getPlayer(play.tacklers[i], offensive: false) {
                        tacklerPlayer = player
                    }
                    else {
                        tacklerPlayer = Player(offensive: false, number: play.tacklers[i])
                        tempDefTeam.addPlayer(tacklerPlayer)
                    }
                    tempDefTeam.getPlayer(play.tacklers[i], offensive: false)?.updateDefStats(false, tackle: play.tackleFlag, loss: play.lossFlag, fumblerec: false, forcedfum: play.fumbleFlag, sack: play.sackFlag, td: false, group: group)
                }
            }
            if play.fumbleRecFlag && play.defNumber != -1 {
                tempDefTeam.getPlayer(play.defNumber, offensive: false)?.updateDefStats(false, tackle: false, loss: false, fumblerec: play.fumbleRecFlag, forcedfum: false, sack: false, td: play.touchdownFlag, group: false)
            }
            
        case "Punt":
            tempOffTeam.getPlayer(play.playerNumber, offensive: true)?.updateKickRetStats(play.returnYds, fumb: play.fumbleFlag, td: play.touchdownFlag)
            if play.tackleFlag && play.tacklers.count > 0 {
                var group = false
                if play.tacklers.count > 1 {
                    group = true
                }
                
                for i in stride(from: 0, to: play.tacklers.count, by: 1) {
                    if let player = tempDefTeam.getPlayer(play.tacklers[i], offensive: false) {
                        tacklerPlayer = player
                    }
                    else {
                        tacklerPlayer = Player(offensive: false, number: play.tacklers[i])
                        tempDefTeam.addPlayer(tacklerPlayer)
                    }
                    tempDefTeam.getPlayer(play.tacklers[i], offensive: false)?.updateDefStats(false, tackle: play.tackleFlag, loss: play.lossFlag, fumblerec: false, forcedfum: play.fumbleFlag, sack: play.sackFlag, td: false, group: group)
                }
            }
            if play.fumbleRecFlag && play.defNumber != -1 {
                tempDefTeam.getPlayer(play.defNumber, offensive: false)?.updateDefStats(false, tackle: false, loss: false, fumblerec: play.fumbleRecFlag, forcedfum: false, sack: false, td: play.touchdownFlag, group: false)
            }
            
        case "PAT": break
            
        case "2 Pt. Conversion": break
            
        case "Penalty": break
        
        default: break
            
        }
        
        if play.possFlag {
            game.homeTeam = tempOffTeam
            game.awayTeam = tempDefTeam
        }
        else {
            game.homeTeam = tempDefTeam
            game.awayTeam = tempOffTeam
        }
        
    }
    
    func undoStats(_ play: Play) {
        var tempOffTeam: Team, tempDefTeam: Team
        
        if play.possFlag {
            tempOffTeam = game.homeTeam
            tempDefTeam = game.awayTeam
        }
        else {
            tempOffTeam = game.awayTeam
            tempDefTeam = game.homeTeam
        }
        
        if play.playerNumber != -1 {
            switch play.playType {
            case "Pass":
                tempOffTeam.getPlayer(play.playerNumber, offensive: true)?.undoPassStats(play.gnLs, pic: play.interceptionFlag, incompletion: play.incompleteFlag, td: play.touchdownFlag, fum: play.fumbleFlag)
                if play.tackleFlag && play.tacklers.count > 0 {
                    var group = false
                    if play.tacklers.count > 1 {
                        group = true
                    }
                    
                    for i in stride(from: 0, to: play.tacklers.count, by: 1) {
                        tempDefTeam.getPlayer(play.tacklers[i], offensive: false)?.undoDefStats(false, tackle: play.tackleFlag, loss: play.lossFlag, fumblerec: false, forcedfum: play.fumbleFlag, sack: play.sackFlag, td: false, group: group)
                    }
                }
                if !play.interceptionFlag && !play.incompleteFlag && play.recNumber != -1 {
                    tempOffTeam.getPlayer(play.recNumber, offensive: true)?.undoRecStats(play.gnLs, fumb: play.fumbleFlag, td: play.touchdownFlag)
                }
                if (play.interceptionFlag || play.fumbleRecFlag) && play.defNumber != -1 {
                    tempDefTeam.getPlayer(play.defNumber, offensive: false)?.undoDefStats(play.interceptionFlag, tackle: false, loss: play.lossFlag, fumblerec: play.fumbleRecFlag, forcedfum: false, sack: false, td: play.touchdownFlag, group: false)
                }
                
            case "Run" :
                tempOffTeam.getPlayer(play.playerNumber, offensive: true)?.undoRunStats(play.gnLs, fumb: play.fumbleFlag, td: play.touchdownFlag)
                if play.tackleFlag && play.tacklers.count > 0 {
                    var group = false
                    if play.tacklers.count > 1 {
                        group = true
                    }
                    
                    for i in stride(from: 0, to: play.tacklers.count, by: 1) {
                        tempDefTeam.getPlayer(play.tacklers[i], offensive: false)?.undoDefStats(false, tackle: play.tackleFlag, loss: play.lossFlag, fumblerec: false, forcedfum: play.fumbleFlag, sack: play.sackFlag, td: false, group: group)
                    }
                }
                if play.fumbleRecFlag && play.defNumber != -1 {
                    tempDefTeam.getPlayer(play.defNumber, offensive: false)?.undoDefStats(false, tackle: false, loss: play.lossFlag, fumblerec: play.fumbleRecFlag, forcedfum: false, sack: false, td: play.touchdownFlag, group: false)
                }
                
            case "Field Goal":
                break
                
            case "Kickoff":
                tempOffTeam.getPlayer(play.playerNumber, offensive: true)?.undoKickRetStats(play.returnYds, fumb: play.fumbleFlag, td: play.touchdownFlag)
                if play.tackleFlag && play.tacklers.count > 0 {
                    var group = false
                    if play.tacklers.count > 1 {
                        group = true
                    }
                    
                    for i in stride(from: 0, to: play.tacklers.count, by: 1) {
                        tempDefTeam.getPlayer(play.tacklers[i], offensive: false)?.undoDefStats(false, tackle: play.tackleFlag, loss: play.lossFlag, fumblerec: false, forcedfum: play.fumbleFlag, sack: play.sackFlag, td: false, group: group)
                    }
                }
                if play.fumbleRecFlag && play.defNumber != -1 {
                    tempDefTeam.getPlayer(play.defNumber, offensive: false)?.undoDefStats(false, tackle: false, loss: false, fumblerec: play.fumbleRecFlag, forcedfum: false, sack: false, td: play.touchdownFlag, group: false)
                }
                
            case "Punt":
                tempOffTeam.getPlayer(play.playerNumber, offensive: true)?.undoKickRetStats(play.returnYds, fumb: play.fumbleFlag, td: play.touchdownFlag)
                if play.tackleFlag && play.tacklers.count > 0 {
                    var group = false
                    if play.tacklers.count > 1 {
                        group = true
                    }
                    
                    for i in stride(from: 0, to: play.tacklers.count, by: 1) {
                        tempDefTeam.getPlayer(play.tacklers[i], offensive: false)?.undoDefStats(false, tackle: play.tackleFlag, loss: play.lossFlag, fumblerec: false, forcedfum: play.fumbleFlag, sack: play.sackFlag, td: false, group: group)
                    }
                }
                if play.fumbleRecFlag && play.defNumber != -1 {
                    tempDefTeam.getPlayer(play.defNumber, offensive: false)?.undoDefStats(false, tackle: false, loss: false, fumblerec: play.fumbleRecFlag, forcedfum: false, sack: false, td: play.touchdownFlag, group: false)
                }
                
            case "PAT": break
                
            case "2 Pt. Conversion": break
                
            case "Penalty": break
                
            default: break
                
            }
            
            if play.possFlag {
                game.homeTeam = tempOffTeam
                game.awayTeam = tempDefTeam
            }
            else {
                game.homeTeam = tempDefTeam
                game.awayTeam = tempOffTeam
            }
        }
        
    }
    
    func export() {
        saveGame()
        
        let email = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(email, animated: true, completion: nil)
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let emailController = MFMailComposeViewController()
        emailController.mailComposeDelegate = self
        emailController.setSubject(gameName)
        emailController.setMessageBody("", isHTML: false)
        
        var fileName = ""
        for k in stride(from: 0, to: 5, by: 1) {
            switch k {
            case 0:
                fileName = csvOffHomeStats
            case 1:
                fileName = csvOffAwayStats
            case 2:
                fileName = csvDefHomeStats
            case 3:
                fileName = csvDefAwayStats
            case 4:
                fileName = csvPlayList
            default:
                break
            }
            
            let path = URL(fileURLWithPath: gameFolder).appendingPathComponent(fileName)
            
            print("Exporting \(fileName)")
            
            emailController.addAttachmentData(try! Data(contentsOf: path), mimeType: "text/csv", fileName: fileName)
        }
        
        return emailController
    }
    
}

extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
}
