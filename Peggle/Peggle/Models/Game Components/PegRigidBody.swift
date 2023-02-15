//
//  PegRigidBody.swift
//  Peggle
//
//  Created by James Chiu on 13/2/23.
//

import Foundation

class PegRigidBody: VisibleRigidBody {
    let peg: Peg
    private var collisionCount = 0
    private var ballHitStartTime: Double = 0

    init(_ peg: Peg) {
        self.peg = peg
        let spriteContainer = SpriteContainer(
            sprite: peg.pegColor,
            unitWidth: peg.unitRadius * 2,
            unitHeight: peg.unitRadius * 2
        )
        super.init(
            isDynamic: false,
            material: Material.staticMaterial,
            collider: CircleCollider(peg.unitRadius),
            transform: peg.transform,
            spriteContainer: spriteContainer
        )
    }

    override func onCollisionEnter(_ collision: Collision) {
        super.onCollisionEnter(collision)
        if collision.rbB is CannonBall {
            guard let startTime = GameWorld.activeGameBoard?.gameTime else {
                fatalError("No active board")
            }
            spriteContainer.sprite = peg.pegLitColor
            ballHitStartTime = startTime

            collisionCount += 1
            if collisionCount == GameWorld.activeGameBoard?.pegRemovalHitCount {
                GameWorld.activeGameBoard?.removePeg(self)
            }
            GameWorld.activeGameBoard?.queuePegRemoval(self)
        }
    }

    override func onCollisionStay(_ collision: Collision) {
        if collision.rbB is CannonBall {
            guard let activeGameBoard = GameWorld.activeGameBoard else {
                fatalError("No active board")
            }

            if activeGameBoard.gameTime - ballHitStartTime >= activeGameBoard.pegRemovalTimeInterval {
                activeGameBoard.removePeg(self)
            }
        }
    }
}
