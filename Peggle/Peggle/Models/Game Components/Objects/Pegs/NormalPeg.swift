//
//  NormalPeg.swift
//  Peggle
//
//  Created by James Chiu on 13/2/23.
//

import Foundation

class NormalPeg: PegRB, Fadable {
    var fadableBody: some PegRB { self }
    var ballHitStartTime: Double = 0
    var fadeTime: Double = 1
    var pegHitCount: Int = 0

    lazy var afterFade: () -> Void = { [unowned self] in
        GameWorld.activeGameBoard?.removePeg(self)
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
            pegHitCount += 1

            if pegHitCount == GameWorld.activeGameBoard?.pegRemovalHitCount {
                makeFade()
            }
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
