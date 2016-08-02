//
//  Play.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 7/13/16.
//  Copyright © 2016 Jonathan Kerbelis. All rights reserved.
//

import Foundation

class Play {
    var playerNumber = -1, recNumber = -1, defNumber = -1, fieldPos = 0, prevYdLn = 0, ydLn = 0, gnLs = 0, downNum = 0, dist = 0, qtr = 1, fgDistance = 0, playCount = 0, returnYds = 0, prevDist = 0, prevDown = 0, homeScore = 0, awayScore = 0, firstDn = 0, returnedYdLn = -51
    var tacklers = [Int]()
    var incompleteFlag = false, touchdownFlag = false, recFlag = false, touchbackFlag = false, faircatchFlag = false, interceptionFlag = false, fumbleFlag = false, fumbleRecFlag = false, tackleFlag = false, sackFlag = false, fgMadeFlag = false, possFlag = false, safetyFlag = false, defensivePenalty = false, lossFlag = false, returnFlag = false, oppTerFlag = false, invalidPlay = false
    var playType = "", result = "", notes = "", formation = " ", prevHash = " ", hash = " ", playCall = " ", offensiveTeam = " ", playDir = " "
    
    init (currentGame: Game) {
        prevDist = currentGame.dist
        dist = currentGame.dist
        prevDown = currentGame.down
        downNum = currentGame.down
        firstDn = currentGame.firstDn
        prevYdLn = currentGame.ydLn
        ydLn = currentGame.ydLn
        homeScore = currentGame.homeTeam.teamScore
        awayScore = currentGame.awayTeam.teamScore
        possFlag = currentGame.possFlag
        qtr = currentGame.qtr
        prevHash = currentGame.hash
        
        safetyFlag = false
    }
    
}