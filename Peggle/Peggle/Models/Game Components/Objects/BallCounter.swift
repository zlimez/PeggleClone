//
//  WorldUI.swift
//  Peggle
//
//  Created by James Chiu on 27/2/23.
//

import Foundation

protocol Optional {
    var isActive: Bool { get set }
}

struct BallCounter: Optional {
    var ballCount: Int = 0
    var isActive = true
    var hasBallLeft: Bool {
        !isActive || ballCount > 0
    }

    func getBallCount() -> Int? {
        if !isActive {
            return nil
        }
        return ballCount
    }

    mutating func onBallFired(_ quantity: Int) {
        if !isActive {
            return
        }
        ballCount -= quantity
    }

    mutating func onBallRecycled(_ quantity: Int) {
        if !isActive {
            return
        }
        ballCount += quantity
    }
}

struct CivTally: Optional {
    var isActive = true

    func getCivDeathTally(_ gameModeAttachment: GameModeAttachment) -> (Int, Int)? {
        if !isActive {
            return nil
        }

        guard let civScoreSystem = gameModeAttachment.scoreSystem as? CivilianScoreSystem,
            let stdEvaluator = gameModeAttachment.winLoseEvaluator as? StandardEvaluator else {
            fatalError("Active civilian tally should be matched with standard game mode")
        }

        return (civScoreSystem.civilianKilled, stdEvaluator.allowedKills)
    }
}

struct Score: Optional {
    var isActive = true

    func getScore(_ gameModeAttachment: GameModeAttachment) -> Int? {
        if !isActive {
            return nil
        }

        return gameModeAttachment.scoreSystem.score
    }
}

struct TargetScore: Optional {
    var isActive = false

    func getTargetScore(_ gameModeAttachment: GameModeAttachment) -> Int? {
        if !isActive {
            return nil
        }

        guard let timedScoreEvaluator = gameModeAttachment.winLoseEvaluator as? TimedHighScoreEvaluator else {
            fatalError("Active target score should be matched with timed beat score game mode")
        }

        return timedScoreEvaluator.targetScore
    }
}

struct Timer: Optional {
    var timeLeft: Double = 0
    var isActive = false
    var expired: Bool {
        timeLeft <= 0
    }

    func getTime() -> Double? {
        if !isActive {
            return nil
        }
        return timeLeft
    }

    mutating func countDown(_ deltaTime: Double) {
        if !isActive {
            return
        }

        timeLeft -= deltaTime
    }
}
