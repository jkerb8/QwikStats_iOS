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

var game: Game!
var globalPlay: Play!
var saved: Bool!
var flow: Bool!
var fieldSize: Int!
var ydLnData = [Int]()
var ydLnStrings = [String]()
var gamePlays = [Play]()

class GameViewController: UIViewController {

    @IBOutlet var awayTeamNameView: UILabel!
    @IBOutlet var homeTeamNameView: UILabel!
    @IBOutlet var awayScoreLabel: UILabel!
    @IBOutlet var homeScoreLabel: UILabel!
    @IBOutlet var downNoEditLabel: UILabel!
    @IBOutlet var distNoEditLabel: UILabel!
    @IBOutlet var ydLnNoEditLabel: UILabel!
    @IBOutlet var qtrNoEditLabel: UILabel!
    @IBOutlet var downLabel: UILabel!
    @IBOutlet var distLabel: UILabel!
    @IBOutlet var ydLnLabel: UILabel!
    @IBOutlet var qtrLabel: UILabel!
    var qtrText: String = ""

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateFlag = false
        
        playScrollView.contentSize = CGSizeMake(414, 524)
        self.navigationController?.navigationBarHidden = true
        
        for i in 0.stride(to: -50, by: -1){
            ydLnData.append(i)
            ydLnStrings.append(" \(String(i)) ")
        }
        
        for i in 50.stride(to: -1, by: -1) {
            ydLnData.append(i)
            ydLnStrings.append(" \(String(i)) ")
        }
        
        //placeholder until that is sorted out
        //awayTeamName = "AwayTeam"
        //homeTeamName = "HomeTeam"
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
        
        let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first
        let folder = NSURL(fileURLWithPath: dir!).URLByAppendingPathComponent("QwikStats").absoluteString
        gameFolder = NSURL(fileURLWithPath: folder).URLByAppendingPathComponent(gameName).absoluteString
    

        //set scoreboard font stuff
        
        //if opening game, go to openGame()
        
        //else go to ...
        openingKickoffDialog()
        
