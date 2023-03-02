//
//  ChancePeg.swift
//  Peggle
//
//  Created by James Chiu on 2/3/23.
//

import Foundation

// Frank Peg
class ChancePeg: PegRB, Fadable {
    var fadableBody: some PegRB { self }
    var ballHitStartTime: Double = 0
    var fadeTime: Double = 1
    var pegHitCount: Int = 0
    var chance: Double

    init(peg: Peg, collider: Collider, chance: Double = 1 / 3) {
        self.chance = chance
        super.init(peg: peg, collider: collider)
    }

    lazy var afterFade: () -> Void = { [unowned self] in
        GameWorld.activeGameBoard?.removePeg(self)
    }

    func giveFreeBallOnChance() -> Bool {
        let randNum = Int.random(in: 0...100)
        if Double(randNum) / 100 <= chance {
            spriteContainer.sprite = peg.pegLitSprite
            GameWorld.activeGameBoard?.addBallToCount()
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

            if giveFreeBallOnChance() {
                makeFade()
            }

            ballHitStartTime = activeGameBoard.gameTime
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
