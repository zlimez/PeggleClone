//
//  NormalPeg.swift
//  Peggle
//
//  Created by James Chiu on 13/2/23.
//

import Foundation

class NormalPeg: PegRB {
    private var collisionCount = 0
    private var ballHitStartTime: Double = 0
    private var pegFadeTime: Double = 1

    func makeFade() {
        guard let activeGameBoard = GameWorld.activeGameBoard else {
            fatalError("No active board")
        }
        activeGameBoard.addCoroutine(Coroutine(routine: fade, onCompleted: activeGameBoard.removeCoroutine))
    }

    func fade(deltaTime: Double) -> Bool {
        spriteContainer.opacity -= deltaTime / pegFadeTime
        if spriteContainer.opacity <= 0 {
            GameWorld.activeGameBoard?.removePeg(self)
            return true
        }

        return false
    }

    override func onCollisionEnter(_ collision: Collision) {
        super.onCollisionEnter(collision)
        if collision.rbB is CannonBall || collision.rbB is LoidPeg {
            guard let activeGameBoard = GameWorld.activeGameBoard else {
                fatalError("No active board")
            }
            spriteContainer.sprite = peg.pegLitColor
            ballHitStartTime = activeGameBoard.gameTime

            collisionCount += 1
            if collisionCount == activeGameBoard.pegRemovalHitCount {
                makeFade()
            }
            activeGameBoard.queuePegRemoval(self)
        }
    }

    override func onCollisionStay(_ collision: Collision) {
        if collision.rbB is CannonBall || collision.rbB is LoidPeg {
            guard let activeGameBoard = GameWorld.activeGameBoard else {
                fatalError("No active board")
            }

            if activeGameBoard.gameTime - ballHitStartTime >= activeGameBoard.pegRemovalTimeInterval {
                makeFade()
            }
        }
    }
}
