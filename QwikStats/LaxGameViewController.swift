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
import Alamofire

var currentPlayerNum: Int!
var currentTitle: String!
var txtSpeechInput: String!
var forcedTurnover: Bool!

class LaxGameViewController: UIViewController, OEEventsObserverDelegate {
    
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
    var openEarsEventsObserver = OEEventsObserver()
    var APIUser = "qwikcutappstats"
    var API_KEY = "ebd7a876-c8ad-11e6-9d9d-cec0c932ce01"
    var userid = 0
    var deviceUUID = "82c5ea27-d30e-4b13-8ed7-9151b7c61bff"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.openEarsEventsObserver = OEEventsObserver()
        self.openEarsEventsObserver.delegate = self
        
        vrEnabled = false
        vrSwitch.setOn(vrEnabled, animated: true)
        vrSwitch.isEnabled = false
        
        
        gameName = "\(month)_\(day)_\(year)_\(homeTeamName)_\(awayTeamName)"
        
        game = LaxGame(homeName: homeTeamName, awayName: awayTeamName, day: day, month: month, year: year)
        
        matchupName = "\(homeTeamName) vs. \(awayTeamName)"
        
        homeTeamLabel.text = homeTeamName
        awayTeamLabel.text = awayTeamName
        forcedTurnover = false
        
        //startOESpeech()
    
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
            
            case homeAssistBtn:
                currentTitle = "Assist"
            
            case homeGoalBtn:
                currentTitle = "Goal"
            
            case homeSaveBtn:
                currentTitle = "Save"
                
            case homeTurnoverBtn:
                currentTitle = "Turnover"
                
            case homeShotBtn:
                currentTitle = "Shot"
            
            case homePenaltyBtn:
                currentTitle = "Penalty"
            
