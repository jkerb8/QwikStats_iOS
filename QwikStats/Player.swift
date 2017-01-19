//
//  Player.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 7/13/16.
//  Copyright © 2016 Jonathan Kerbelis. All rights reserved.
//

import Foundation

class Player {
    var offensive: Bool = false
    var number: Int = 0
    var passcomps: Int = 0
    var passatmpts: Int = 0
    var passyds: Int = 0
    var runatmpts: Int = 0
    var runyds: Int = 0
    var ints: Int = 0
    var fumbles: Int = 0
    var catches: Int = 0
    var recyds: Int = 0
    var passtds: Int = 0
    var runtds: Int = 0
    var rectds: Int = 0
    var puntrettds: Int = 0
    var kickrettds: Int = 0
    var puntreturns: Int = 0
    var kickreturns: Int = 0
    var puntretyds: Int = 0
    var kickretyds: Int = 0
    var pics: Int = 0
    var fumblerecs: Int = 0
    var forcedfums: Int = 0
    var deftds: Int = 0
    var tackles: Float = 0
    var tfls: Float = 0
    var sacks: Float = 0

    init (offensive: Bool, number: Int) {
        self.offensive = offensive
        self.number = number
    }
    
    func updatePassStats(_ yds: Int, pic: Bool, incompletion: Bool, td: Bool, fum: Bool) {
        self.passyds += yds
        if pic {
            self.ints += 1
        }
        if !incompletion {
            self.passcomps += 1
        }
        if td && !fum && !pic {
            self.passtds += 1
        }
        self.passatmpts += 1
     }
    
    func undoPassStats(_ yds: Int, pic: Bool, incompletion: Bool, td: Bool, fum: Bool) {
        self.passyds -= yds
        if pic {
            self.ints -= 1
        }
        if !incompletion {
            self.passcomps -= 1
        }
        if td && !fum && !pic {
            self.passtds -= 1
        }
        self.passatmpts -= 1
    }
    
    func updateRunStats (_ yds: Int, fumb: Bool, td: Bool) {
        runyds += yds
        if fumb {
            fumbles += 1
        }
        if td && !fumb {
            runtds += 1
        }
        runatmpts += 1
    }
    
    func undoRunStats (_ yds: Int, fumb: Bool, td: Bool) {
        runyds -= yds
        if fumb {
            fumbles -= 1
        }
        if td && !fumb {
            runtds -= 1
        }
        runatmpts -= 1
    }
    
    func updateRecStats(_ yds: Int, fumb: Bool, td: Bool) {
        recyds += yds
        if fumb {
            fumbles += 1
        }
        if td && !fumb {
            rectds += 1
        }
        catches += 1
    }
    
    func undoRecStats(_ yds: Int, fumb: Bool, td: Bool) {
        recyds -= yds
        if fumb {
            fumbles -= 1
        }
        if td && !fumb {
            rectds -= 1
        }
        catches -= 1
    }
    
    func updatePuntRetStats(_ yds: Int, fumb: Bool, td: Bool) {
        puntretyds += yds
        if fumb {
            fumbles += 1
        }
        if (td && !fumb) {
            puntrettds += 1
        }
        puntreturns += 1
    }
    
    func undoPuntRetStats(_ yds: Int, fumb: Bool, td: Bool) {
        puntretyds -= yds
        if fumb {
            fumbles -= 1
        }
        if (td && !fumb) {
            puntrettds -= 1
        }
        puntreturns -= 1
    }
    
    func updateKickRetStats (_ yds: Int, fumb: Bool, td: Bool) {
        kickretyds += yds
        if fumb {
            fumbles += 1
        }
        if td && !fumb {
            kickrettds += 1
        }
        kickreturns += 1
    }
    
    func undoKickRetStats (_ yds: Int, fumb: Bool, td: Bool) {
        kickretyds -= yds
        if fumb {
            fumbles -= 1
        }
        if td && !fumb {
            kickrettds -= 1
        }
        kickreturns -= 1
    }
    
    func updateDefStats(_ pic: Bool, tackle: Bool, loss: Bool, fumblerec: Bool, forcedfum: Bool, sack: Bool, td: Bool, group: Bool) {
        if pic {
            pics += 1
        }
        if tackle  {
            if !group {
                tackles += 1
            }
            else {
                tackles += 0.5
            }
        }
        if tackle && loss {
            if !group {
                tfls += 1
            }
            else {
                tfls += 0.5
            }
        }
        if fumblerec {
            fumblerecs += 1
        }
        if (sack) {
            if !group {
                sacks += 1
            }
            else {
                sacks += 0.5
            }
        }
        if td {
            deftds += 1
        }
        if forcedfum {
            forcedfums += 1
        }
    }
    
    func undoDefStats(_ pic: Bool, tackle: Bool, loss: Bool, fumblerec: Bool, forcedfum: Bool, sack: Bool, td: Bool, group: Bool) {
        if pic {
            pics -= 1
        }
        if tackle  {
            if !group {
                tackles -= 1
            }
            else {
                tackles -= 0.5
            }
        }
        if tackle && loss {
            if !group {
                tfls -= 1
            }
            else {
                tfls -= 0.5
            }
        }
        if fumblerec {
            fumblerecs -= 1
        }
        if (sack) {
            if !group {
                sacks -= 1
            }
            else {
                sacks -= 0.5
            }
        }
        if td {
            deftds -= 1
        }
        if forcedfum {
            forcedfums -= 1
        }
    }
    
}
