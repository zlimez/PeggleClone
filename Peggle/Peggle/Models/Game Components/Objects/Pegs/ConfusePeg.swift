//
//  ConfusePeg.swift
//  Peggle
//
//  Created by James Chiu on 1/3/23.
//

import Foundation

class ConfusePeg: NormalPeg {
    override func onCollisionEnter(_ collision: Collision) {
        if collision.rbB is CannonBall || collision.rbB is LoidPeg {
            guard let activeGameBoard = GameWorld.activeGameBoard else {
                fatalError("No active board")
            }
            activeGameBoard.flipPegs()
            spriteContainer.sprite = peg.pegLitSprite
            ballHitStartTime = activeGameBoard.gameTime
            activeGameBoard.queuePegRemoval(self)

            pegHitCount += 1
            if pegHitCount == GameWorld.activeGameBoard?.pegRemovalHitCount {
                makeFade()
            }
        }
    }
}
