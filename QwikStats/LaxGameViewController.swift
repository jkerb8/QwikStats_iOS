//
//  LaxGameViewController.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 1/17/17.
//  Copyright © 2017 Jonathan Kerbelis. All rights reserved.
//

import UIKit
import Toast_Swift
import MZFormSheetPresentationController

var currentPlayerNum: Int!
var currentTitle: String!
var txtSpeechInput: String!
var forcedTurnover: Bool!

class LaxGameViewController: UIViewController {
    
    @IBOutlet var matchupLabel: UILabel!
    @IBOutlet var homeTeamLabel: UILabel!
    @IBOutlet var awayTeamLabel: UILabel!
    
    @IBOutlet var homeGrounderBtn: UIButton!
    @IBOutlet var homeAssistBtn: UIButton!
    @IBOutlet var homeGoalBtn: UIButton!
    @IBOutlet var homeSaveBtn: UIButton!
    @IBOutlet var homeTurnoverBtn: UIButton!
    @IBOutlet var homeShotBtn: UIButton!
    @IBOutlet var homePenaltyBtn: UIButton!
    
    @IBOutlet var awayGrounderBtn: UIButton!
    @IBOutlet var awayAssistBtn: UIButton!
    @IBOutlet var awayGoalBtn: UIButton!
    @IBOutlet var awaySaveBtn: UIButton!
    @IBOutlet var awayTurnoverBtn: UIButton!
    @IBOutlet var awayShotBtn: UIButton!
    @IBOutlet var awayPenaltyBtn: UIStackView!
    
    @IBOutlet var vrSwitch: UISwitch!
    
    var homeTeamName: String = ""
    var awayTeamName: String = ""
    var division: String = ""
    var gameName: String = ""
    var matchupName: String = ""
    var day = 1
    var month = 1
    var year = 2017
    var openingPastGame = false
    var home = false
    var vrEnabled = true
    var game: LaxGame!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vrSwitch.setOn(vrEnabled, animated: true)
        
        
        gameName = "\(month)_\(day)_\(year)_\(homeTeamName)_\(awayTeamName)"
        
        game = LaxGame(homeName: homeTeamName, awayName: awayTeamName, day: day, month: month, year: year)
        
        matchupName = "\(homeTeamName) vs. \(awayTeamName)"
        
        matchupLabel.text = matchupName
        homeTeamLabel.text = homeTeamName
        awayTeamLabel.text = awayTeamName
        forcedTurnover = false
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func inputDialog() {
        let dialogVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LaxDialogViewController") as! LaxDialogViewController
        self.addChildViewController(dialogVC)
        dialogVC.view.frame = self.view.frame
        self.view.addSubview(dialogVC.view)
        dialogVC.didMove(toParentViewController: self)
        
    }
    
    @IBAction func homeStatPressed(_ sender: UIButton) {
        home = true
        txtSpeechInput = ""
        switch sender {
            case homeGrounderBtn:
                currentTitle = "Grounder"
                enterNumberDialog()
            
            case homeAssistBtn:
                currentTitle = "Assist"
                enterNumberDialog()
            
            case homeGoalBtn:
                currentTitle = "Goal"
                enterNumberDialog()
            
            case homeSaveBtn:
                currentTitle = "Save"
                enterNumberDialog()
                
            case homeTurnoverBtn:
                currentTitle = "Turnover"
                turnoverDialog()
                
            case homeShotBtn:
                currentTitle = "Shot"
                enterNumberDialog()
            
            case homePenaltyBtn:
                currentTitle = "Penalty"
                enterNumberDialog()
            
            default:
                currentTitle = ""
        }
    }
    
    @IBAction func awayStatPressed(_ sender: UIButton) {
        home = false
        txtSpeechInput = ""
        switch sender {
            case awayGrounderBtn:
                currentTitle = "Grounder"
                enterNumberDialog()
                
            case awayAssistBtn:
                currentTitle = "Assist"
                enterNumberDialog()
                
            case awayGoalBtn:
                currentTitle = "Goal"
                enterNumberDialog()
                
            case awaySaveBtn:
                currentTitle = "Save"
                enterNumberDialog()
                
            case awayTurnoverBtn:
                currentTitle = "Turnover"
                turnoverDialog()
                
            case awayShotBtn:
                currentTitle = "Shot"
                enterNumberDialog()
                
            case awayPenaltyBtn:
                currentTitle = "Penalty"
                enterNumberDialog()
                
            default:
                currentTitle = ""
        }
    }
    
