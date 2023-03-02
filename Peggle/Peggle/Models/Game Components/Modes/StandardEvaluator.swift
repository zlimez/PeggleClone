//
//  StandardEvaluator.swift
//  Peggle
//
//  Created by James Chiu on 27/2/23.
//

import Foundation

class StandardEvaluator: WinLoseEvaluator {
    typealias Scorer = CivilianScoreSystem

    var allowedKills: Int = 0
    var hostileCount: Int = 0

    func reset() {
        allowedKills = 0
        hostileCount = 0
    }

    func evaluateGameState(gameWorld: GameWorld, scoreSystem: CivilianScoreSystem) -> PlayState {
        if scoreSystem.civilianKilled > allowedKills {
            return PlayState.lost
        }

        if scoreSystem.hostileKilled == hostileCount {
            return PlayState.won
        }

        if !gameWorld.ballCounter.hasBallLeft && gameWorld.shotComplete {
            return PlayState.lost
        }

        return PlayState.inProgress
    }
}

class TimedHighScoreEvaluator: WinLoseEvaluator {
    typealias Scorer = BaseScoreSystem
    var targetScore: Int = 0

    func reset() {
        targetScore = 0
    }

    func evaluateGameState(gameWorld: GameWorld, scoreSystem: BaseScoreSystem) -> PlayState {
        if !gameWorld.timer.expired {
            return PlayState.inProgress
        }

        return scoreSystem.score >= targetScore ? PlayState.won : PlayState.lost
    }
}

class NoHitEvaluator: WinLoseEvaluator {
    typealias Scorer = NoScoreSystem
    func reset() {}

    func evaluateGameState(gameWorld: GameWorld, scoreSystem: NoScoreSystem) -> PlayState {
        if scoreSystem.hasHit {
            return PlayState.lost
        } else if !gameWorld.ballCounter.hasBallLeft && gameWorld.shotComplete {
            return PlayState.won
        }
        return PlayState.inProgress
    }
}
