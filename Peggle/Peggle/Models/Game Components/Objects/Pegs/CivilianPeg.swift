//
//  CivilianPeg.swift
//  Peggle
//
//  Created by James Chiu on 25/2/23.
//

import Foundation

class CivilianPeg: NormalPeg {
    // TODO: Substitute with animated
    var deathSprite: String
    var deathThreshold: Int
    private var isDead = false
    private var collisionCount = 0

    init(peg: Peg, deathThreshold: Int = 2, deathSprite: String = "peg-grey") {
        self.deathSprite = deathSprite
        self.deathThreshold = deathThreshold
        super.init(peg)
    }

    override func onCollisionEnter(_ collision: Collision) {
        if !isDead && (collision.rbB is CannonBall || collision.rbB is LoidPeg) {
            guard let activeGameBoard = GameWorld.activeGameBoard else {
                fatalError("No active board")
            }
            ballHitStartTime = activeGameBoard.gameTime

            collisionCount += 1
            if collisionCount < deathThreshold {
                spriteContainer.sprite = peg.pegLitSprite
            } else if collisionCount == deathThreshold {
                spriteContainer.sprite = deathSprite
                isDead = true
                activeGameBoard.queuePegRemoval(self)
            }

        }
    }
}
