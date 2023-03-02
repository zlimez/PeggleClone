//
//  Block.swift
//  Peggle
//
//  Created by James Chiu on 26/2/23.
//

import Foundation

class Block: PegRB, Fadable {
    static var removalHitCountThreshold: Int = 100
    var fadeTime: Double = 1
    var fadableBody: some PegRB { self }
    var ballHitStartTime: Double = 0
    private var blockHitCount: Int = 0

    lazy var afterFade: () -> Void = { [unowned self] in
        GameWorld.activeGameBoard?.removePeg(self)
    }

    init(_ block: Peg) {
        super.init(peg: block, collider: BoxCollider(halfWidth: block.unitWidth / 2, halfHeight: block.unitHeight / 2))
    }

    override func onCollisionEnter(_ collision: Collision) {
        if collision.rbB is CannonBall || collision.rbB is LoidPeg {
            guard let activeGameBoard = GameWorld.activeGameBoard else {
                fatalError("No active board")
            }
            ballHitStartTime = activeGameBoard.gameTime
            blockHitCount += 1
            if blockHitCount == Block.removalHitCountThreshold {
                makeFade()
            }
        }
    }
}