    func addStat(num: Int) {
        var temp: LaxTeam
        if (home) {
            temp = game.homeTeam
        }
        else {
            temp = game.awayTeam
        }
        
        temp.addPlayer(number: num)
        
        switch currentTitle {
            case "Grounder":
                temp.getPlayer(number: num)?.addGrounder()
            case "Assist":
                temp.getPlayer(number: num)?.addAssist()
            case "Goal":
                temp.getPlayer(number: num)?.addGoal()
            case "Save":
                temp.getPlayer(number: num)?.addSave()
            case "Turnover":
                temp.getPlayer(number: num)?.addTurnover(forced: forcedTurnover)
            case "Shot":
                temp.getPlayer(number: num)?.addShot()
            case "Penalty":
                temp.getPlayer(number: num)?.addPenalty()
        default:
            showMessage("Invalid Stat")
            return
        }
        
        if (home) {
            game.homeTeam = temp
        }
        else {
            game.awayTeam = temp
        }
        showMessage("Stat Saved")
    }
    
    func minusStat(num: Int) {
        var temp: LaxTeam
        if (home) {
            temp = game.homeTeam
        }
        else {
            temp = game.awayTeam
        }
        
        switch currentTitle {
        case "Grounder":
            temp.getPlayer(number: num)?.minusGrounder()
        case "Assist":
            temp.getPlayer(number: num)?.minusAssist()
        case "Goal":
            temp.getPlayer(number: num)?.minusGoal()
        case "Save":
            temp.getPlayer(number: num)?.minusSave()
        case "Turnover":
            temp.getPlayer(number: num)?.minusTurnover(forced: forcedTurnover)
        case "Shot":
            temp.getPlayer(number: num)?.minusShot()
        case "Penalty":
            temp.getPlayer(number: num)?.minusPenalty()
        default:
            showMessage("Invalid Stat")
        }
        
        if (home) {
            game.homeTeam = temp
        }
        else {
            game.awayTeam = temp
        }
    }
    
    @IBAction func menuBtn(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Game Menu", message: "Choose an option", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        let saveGameAction = UIAlertAction(title: "Save Game", style: .default) { (action) in
            //self.saveGame()
        }
        alertController.addAction(saveGameAction)
        
        let exitAction = UIAlertAction(title: "Exit Game", style: .default) { (action) in
            self.exitGameDialog()
        }
        alertController.addAction(exitAction)
        
        let exportAction = UIAlertAction(title: "Export", style: .default) { (action) in
            //self.export()
        }
        alertController.addAction(exportAction)
        
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
            //self.saveGame()
            self.performSegue(withIdentifier: "unwindToViewController", sender: self)
        }
        alertController.addAction(exitAction)
        
        let nextQtrAction = UIAlertAction(title: "Exit Without Saving", style: .default) { (action) in
            self.performSegue(withIdentifier: "unwindToViewController", sender: self)
        }
        alertController.addAction(nextQtrAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showMessage(_ message: String) {
        self.view.makeToast(message, duration: 3.0, position: .bottom)
    }
    
    func enterNumberDialog() {
        
        let navigationController = self.storyboard!.instantiateViewController(withIdentifier: "LaxDialogViewController")// as! UIViewController
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        //formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        //formSheetController.presentationController?.shouldApplyBackgroundBlurEffect = true
        //width is first, height is second
        formSheetController.presentationController?.contentViewSize = CGSize(width: 295, height: 206)
        formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.slideAndBounceFromBottom
        
        formSheetController.willPresentContentViewControllerHandler = { vc in
            let navigationController = vc
            let presentedViewController = navigationController as! LaxDialogViewController
            presentedViewController.view?.layoutIfNeeded()
            //presentedViewController.playTypeLabel?.text = "Play Type"
        }
        
        self.present(formSheetController, animated: true, completion: nil)
        
    }
    
    func turnoverDialog() {
        
        let navigationController = self.storyboard!.instantiateViewController(withIdentifier: "LaxTurnoverViewController")// as! UIViewController
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        //formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        //formSheetController.presentationController?.shouldApplyBackgroundBlurEffect = true
        //width is first, height is second
        formSheetController.presentationController?.contentViewSize = CGSize(width: 295, height: 235)
        formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.slideAndBounceFromBottom
        
        formSheetController.willPresentContentViewControllerHandler = { vc in
            let navigationController = vc
            let presentedViewController = navigationController as! LaxTurnoverViewController
            presentedViewController.view?.layoutIfNeeded()
            //presentedViewController.playTypeLabel?.text = "Play Type"
        }
        
        self.present(formSheetController, animated: true, completion: nil)
        
    }
}
