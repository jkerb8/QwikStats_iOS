//
//  GameViewController.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 7/13/16.
//  Copyright © 2016 Jonathan Kerbelis. All rights reserved.
//

import UIKit
import Toast_Swift
import MZFormSheetPresentationController

class GameViewController: UITableViewController {
    
    
    //@IBOutlet var awayTeamNameView: UILabel!
    //@IBOutlet var homeTeamNameView: UILabel!
    //@IBOutlet var awayScoreLabel: UILabel!
    //@IBOutlet var homeScoreLabel: UILabel!
    //@IBOutlet var downNoEditLabel: UILabel!
    //@IBOutlet var distNoEditLabel: UILabel!
    //@IBOutlet var ydLnNoEditLabel: UILabel!
    //@IBOutlet var qtrNoEditLabel: UILabel!
    //@IBOutlet var downLabel: UILabel!
    //@IBOutlet var distLabel: UILabel!
    //@IBOutlet var ydLnLabel: UILabel!
    //@IBOutlet var qtrLabel: UILabel!
    
    //@IBOutlet var awayPossImageView: UIImageView!
    //@IBOutlet var homePossImageView: UIImageView!

    //@IBOutlet var playScrollView: UIScrollView!
    
    var buttonList = [UIButton]()
    var gameDataList = [String]()
    var statsList = [String]()
    
    var ydLnList = [String]()
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
    var fieldSize: Int = 100
    var projDir: FILE!
    var flow=true, saved=false, canceled=false, homeTeamStart=false, updateFlag=false
    var globalPlay: Play!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //var day: Int = 0
        //var month: Int = 0
        //var year: Int = 0
        var homeTeamName = ""
        var awayTeamName = ""
        //var division = ""
        
        for i in 0.stride(to: -50, by: -1){
            ydLnList.append(String(i))
        }
        
        for i in 50.stride(to: -1, by: -1) {
            ydLnList.append(String(i))
        }
        
        //get homeTeamName, awayTeamName, day, month, year, division, fieldSize
        //make dirPath and gameName from them
        
        //placeholder until that is sorted out
        awayTeamName = "AwayTeam"
        homeTeamName = "HomeTeam"
        game = Game(awayName: awayTeamName, homeName: homeTeamName, division: "Varsity", day: 1, month: 1, year: 2016, fieldSize: 100)
        
        awayTeamNameView.text = awayTeamName
        homeTeamNameView.text = homeTeamName
        
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
        // Blur will be applied to all MZFormSheetPresentationControllers by default
        MZFormSheetPresentationController.appearance().shouldApplyBackgroundBlurEffect = true
        