        // Do any additional setup after loading the view.
    }
    
    func showMessage(message: String) {
        self.view.makeToast(message, duration: 3.0, position: .Bottom)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func newPlayBtn(sender: UIButton) {
        saved = false
        globalPlay = Play(currentGame: game)
        playTypeDialog()
        
    }
    
    @IBAction func undoBtn(sender: UIButton) {
        if qtrText == "End of Game" {
            returnToFourthDialog()
        }
        else if qtrText == "Halftime" {
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
        let alertController = UIAlertController(title: "Undo Play", message: "Are you sure you want to undo the last play?", preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "Yes", style: .Default) { (action) in
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
            gamePlays.removeAtIndex(gamePlays.count - 1)
            self.gameDataList.removeAtIndex(self.gameDataList.count - 1)
            self.updateVisuals()
            
        }
        alertController.addAction(okAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func returnToFourthDialog() {
        let alertController = UIAlertController(title: "Undo Play", message: "Return to the 4th Quarter?", preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "Yes", style: .Default) { (action) in
            self.newPlayBtn.enabled = true
            self.qtrText = ""
            self.updateGameData(gamePlays[gamePlays.count - 1])
            self.updateVisuals()
        }
        alertController.addAction(okAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func returnToSecondDialog() {
        let alertController = UIAlertController(title: "Undo Play", message: "Return to the 2nd Quarter?", preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "Yes", style: .Default) { (action) in
            self.qtrText = ""
            game.qtr = 2
            self.updateGameData(gamePlays[gamePlays.count - 1])
            self.updateVisuals()
        }
        alertController.addAction(okAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func menuBtn(sender: UIButton) {
        let alertController = UIAlertController(title: "Game Menu", message: "Choose an option", preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        let saveGameAction = UIAlertAction(title: "Save Game", style: .Default) { (action) in
            self.saveGame()
        }
        alertController.addAction(saveGameAction)
        
        let exitAction = UIAlertAction(title: "Exit Game", style: .Default) { (action) in
            self.exitGameDialog()
        }
        alertController.addAction(exitAction)
        
        let nextQtrAction = UIAlertAction(title: "Next Qtr", style: .Default) { (action) in
            var qtr = game.qtr
            qtr += 1
            if qtr > 4 {
                self.qtrLabel.text = ""
                self.qtrText = "End of Game"
                self.newPlayBtn.enabled = false
            }
            else if qtr == 3 {
                //startSecondHalf()
                self.updateVisuals()
                self.qtrLabel.text = ""
                self.qtrText = "Halftime"
                game.qtr = qtr
            }
            else {
                game.qtr = qtr
                self.updateVisuals()
            }
        }
        alertController.addAction(nextQtrAction)
        
        let exportAction = UIAlertAction(title: "Export", style: .Default) { (action) in
            //export()
        }
        alertController.addAction(exportAction)
        
        let manualUpdateAction = UIAlertAction(title: "Manual Update", style: .Default) { (action) in
            //manualUpdate()
        }
        alertController.addAction(manualUpdateAction)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .Default) { (action) in
            //settings()
        }
        alertController.addAction(settingsAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func exitGameDialog() {
        let alertController = UIAlertController(title: "Exiting Game", message: "Would you like to save?", preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        let exitAction = UIAlertAction(title: "Save and Exit", style: .Default) { (action) in
            self.saveGame()
            self.performSegueWithIdentifier("unwindToViewController", sender: self)
        }
        alertController.addAction(exitAction)
        
        let nextQtrAction = UIAlertAction(title: "Exit Without Saving", style: .Default) { (action) in
            self.performSegueWithIdentifier("unwindToViewController", sender: self)
        }
        alertController.addAction(nextQtrAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func openingKickoffDialog() {
        let alertController = UIAlertController(title: "Opening Kickoff", message: "Which team is kicking off to begin the game?", preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: game.homeTeam.teamName, style: .Default) { (action) in
            if !game.possFlag {
                self.changePossession()
            }
            self.homeTeamStart = true
            self.showMessage("\(game.homeTeam.teamName) will kick to \(game.awayTeam.teamName) to begin the game")
        }
        alertController.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: game.awayTeam.teamName, style: .Default) { (action) in
            if game.possFlag {
                self.changePossession()
            }
            self.homeTeamStart = false
            self.showMessage("\(game.awayTeam.teamName) will kick to \(game.homeTeam.teamName) to begin the game")
        }
        alertController.addAction(okAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func playTypeDialog() {
        
        let navigationController = self.storyboard!.instantiateViewControllerWithIdentifier("PlayTypeController")// as! UIViewController
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        //formSheetController.presentationController?.shouldApplyBackgroundBlurEffect = true
        //width is first, height is second
        formSheetController.presentationController?.contentViewSize = CGSizeMake(350, 275)
        formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.SlideAndBounceFromTop
        
        //let presentedViewController = navigationController as! PlayTypeController
        //presentedViewController.play = globalPlay
        
        formSheetController.willPresentContentViewControllerHandler = { vc in
            let navigationController = vc
            let presentedViewController = navigationController as! PlayTypeController
            presentedViewController.view?.layoutIfNeeded()
            //presentedViewController.playTypeLabel?.text = "Play Type"
        }
        
        self.presentViewController(formSheetController, animated: true, completion: nil)

    }
    
    func savePlay() {
        if updateFlag {
            //removeButton(gamePlays[gamePlays.count - 1])
            gamePlays.removeAtIndex(gamePlays.count - 1)
            gameDataList.removeAtIndex(gameDataList.count - 1)
        }
        
        if (qtrLabel.text) != nil{
            if qtrLabel.text == "Halftime" {
                qtrLabel.text = ""
                game.qtr = 3
            }
        }
        
        globalPlay.playCount = buttonList.count + 1
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
            for i in 0.stride(to: globalPlay.tacklers.count, by: 1){
                output += "," + String(i)
            }
        }
        
        output += "\n"
        
        gameDataList.append(output)
        
        saved = false
        //playList data here if needed
    }
    
    func makeDirectory() -> Bool {
        if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let folder = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent("QwikStats").path!
            let fileManager = NSFileManager.defaultManager()
            if fileManager.fileExistsAtPath(folder) {
                print("QwikStats folder exists...")
                return createGameFolder(folder)
            }
            else {
                do {
                    print("Creating QwikStats folder...")
                    try fileManager.createDirectoryAtPath(folder, withIntermediateDirectories: false, attributes: nil)
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
    
    func createGameFolder(dir: String) -> Bool {
        let fileManager = NSFileManager.defaultManager()
        let folder = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(gameName).path!
        if fileManager.fileExistsAtPath(folder) {
            print("Game Directory exists")
            return true
        }
        else {
            do {
                print("creating game folder...")
                try fileManager.createDirectoryAtPath(folder, withIntermediateDirectories: false, attributes: nil)
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
            let file = csvGameData
            let fileManager = NSFileManager.defaultManager()
            let path = NSURL(fileURLWithPath: gameFolder).URLByAppendingPathComponent(file)
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
            let temp = gameDataList[0] + "\n"
            do {
                try temp.writeToURL(path, atomically: true, encoding: NSUTF8StringEncoding)
                self.showMessage("Game Saved")
                print("Game Saved")
            }
            catch {
                showMessage("There was a problem writing data to your device")
            }
            
            if let fileHandle  = try? NSFileHandle(forWritingToURL: path) {
                defer {
                    fileHandle.closeFile()
                }
            
                for i in 1.stride(to: gameDataList.count, by: 1) {
                    let text = gameDataList[i] + "\n"
        
                    let data = text.dataUsingEncoding(NSUTF8StringEncoding)
                    fileHandle.seekToEndOfFile()
                    fileHandle.writeData(data!)
                }
            }
            else {
                print("fileHandle not working")
            }
            //}
        }
        print(gameFolder)
        //export()
    }
    
    func addButton(play: Play) {
        let prevNum = buttonList.count
        
        var margin: CGFloat = 55
        for i in (buttonList.count-1).stride(to: -1, by: -1) {
            buttonList[i].frame = CGRectMake(10, margin, buttonWidth, buttonHeight)
            margin += 55
        }
        
        let button = UIButton.init(type: UIButtonType.System) as UIButton
            button.frame = CGRectMake(10, 5, buttonWidth, buttonHeight)
            button.backgroundColor = UIColor.clearColor()
            button.setTitle("Play \(prevNum+1) - \(globalPlay.result)", forState: UIControlState.Normal)
            button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            button.addTarget(self, action: #selector(playBtnPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            button.tag = prevNum
            button.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
            self.playScrollView.addSubview(button)
        
        buttonList.append(button)
    }
    
    func removeButton(play: Play) {
        buttonList[buttonList.count - 1].hidden = true
        buttonList.removeAtIndex(buttonList.count - 1)
        
        var margin: CGFloat = 5
        for i in (buttonList.count - 1).stride(to: -1, by: -1) {
            buttonList[i].frame = CGRectMake(10, margin, buttonWidth, buttonHeight)
            margin += 55
        }
        
    }
    
    func playBtnPressed(sender: UIButton) {
        if sender.tag == (buttonList.count-1) {
            showMessage("Most Recent button was pressed")
        }
        else {
            showMessage("Play number \(sender.tag + 1) was pressed")
        }
    }
    
    func updateGameData(play: Play) {
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
            homePossImageView.hidden = false
            awayPossImageView.hidden = true
        }
        else {
            homePossImageView.hidden = true
            awayPossImageView.hidden = false
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
    
    func getResult(currentPlay: Play) -> Play {
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
                    for i in 1.stride(to: play.tacklers.count, by: 1) {
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
                for i in 1.stride(to: play.tacklers.count, by: 1) {
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
            awayPossImageView.hidden = false
            homePossImageView.hidden = true
            game.homeTeam.onOffense = false
            game.awayTeam.onOffense = true
            game.possFlag = false
        }
        else {
            awayPossImageView.hidden = true
            homePossImageView.hidden = false
            game.homeTeam.onOffense = true
            game.awayTeam.onOffense = false
            game.possFlag = true
        }
    }
    
    func addScore (play: Play, score: Int) -> Play {
        //var current: Play = play
        if play.possFlag {
            play.homeScore += score
        }
        else {
            play.awayScore += score
        }
        return play
    }
    
    func updateStats(play: Play) {
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
                
                for i in 0.stride(to: play.tacklers.count, by: 1) {
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
                
                for i in 0.stride(to: play.tacklers.count, by: 1) {
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
                
                for i in 0.stride(to: play.tacklers.count, by: 1) {
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
                
                for i in 0.stride(to: play.tacklers.count, by: 1) {
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
    
    func undoStats(play: Play) {
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
                    
                    for i in 0.stride(to: play.tacklers.count, by: 1) {
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
                    
                    for i in 0.stride(to: play.tacklers.count, by: 1) {
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
                    
                    for i in 0.stride(to: play.tacklers.count, by: 1) {
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
                    
                    for i in 0.stride(to: play.tacklers.count, by: 1) {
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
    
}
