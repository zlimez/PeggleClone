//
//  BaseScoreSystem.swift
//  Peggle
//
//  Created by James Chiu on 25/2/23.
//

import Foundation

class BaseScoreSystem: ScoreSystem {
    var score: Int
    private var currTally = 0
    private var arrestStreak = 0
    private var collateralStreak = 0

    init() {
        self.score = 0
    }

    func updateBaseScore(_ pegRemoved: PegRB) {
        if let enemyPeg = pegRemoved as? HostilePeg {
            updateBaseScore(enemyPeg)
            return
        }

        if let civilian = pegRemoved as? CivilianPeg {
            updateBaseScore(civilian)
            return
        }
    }

    private func updateBaseScore(_ hostilePeg: HostilePeg) {
        arrestStreak += 1
        if hostilePeg.threatLevel == ThreatLevel.low {
            currTally += 100
        } else if  hostilePeg.threatLevel == ThreatLevel.high {
            currTally += 500
        }
    }
    
    private func updateBaseScore(_ civilianPeg: CivilianPeg) {
        collateralStreak += 1
        currTally -= 150
    }
    
    // Apply streak based multiplier
    func updateScore() {
        let absNetStreak = abs(arrestStreak - collateralStreak)
        var multiplier = 1
        if absNetStreak <= 2 {
            multiplier = 1
        } else if absNetStreak <= 5 {
            multiplier = 2
        } else if absNetStreak <= 10 {
            multiplier = 3
        } else if  absNetStreak <= 25 {
            multiplier = 5
        } else {
            multiplier = 10
        }
        score += currTally * multiplier
        currTally = 0
        collateralStreak = 0
        arrestStreak = 0
    }
    
    func reset() {
        score = 0
        currTally = 0
        arrestStreak = 0
        collateralStreak = 0
    }
}
