//
//  NormalPeg.swift
//  Peggle
//
//  Created by James Chiu on 13/2/23.
//

import Foundation

class NormalPeg: PegRB {
    var ballHitStartTime: Double = 0
    var pegFadeTime: Double = 1

    func makeFade() {
        guard let activeGameBoard = GameWorld.activeGameBoard else {
            fatalError("No active board")
        }
        activeGameBoard.addCoroutine(Coroutine(routine: fade, onCompleted: activeGameBoard.removeCoroutine))
    }

    lazy var fade: (Double) -> Bool = { [weak self] (deltaTime: Double) -> Bool in
        guard let self = self else {
            print("Object have been destroyed before its coroutine")
            return true
        }

        self.spriteContainer.opacity -= deltaTime / self.pegFadeTime
        if self.spriteContainer.opacity <= 0 {
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
            spriteContainer.sprite = peg.pegLitSprite
            ballHitStartTime = activeGameBoard.gameTime
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
