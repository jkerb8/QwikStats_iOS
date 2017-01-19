//
//  LaxPlayer.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 1/18/17.
//  Copyright © 2017 Jonathan Kerbelis. All rights reserved.
//

import Foundation

 class LaxPlayer {
    
    var number: Int = 0
    var shots: Int = 0
    var saves: Int = 0
    var goals: Int = 0
    var penalties: Int = 0
    var assists: Int = 0
    var turnovers: Int = 0
    var forcedTurnovers: Int = 0
    var grounders: Int = 0
    var position: String = ""
    
    init (number: Int) {
        self.number = number
    }
    
    func addGrounder() {
        grounders += 1
    }
    func minusGrounder() {
        grounders -= 1
    }
    
    func addShot() {
        shots += 1
    }
    func minusShot() {
        shots -= 1
    }
    
    func addGoal() {
        goals += 1
    }
    func minusGoal() {
        goals -= 1
    }
    
    func addSave() {
        saves += 1
    }
    func minusSave() {
        saves -= 1
    }
    
    func addPenalty() {
        penalties += 1
    }
    func minusPenalty() {
        penalties -= 1
    }
    
    func addAssist() {
        assists += 1
    }
    func minusAssist() {
        assists -= 1
    }
    
    func addTurnover(forced: Bool) {
        turnovers += 1
        if forced {
            forcedTurnovers += 1
        }
    }
    func minusTurnover(forced: Bool) {
        turnovers -= 1
        if forced {
            forcedTurnovers -= 1
        }
    }

    
}
