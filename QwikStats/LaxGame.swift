//
//  LaxGame.swift
//  QwikStats
//
//  Created by Jonathan Kerbelis on 1/18/17.
//  Copyright © 2017 Jonathan Kerbelis. All rights reserved.
//

import Foundation


class LaxGame {
    
    var homeTeam: LaxTeam
    var awayTeam: LaxTeam
    var month: Int
    var day: Int
    var year: Int
    
    init(homeName: String, awayName: String, day: Int, month: Int, year: Int) {
        self.homeTeam = LaxTeam(teamName: homeName, home: true)
        self.awayTeam = LaxTeam(teamName: awayName, home: false)
        self.month = month
        self.day = day
        self.year = year
    }
}