            default:
                currentTitle = ""
        }
        
        if (vrSwitch.isOn) {
            speechInputDialog()
            sleep(1)
            beginListening()
        }
        else {
            enterNumberDialog()
        }
    }
    
    @IBAction func awayStatPressed(_ sender: UIButton) {
        home = false
        txtSpeechInput = ""
        
        switch sender {
            case awayGrounderBtn:
                currentTitle = "Grounder"
                
            case awayAssistBtn:
                currentTitle = "Assist"
                
            case awayGoalBtn:
                currentTitle = "Goal"
            
            case awaySaveBtn:
                currentTitle = "Save"
                
            case awayTurnoverBtn:
                currentTitle = "Turnover"
            
            case awayShotBtn:
                currentTitle = "Shot"
                
            case awayPenaltyBtn:
                currentTitle = "Penalty"
                
            default:
                currentTitle = ""
        }
        
        if (vrSwitch.isOn) {
            speechInputDialog()
            sleep(1)
            beginListening()
        }
        else {
            enterNumberDialog()
        }
    }
    
    func addStat(num: Int) {
        stopListening()
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
        showMessage("Stat Saved: " + String(num))
        postStats()
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
    
    func saveGame() {
        showMessage("Saving Game...")
    }
    
    func postStats() {
        if (game.homeTeam.players.count > 0) {
            postAllTeamStats(team: game.homeTeam)
        }
        if (game.awayTeam.players.count > 0) {
            postAllTeamStats(team: game.awayTeam)
        }
    }
    
    func postAllTeamStats(team: LaxTeam){
        let url = "http://qwikcut-stats.cloudapp.net/api/v1.0/lacrosse/stats"
        
        let date = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString: String = formatter.string(from: date as Date)
        
        //let credentialData = "\(APIUser):\(API_KEY)".data(using: String.Encoding.utf8, allowLossyConversion: true)
        //let base64Credentials = credentialData?.base64EncodedString(options: [])
        
        let header: HTTPHeaders = [
            "Authorization": "Basic cXdpa2N1dGFwcHN0YXRzOmViZDdhODc2LWM4YWQtMTFlNi05ZDlkLWNlYzBjOTMyY2UwMQ==",
            "Content-Type": "application/json"
        ]
        
        for player in team.players {
            let p : [String: Any] = [
                "id": 0,
                "statid": 1,
                "playerid": 0,
                "playernumber": player.number,
                "goals": player.goals,
                "shots": player.shots,
                "assists": player.assists,
                "saves": player.saves,
                "grounders": player.grounders,
                "turnovers": player.turnovers,
                "forcedturnovers": player.forcedTurnovers,
                "penalties": player.penalties,
                "teamid": 0,
                "gameid": 0,
                "teamname": team.teamName,
                "statdate": dateString,
                "userid": userid,
                "deviceid": deviceUUID
            ]
            Alamofire.request(url, method: .post, parameters: p, encoding: JSONEncoding.default, headers: header).responseJSON {
                response in
                    NSLog("RESPONSE: \(response)")
                if let statusCode = response.response?.statusCode {
                    NSLog("\(team.teamName): \(statusCode)")
                    if statusCode == 201 {
                        team.removePlayer(number: player.number)
                    }
                    else {
                        //post failed so that needs to be handled
                    }
                }
            }
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
            self.performSegue(withIdentifier: "laxUnwindSegue", sender: self)
        }
        alertController.addAction(exitAction)
        
        let nextQtrAction = UIAlertAction(title: "Exit Without Saving", style: .default) { (action) in
            self.performSegue(withIdentifier: "laxUnwindSegue", sender: self)
        }
        alertController.addAction(nextQtrAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showMessage(_ message: String) {
        self.view.makeToast(message, duration: 3.0, position: .bottom)
    }
    
    func startOESpeech() {
        switch AVAudioSession.sharedInstance().recordPermission() {
            case AVAudioSessionRecordPermission.granted:
                print("Permission granted")
            case AVAudioSessionRecordPermission.denied:
                print("Pemission denied")
            case AVAudioSessionRecordPermission.undetermined:
                AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
            if granted {
                return
            } else{
                print("not granted")
            }
            })
            default:
            break
        }
        
        
        let lmGenerator = OELanguageModelGenerator()
        
        words = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10",
                 "11", "12", "13", "14", "15", "16", "17", "18", "19", "20",
                 "21", "22", "23", "24", "25", "26", "27", "28", "29", "30",
                 "31", "32", "33", "34", "35", "36", "37", "38", "39", "40",
                 "41", "42", "43", "44", "45", "46", "47", "48", "49", "50",
                 "51", "52", "53", "54", "55", "56", "57", "58", "59", "60",
                 "61", "62", "63", "64", "65", "66", "67", "68", "69", "70",
                 "71", "72", "73", "74", "75", "76", "77", "78", "79", "80",
                 "81", "82", "83", "84", "85", "86", "87", "88", "89", "90",
                 "91", "92", "93", "94", "95", "96", "97", "98", "99", "100"]
        
        let name = "numbers"
        let err: Error! = lmGenerator.generateLanguageModel(from: words, withFilesNamed: name, forAcousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"))
        
        if(err != nil) {
            print("Error while creating initial language model: \(err)")
        } else {
            let lmPath = lmGenerator.pathToSuccessfullyGeneratedLanguageModel(withRequestedName: name) // Convenience method to reference the path of a language model known to have been created successfully.
            let dicPath = lmGenerator.pathToSuccessfullyGeneratedDictionary(withRequestedName: name) // Convenience method to reference the path of a dictionary known to have been created successfully.
        }
        
        lmPath = lmGenerator.pathToSuccessfullyGeneratedLanguageModel(withRequestedName: name)
        dicPath = lmGenerator.pathToSuccessfullyGeneratedDictionary(withRequestedName: name)
    }
    
    func enterNumberDialog() {
        
        if (currentTitle == "Turnover") {
            turnoverDialog()
            return
        }
        
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
    
    func speechInputDialog() {
        let navigationController = self.storyboard!.instantiateViewController(withIdentifier: "SpeechInputViewController")// as! UIViewController
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        //formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        //formSheetController.presentationController?.shouldApplyBackgroundBlurEffect = true
        //width is first, height is second
        formSheetController.presentationController?.contentViewSize = CGSize(width: 295, height: 206)
        formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.slideAndBounceFromBottom
        
        formSheetController.willPresentContentViewControllerHandler = { vc in
            let navigationController = vc
            let presentedViewController = navigationController as! SpeechInputViewController
            presentedViewController.view?.layoutIfNeeded()
            //presentedViewController.playTypeLabel?.text = "Play Type"
        }
        
        self.present(formSheetController, animated: true, completion: nil)
    }
    
    func beginListening() {
        // OELogging.startOpenEarsLogging() //Uncomment to receive full OpenEars logging in case of any unexpected results.
        do {
            try OEPocketsphinxController.sharedInstance().setActive(true) // Setting the shared OEPocketsphinxController active is necessary before any of its properties are accessed.
            OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(atPath: lmPath, dictionaryAtPath: dicPath, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false)
        } catch {
            print("Error: it wasn't possible to set the shared instance to active: \"\(error)\"")
        }
        
        OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(atPath: lmPath, dictionaryAtPath: dicPath, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false)
    }
    
    func stopListening() {
        OEPocketsphinxController.sharedInstance().stopListening()
    }
    
    func pocketsphinxDidReceiveHypothesis(_ hypothesis: String!, recognitionScore: String!, utteranceID: String!) { // Something was heard
        print("Local callback: The received hypothesis is \(hypothesis!) with a score of \(recognitionScore!) and an ID of \(utteranceID!)")
        //numberLabel.text = hypothesis
        let vc = presentedViewController as! SpeechInputViewController!
        vc?.numberLabel.text = hypothesis
        
    }
    
    // An optional delegate method of OEEventsObserver which informs that the Pocketsphinx recognition loop has entered its actual loop.
    // This might be useful in debugging a conflict between another sound class and Pocketsphinx.
    func pocketsphinxRecognitionLoopDidStart() {
        print("Local callback: Pocketsphinx started.") // Log it.
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx is now listening for speech.
    func pocketsphinxDidStartListening() {
        print("Local callback: Pocketsphinx is now listening.") // Log it.
        let vc = presentedViewController as! SpeechInputViewController!
        vc?.statusLabel.text = "Listening..."
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx detected speech and is starting to process it.
    func pocketsphinxDidDetectSpeech() {
        print("Local callback: Pocketsphinx has detected speech.") // Log it.
        let vc = presentedViewController as! SpeechInputViewController!
        vc?.statusLabel.text = "Listening..."
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx detected a second of silence, indicating the end of an utterance.
    func pocketsphinxDidDetectFinishedSpeech() {
        print("Local callback: Pocketsphinx has detected a second of silence, concluding an utterance.") // Log it.
        let vc = presentedViewController as! SpeechInputViewController!
        vc?.statusLabel.text = "Say a Number"
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx has exited its recognition loop, most
    // likely in response to the OEPocketsphinxController being told to stop listening via the stopListening method.
    func pocketsphinxDidStopListening() {
        print("Local callback: Pocketsphinx has stopped listening.") // Log it.
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx is still in its listening loop but it is not
    // Going to react to speech until listening is resumed.  This can happen as a result of Flite speech being
    // in progress on an audio route that doesn't support simultaneous Flite speech and Pocketsphinx recognition,
    // or as a result of the OEPocketsphinxController being told to suspend recognition via the suspendRecognition method.
    func pocketsphinxDidSuspendRecognition() {
        print("Local callback: Pocketsphinx has suspended recognition.") // Log it.
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx is still in its listening loop and after recognition
    // having been suspended it is now resuming.  This can happen as a result of Flite speech completing
    // on an audio route that doesn't support simultaneous Flite speech and Pocketsphinx recognition,
    // or as a result of the OEPocketsphinxController being told to resume recognition via the resumeRecognition method.
    func pocketsphinxDidResumeRecognition() {
        print("Local callback: Pocketsphinx has resumed recognition.") // Log it.
    }
    
    // An optional delegate method which informs that Pocketsphinx switched over to a new language model at the given URL in the course of
    // recognition. This does not imply that it is a valid file or that recognition will be successful using the file.
    func pocketsphinxDidChangeLanguageModel(toFile newLanguageModelPathAsString: String!, andDictionary newDictionaryPathAsString: String!) {
        
        print("Local callback: Pocketsphinx is now using the following language model: \n\(newLanguageModelPathAsString!) and the following dictionary: \(newDictionaryPathAsString!)")
    }
    
    // An optional delegate method of OEEventsObserver which informs that Flite is speaking, most likely to be useful if debugging a
    // complex interaction between sound classes. You don't have to do anything yourself in order to prevent Pocketsphinx from listening to Flite talk and trying to recognize the speech.
    func fliteDidStartSpeaking() {
        print("Local callback: Flite has started speaking") // Log it.
    }
    
    // An optional delegate method of OEEventsObserver which informs that Flite is finished speaking, most likely to be useful if debugging a
    // complex interaction between sound classes.
    func fliteDidFinishSpeaking() {
        print("Local callback: Flite has finished speaking") // Log it.
    }
    
    func pocketSphinxContinuousSetupDidFail(withReason reasonForFailure: String!) { // This can let you know that something went wrong with the recognition loop startup. Turn on [OELogging startOpenEarsLogging] to learn why.
        print("Local callback: Setting up the continuous recognition loop has failed for the reason \(reasonForFailure), please turn on OELogging.startOpenEarsLogging() to learn more.") // Log it.
    }
    
    func pocketSphinxContinuousTeardownDidFail(withReason reasonForFailure: String!) { // This can let you know that something went wrong with the recognition loop startup. Turn on OELogging.startOpenEarsLogging() to learn why.
        print("Local callback: Tearing down the continuous recognition loop has failed for the reason \(reasonForFailure)") // Log it.
    }
    
    /** Pocketsphinx couldn't start because it has no mic permissions (will only be returned on iOS7 or later).*/
    func pocketsphinxFailedNoMicPermissions() {
        print("Local callback: The user has never set mic permissions or denied permission to this app's mic, so listening will not start.")
    }
    
    /** The user prompt to get mic permissions, or a check of the mic permissions, has completed with a true or a false result  (will only be returned on iOS7 or later).*/
    
    func micPermissionCheckCompleted(withResult: Bool) {
        print("Local callback: mic check completed.")
    }
}