        playTypeDialog()
    }

    @IBAction func undoBtn(sender: UIButton) {
    }
    
    func playTypeDialog() {
        
        let navigationController = self.storyboard!.instantiateViewControllerWithIdentifier("PlayTypeController") as! UINavigationController
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        formSheetController.presentationController?.shouldApplyBackgroundBlurEffect = true
        formSheetController.presentationController?.contentViewSize = CGSizeMake(250, 250)
        formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.SlideAndBounceFromTop
        
        let presentedViewController = navigationController.viewControllers.first as! PlayTypeController
        presentedViewController.passingString = "PASSED DATA"
        
        formSheetController.willPresentContentViewControllerHandler = { vc in
            let navigationController = vc as! UINavigationController
            let presentedViewController = navigationController.viewControllers.first as! PlayTypeController
            presentedViewController.view?.layoutIfNeeded()
            presentedViewController.playTypeLabel.text = "BALLS"
        }
        
        self.presentViewController(formSheetController, animated: true, completion: nil)
    }
    
    //functions from github
    //****************************************************
    
    func formSheetControllerWithNavigationController() -> UINavigationController {
        return self.storyboard!.instantiateViewControllerWithIdentifier("PlayTypeController") as! UINavigationController
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "segue" {
                let presentationSegue = segue as! MZFormSheetPresentationViewControllerSegue
                presentationSegue.formSheetPresentationController.presentationController?.shouldApplyBackgroundBlurEffect = true
                let navigationController = presentationSegue.formSheetPresentationController.contentViewController as! UINavigationController
                let presentedViewController = navigationController.viewControllers.first as! PlayTypeController
                //presentedViewController.textFieldBecomeFirstResponder = true
                presentedViewController.passingString = "PASSED DATA"
                presentedViewController.playTypeLabel?.text = "balls"
            }
        }
    }
    
    func passDataToViewControllerAction() {
        let navigationController = self.formSheetControllerWithNavigationController()
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        formSheetController.presentationController?.shouldApplyBackgroundBlurEffect = true
        
        let presentedViewController = navigationController.viewControllers.first as! PresentedTableViewController
        presentedViewController.textFieldBecomeFirstResponder = true
        presentedViewController.passingString = "PASSED DATA"
        
        formSheetController.willPresentContentViewControllerHandler = { vc in
            let navigationController = vc as! UINavigationController
            let presentedViewController = navigationController.viewControllers.first as! PresentedTableViewController
            presentedViewController.view?.layoutIfNeeded()
            presentedViewController.textField?.text = "PASS DATA DIRECTLY TO OUTLET!!"
        }
        
        self.presentViewController(formSheetController, animated: true, completion: nil)
    }
    
    func blurEffectAction() {
        let navigationController = self.formSheetControllerWithNavigationController()
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.shouldApplyBackgroundBlurEffect = true
        formSheetController.presentationController?.blurEffectStyle = UIBlurEffectStyle.Dark
        
        self.presentViewController(formSheetController, animated: true, completion: nil)
    }
    
    func parallaxEffectAction() {
        let navigationController = self.formSheetControllerWithNavigationController()
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.shouldUseMotionEffect = true
        
        self.presentViewController(formSheetController, animated: true, completion: nil)
    }
    
    func customContentViewSizeAction() {
        let navigationController = self.formSheetControllerWithNavigationController()
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.contentViewSize = CGSizeMake(100, 100)
        
        self.presentViewController(formSheetController, animated: true, completion: nil)
    }
    
    func compressedContentViewSizeAction() {
        let navigationController = self.formSheetControllerWithNavigationController()
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.contentViewSize = UILayoutFittingCompressedSize
        
        self.presentViewController(formSheetController, animated: true, completion: nil)
    }
    
    func expandedContentViewSizeAction() {
        let navigationController = self.formSheetControllerWithNavigationController()
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.contentViewSize = UILayoutFittingExpandedSize
        
        self.presentViewController(formSheetController, animated: true, completion: nil)
    }
    
    func customBackgroundColorAction() {
        let navigationController = self.formSheetControllerWithNavigationController()
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.3)
        
        self.presentViewController(formSheetController, animated: true, completion: nil)
    }
    
    func centerVerticallyAction() {
        let navigationController = self.formSheetControllerWithNavigationController()
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.shouldCenterVertically = true
        let presentedViewController = navigationController.viewControllers.first as! PresentedTableViewController
        presentedViewController.textFieldBecomeFirstResponder = true
        
        formSheetController.presentationController?.frameConfigurationHandler = { [weak formSheetController] view, currentFrame, isKeyboardVisible in
            if UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation) {
                return CGRectMake(CGRectGetMidX(formSheetController!.presentationController!.containerView!.bounds) - 210, currentFrame.origin.y, 420, currentFrame.size.height)
            }
            return currentFrame
        };
        
        self.presentViewController(formSheetController, animated: true, completion: nil)
    }
    
    func contentViewShadowAction() {
        let navigationController = self.formSheetControllerWithNavigationController()
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        
        formSheetController.willPresentContentViewControllerHandler = { [weak formSheetController] (value: UIViewController)  -> Void in
            if let weakController = formSheetController {
                weakController.contentViewCornerRadius = 5.0
                weakController.shadowRadius = 6.0
            }
        }
        
        self.presentViewController(formSheetController, animated: true, completion: nil)
    }
    
    func twoFormSheetControllersAction() {
        let navigationController = self.formSheetControllerWithNavigationController()
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        formSheetController.presentationController?.portraitTopInset = 10
        self.presentViewController(formSheetController, animated: true, completion: {
            let navigationController = self.formSheetControllerWithNavigationController()
            let formSheetController2 = MZFormSheetPresentationViewController(contentViewController: navigationController)
            formSheetController2.presentationController?.shouldDismissOnBackgroundViewTap = true
            formSheetController2.presentationController?.shouldApplyBackgroundBlurEffect = true
            formSheetController.presentViewController(formSheetController2, animated: true, completion: nil)
        })
    }
    
    func transparentBackgroundViewAction() {
        let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("TransparentViewController")
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: viewController)
        formSheetController.presentationController?.transparentTouchEnabled = false
        self.presentViewController(formSheetController, animated: true, completion: nil)
    }
    
    func panGestureDismissingGesture() {
        let navigationController = self.formSheetControllerWithNavigationController()
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.interactivePanGestureDismissalDirection = .All;
        self.presentViewController(formSheetController, animated: true, completion: nil)
    }
    
    func formSheetView() {
        let label = UILabel(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 200.0, height: 25.0)))
        label.backgroundColor = .blueColor()
        label.text = "Testing with just a view"
        label.textAlignment = .Center
        label.textColor = .whiteColor()
        
        let formSheetController = MZFormSheetPresentationViewController(contentView: label)
        if let presentationController = formSheetController.presentationController {
            presentationController.shouldCenterVertically = true
            presentationController.shouldDismissOnBackgroundViewTap = true
        }
        
        self.presentViewController(formSheetController, animated: true, completion: nil)
    }
    
    // MARK: -
    
    func presentFormSheetControllerWithTransition(transition: Int) {
        let navigationController = self.formSheetControllerWithNavigationController()
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle(rawValue: transition)!
        
        self.presentViewController(formSheetController, animated: MZFormSheetPresentationTransitionStyle(rawValue: transition)! != .None, completion: nil)
    }
    
    func presentFormSheetControllerWithKeyboardMovement(movementOption: Int) {
        let navigationController = self.formSheetControllerWithNavigationController()
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: navigationController)
        formSheetController.presentationController?.shouldApplyBackgroundBlurEffect = true
        formSheetController.presentationController?.movementActionWhenKeyboardAppears = MZFormSheetActionWhenKeyboardAppears(rawValue: movementOption)!
        formSheetController.contentViewControllerTransitionStyle = MZFormSheetPresentationTransitionStyle.Fade
        let presentedViewController = navigationController.viewControllers.first as! PresentedTableViewController
        presentedViewController.textFieldBecomeFirstResponder = true
        
        self.presentViewController(formSheetController, animated: true, completion: nil)
    }

}
