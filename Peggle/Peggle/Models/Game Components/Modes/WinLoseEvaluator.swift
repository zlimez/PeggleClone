//
//  GameMode.swift
//  Peggle
//
//  Created by James Chiu on 27/2/23.
//

import Foundation

protocol WinLoseEvaluator {
    associatedtype Scorer: ScoreSystem
    func reset()
    func evaluateGameState(gameWorld: GameWorld, scoreSystem: Scorer) -> PlayState
}

// TODO: Add in pauseGame for GameWorld
enum PlayState {
    case none, paused, inProgress, won, lost
}
