//
//  Team.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 7/13/16.
//  Copyright © 2016 Jonathan Kerbelis. All rights reserved.
//

import Foundation

class Team {
    var teamScore: Int = 0
    var teamName: String = ""
    var onOffense: Bool = false
    var homeTeam: Bool = false
    var recentPassers = [Int]()
    var recentRunners = [Int]()
    var recentReceivers = [Int]()
    var players = [Player]()
    var playCalls = [String]()
    var formations = [String]()
    
    init (name: String, homeTeam: Bool, offense: Bool) {
        teamName = name
        onOffense = offense
        self.homeTeam = homeTeam
    }
    
    func addRecent(_ play: Play) {
        switch play.playType {
        case "Pass":
            if play.playerNumber != -1 {
                if recentPassers.contains(play.playerNumber) {
                    if let index = recentPassers.index(of: play.playerNumber) {
                        recentPassers.remove(at: index)
                    }
                }
                recentPassers.insert(play.playerNumber, at: 0)
                while recentPassers.count > 3 {
                    recentPassers.remove(at: recentPassers.count - 1)
                }
            }
            
            if play.recNumber != -1 {
                if recentReceivers.contains(play.recNumber) {
                    if let index = recentReceivers.index(of: play.recNumber) {
                        recentReceivers.remove(at: index)
                    }
                }
                recentReceivers.insert(play.recNumber, at: 0)
                while recentReceivers.count > 3 {
                    recentReceivers.remove(at: recentReceivers.count - 1)
                }
            }
            
        case "Run":
            if play.playerNumber != -1 {
                if recentRunners.contains(play.playerNumber) {
                    if let index = recentRunners.index(of: play.playerNumber) {
                        recentRunners.remove(at: index)
                    }
                }
                recentRunners.insert(play.playerNumber, at: 0)
                while recentRunners.count > 3 {
                    recentRunners.remove(at: recentRunners.count - 1)
                }
            }
        default: break
        }
    }
    
    func getPlayer(_ number: Int, offensive: Bool) -> Player? {
        var currentPlayer : Player
        for i in 0 ..< players.count {
            currentPlayer = players[i]
            if currentPlayer.number == number && currentPlayer.offensive == offensive {
                return currentPlayer
            }
        }
        return nil
    }
    
    func addPlayer (_ player: Player) {
        players.append(player)
    }
    
}
