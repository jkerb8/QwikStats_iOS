//
//  Game.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 7/13/16.
//  Copyright © 2016 Jonathan Kerbelis. All rights reserved.
//

import Foundation


class Game  {
    
    var division: String = ""
    var hash: String = ""
    var year: Int = 0
    var month: Int = 0
    var day: Int = 0
    var qtr: Int = 1
    var dist: Int = 0
    var down: Int = 0
    var firstDn: Int = 0
    var ydLn: Int = 0
    var fieldSize: Int = 0
    var possFlag: Bool = false
    var endOfGame: Bool = false
    var homeTeam : Team
    var awayTeam : Team
    
    init (awayName: String, homeName: String, division: String, day: Int, month: Int, year: Int, fieldSize: Int) {
        awayTeam = Team(name: awayName, homeTeam: false, offense: true)
        homeTeam = Team(name: homeName, homeTeam: true, offense: false)
        self.division = division
        self.year = year
        self.month = month
        self.day = day
        self.fieldSize = fieldSize
    }
    
    func completeReset (){
        awayTeam = Team(name: awayTeam.teamName, homeTeam: false, offense: true)
        homeTeam = Team(name: homeTeam.teamName, homeTeam: true, offense: false)
        
        qtr = 1
        dist = 0
        down = 0
        firstDn = 0
        ydLn = 0
        hash = ""
        possFlag = false
    }
    
    
}