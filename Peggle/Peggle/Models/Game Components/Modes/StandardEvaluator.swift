//
//  StandardEvaluator.swift
//  Peggle
//
//  Created by James Chiu on 27/2/23.
//

import Foundation

class StandardEvaluator: WinLoseEvaluator {
    var allowedKills: Int = 0
    var hostileCount: Int = 0
    
    func evaluateGameState(gameWorld: GameWorld, scoreSystem: ScoreSystem) -> PlayState {
        /// evaluate when civilian ball is killed
        guard let civScoreSystem = scoreSystem as? CivilianScoreSystem else {
            fatalError("Standard evaluator should be associated with civilian score system")
        }
        
        if civScoreSystem.civilianKilled > allowedKills {
            return PlayState.lost
        }
        
        if civScoreSystem.hostileKilled == hostileCount {
            return PlayState.won
        }
        
        if !gameWorld.ballCounter.hasBallLeft {
            return PlayState.lost
        }
        
        return PlayState.inProgress
    }
}

class TimedHighScoreEvaluator: WinLoseEvaluator {
    var targetScore: Int = 0

    func evaluateGameState(gameWorld: GameWorld, scoreSystem: ScoreSystem) -> PlayState {
        if !gameWorld.timer.expired {
            return PlayState.inProgress
        }
        
        return scoreSystem.score >= targetScore ? PlayState.won : PlayState.lost
    }
}

class NoHitEvaluator: WinLoseEvaluator {
    func evaluateGameState(gameWorld: GameWorld, scoreSystem: ScoreSystem) -> PlayState {
        guard let noScoreSystem = scoreSystem as? NoScoreSystem else {
            fatalError("No hit evaluator should be associated with no score system")
        }

        if noScoreSystem.hasHit {
            return PlayState.lost
        } else if !gameWorld.ballCounter.hasBallLeft {
            return PlayState.won
        }
        return PlayState.inProgress
    }
}
