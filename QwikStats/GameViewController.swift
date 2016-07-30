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

var globalPlay: Play!
var fieldSize: Int!
var ydLnData = [String]()
var ydLnStrings = [String]()

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
    var game: Game!
    var gamePlays = [Play]()
    var projDir: FILE!
    var flow=true, saved=false, canceled=false, homeTeamStart=false, updateFlag=false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //var day: Int = 0
        //var month: Int = 0
        //var year: Int = 0
        var homeTeamName = ""
        var awayTeamName = ""
        //var division = ""
        fieldSize = 100
        
        for i in 0.stride(to: -50, by: -1){
            ydLnData.append(String(i))
            ydLnStrings.append(" \(String(i)) ")
        }
        
        for i in 50.stride(to: -1, by: -1) {
            ydLnData.append(String(i))
            ydLnStrings.append(" \(String(i)) ")
        }
        
        //get homeTeamName, awayTeamName, day, month, year, division, fieldSize
        //make dirPath and gameName from them
        
        //placeholder until that is sorted out
        awayTeamName = "AwayTeam"
        homeTeamName = "HomeTeam"
        game = Game(awayName: awayTeamName, homeName: homeTeamName, division: "Varsity", day: 1, month: 1, year: 2016, fieldSize: 100)
        
        globalPlay = Play(currentGame: game)
        
        awayTeamNameView.text = awayTeamName
        homeTeamNameView.text = homeTeamName
        
        homePossImageView.hidden = true
        
        if let play = globalPlay {
            showMessage("PlayerNumber is \(play.playerNumber)")
        }
        else {
            showMessage("Play is nil")
        }
        
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
        //self.performSegueWithIdentifier("newPlaySegue", sender: self)
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
    
    func getResult(currentPlay: Play) -> Play {
        var playResult: String = ""
        var play: Play = currentPlay
        
        switch (play.playType) {
            case "Pass":
                if !play.incompleteFlag && !play.interceptionFlag && !play.sackFlag {
                    playResult = "Number \(play.playerNumber) pass completed to number \(play.recNumber) for \(play.gnLs) yards"
                }
                else if (play.interceptionFlag) {
                    playResult = "Number \(play.playerNumber) pass intercepted by numer \(play.defNumber)"
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
                    play.ydLn = -15
                    play.possFlag = !play.possFlag
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
            playResult += " sacked by number \(play.tacklers[0])"
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
            playResult += " for \(play.gnLs) yards"
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
