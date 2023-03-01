//
//  Setup.swift
//  Peggle
//
//  Created by James Chiu on 27/2/23.
//

import Foundation

protocol WorldConfig {
    func configWorld(gameWorld: GameWorld, pegBodies: Set<PegRB>, evaluator: WinLoseEvaluator)
}

class StandardConfig: WorldConfig {
    func configWorld(gameWorld: GameWorld, pegBodies: Set<PegRB>, evaluator: WinLoseEvaluator) {
        var civilianSurvivability: [CivilianPeg: CGFloat] = [:]
        var hostiles: [HostilePeg] = []
        var bombs: [BoomPeg] = []
        // for each civilian check the hostile pegs and bomb pegs near it
        for pegBody in pegBodies {
            if let civilian = pegBody as? CivilianPeg {
                civilianSurvivability[civilian] = 0
            } else if let hostile = pegBody as? HostilePeg {
                hostiles.append(hostile)
            } else if let bomb = pegBody as? BoomPeg {
                bombs.append(bomb)
            }
        }

        let extendedRadius: CGFloat = 100
        let threatModifier: CGFloat = 0.1
        for civilian in civilianSurvivability.keys {
            var thisSurvivability: CGFloat = 1
            let avgRadius = (civilian.transform.scale.x * civilian.unitWidth
                             + civilian.transform.scale.y * civilian.unitHeight) / 4
            let vulnerabilityRadius = avgRadius + extendedRadius
            for hostile in hostiles {
                let proximity = Vector2.distance(a: hostile.transform.position, b: civilian.transform.position)
                if proximity <= vulnerabilityRadius {
                    let threatPosed = threatModifier * extendedRadius / (proximity - avgRadius)
                    thisSurvivability = max(0, thisSurvivability - threatPosed)
                }
            }
            civilianSurvivability[civilian] = thisSurvivability
        }

        let bombThreat: CGFloat = 0.1
        for bomb in bombs {
            let bombRadius = (bomb.transform.scale.x * bomb.unitWidth
                              + bomb.transform.scale.y * bomb.unitHeight) / 4 * bomb.explosionScale
            for civilian in civilianSurvivability.keys {
                let proximity = Vector2.distance(a: bomb.transform.position, b: civilian.transform.position)
                if proximity <= bombRadius {
                    guard let thisSurvivability = civilianSurvivability[civilian] else {
                        fatalError("Something wrong with swift")
                    }
                    civilianSurvivability[civilian] = max(0, thisSurvivability - bombThreat)
                }
            }
        }

        let totalSurvivability = civilianSurvivability.values.reduce(0, { result, survivability in
            result + survivability
        })
        let allowedKills = civilianSurvivability.count - Int(round(totalSurvivability))

        guard let standardEvaluator = evaluator as? StandardEvaluator else {
            fatalError("Evaluator associated with standard config must be standard evaluator")
        }
        standardEvaluator.allowedKills = allowedKills
        standardEvaluator.hostileCount = hostiles.count
        // Expected to hit an average of 5 hostile balls per shot
        let ballGiven = Int(ceil(Float(hostiles.count) / 5))
        gameWorld.ballCounter.isActive = true
        gameWorld.ballCounter = BallCounter(ballCount: ballGiven)
        gameWorld.civTally.isActive = true
        gameWorld.score.isActive = true
        gameWorld.targetScore.isActive = false
        gameWorld.timer.isActive = false
    }
}

class TimedBeatScoreConfig: WorldConfig {
    func configWorld(gameWorld: GameWorld, pegBodies: Set<PegRB>, evaluator: WinLoseEvaluator) {
        var hostileCount = 0
        // Mid tier streak expected
        let midTierIndex = Int(round(Float(BaseScoreSystem.streakMultipliers.count) / 2))
        let expectedMultiplier = BaseScoreSystem.streakMultipliers[midTierIndex]
        var aggBaseScore = 0
        for pegBody in pegBodies {
            if let hostilePeg = pegBody as? HostilePeg {
                aggBaseScore += hostilePeg.captureReward
                hostileCount += 1
            }
        }

        guard let timedBeatScoreEvaluator = evaluator as? TimedHighScoreEvaluator else {
            fatalError("Evaluator associated with beat score config must be timed high score evaluator")
        }

        let perBallDropTime = 7.5
        let expectedHit: Double = 7
        let timeGiven = perBallDropTime * Double(hostileCount) / expectedHit
        timedBeatScoreEvaluator.targetScore = aggBaseScore * expectedMultiplier
        gameWorld.timer.isActive = true
        gameWorld.timer.timeLeft = timeGiven
        gameWorld.ballCounter.isActive = false
        gameWorld.score.isActive = true
        gameWorld.targetScore.isActive = true
        gameWorld.civTally.isActive = false
    }
}

class siamConfig: WorldConfig {
    func configWorld(gameWorld: GameWorld, pegBodies: Set<PegRB>, evaluator: WinLoseEvaluator) {
        // Let player determine the number of balls to clear
        gameWorld.timer.isActive = false
        gameWorld.ballCounter.isActive = true
        gameWorld.score.isActive = false
        gameWorld.targetScore.isActive = false
        gameWorld.civTally.isActive = false
    }
}
