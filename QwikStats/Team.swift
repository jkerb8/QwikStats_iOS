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
    
    func addRecent(play: Play) {
        switch play.playType {
        case "Pass":
            if play.playerNumber != -1 {
                if recentPassers.contains(play.playerNumber) {
                    if let index = recentPassers.indexOf(play.playerNumber) {
                        recentPassers.removeAtIndex(index)
                    }
                }
                recentPassers.insert(play.playerNumber, atIndex: 0)
                while recentPassers.count > 3 {
                    recentPassers.removeAtIndex(recentPassers.count - 1)
                }
            }
            
            if play.recNumber != -1 {
                if recentReceivers.contains(play.recNumber) {
                    if let index = recentReceivers.indexOf(play.recNumber) {
                        recentReceivers.removeAtIndex(index)
                    }
                }
                recentReceivers.insert(play.recNumber, atIndex: 0)
                while recentReceivers.count > 3 {
                    recentReceivers.removeAtIndex(recentReceivers.count - 1)
                }
            }
            
        case "Run":
            if play.playerNumber != -1 {
                if recentRunners.contains(play.playerNumber) {
                    if let index = recentRunners.indexOf(play.playerNumber) {
                        recentRunners.removeAtIndex(index)
                    }
                }
                recentRunners.insert(play.playerNumber, atIndex: 0)
                while recentRunners.count > 3 {
                    recentRunners.removeAtIndex(recentRunners.count - 1)
                }
            }
        default: break
        }
    }
    
    func getPlayer(number: Int, offensive: Bool) -> Player? {
        var currentPlayer : Player
        for i in 0 ..< players.count {
            currentPlayer = players[i]
            if currentPlayer.number == number && currentPlayer.offensive == offensive {
                return currentPlayer
            }
        }
        return nil
    }
    
    func addPlayer (player: Player) {
        players.append(player)
    }
    
}