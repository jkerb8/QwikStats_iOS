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

    @IBOutlet var awayPossImageView: UIImageView!
    @IBOutlet var homePossImageView: UIImageView!
    
    @IBOutlet var playScrollView: UIScrollView!
    
    var buttonList = [UIButton]()
    var gameDataList = [String]()
    var statsList = [String]()
    
    var dirPath = "", gameName = "", matchupName = ""
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
        game = Game(awayName: awayTeamName, homeName: homeTeamName, division: division, day: day, month: month, year: year, fieldSize: fieldSize)
        gamePlays = [Play]()
        
        globalPlay = Play(currentGame: game)
        
        awayTeamNameView.text = awayTeamName
        homeTeamNameView.text = homeTeamName
        
        updateVisuals()

        //set scoreboard font stuff
        
        //if opening game, go to openGame()
        
        //else go to openingKickoffDialog()
        
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
        //updateStats(globalPlay)
        
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
            let folder = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent("QwikStats").absoluteString
            let fileManager = NSFileManager.defaultManager()
            var isDir: ObjCBool = false
            if fileManager.fileExistsAtPath(folder, isDirectory: &isDir) {
                if isDir {
                    return true
                }
                else {
                    do {
                        try fileManager.createDirectoryAtPath(folder, withIntermediateDirectories: false, attributes: nil)
                        return true
                    }
                    catch let error as NSError{
                        print(error.localizedDescription)
                    }
                }
            }
        }
        return false
    }
    
    func saveGame() {
        if makeDirectory() {
            let file = csvGameData
            
            if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
                let folder = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent("QwikStats").absoluteString
                let path = NSURL(fileURLWithPath: folder).URLByAppendingPathComponent(file)
                for i in 0.stride(to: gameDataList.count, by: 1) {
                    let text = gameDataList[i] + "\n"
                    do {
                        try text.writeToURL(path, atomically: false, encoding: NSUTF8StringEncoding)
                    }
                    catch {
                        showMessage("There was a problem writing data to your device")
                    }
                }
            }
        }
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
    
    
    
    
    
}
