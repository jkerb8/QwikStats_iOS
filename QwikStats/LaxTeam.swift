//
//  LaxTeam.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 1/18/17.
//  Copyright © 2017 Jonathan Kerbelis. All rights reserved.
//

import Foundation

class LaxTeam {
    
    var players = [LaxPlayer]()
    var teamName: String = ""
    var home: Bool = false
    
    init(teamName: String, home: Bool) {
        self.teamName = teamName
        self.home = home
    }
    
    func addPlayer(number: Int) {
        for i in stride(from: 0, to: players.count, by: 1) {
            if players[i].number == number {
                return
            }
        }
        players.append(LaxPlayer(number: number))
    }
    
    func getPlayer(number: Int) -> LaxPlayer? {
        for i in stride(from: 0, to: players.count, by: 1) {
            if players[i].number == number {
                return players[i]
            }
        }
        return nil
    }
    
    func removePlayer(number: Int) {
        for i in stride(from: 0, to: players.count, by: 1) {
            if players[i].number == number {
                players.remove(at: i)
                return
            }
        }
    }
    
}
