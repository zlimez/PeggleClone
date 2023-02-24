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
    private var pegFadeTime: Double = 1

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
            spriteContainer: spriteContainer,
            transform: peg.transform
        )
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
        if collision.rbB is CannonBall {
            guard let activeGameBoard = GameWorld.activeGameBoard else {
                fatalError("No active board")
            }
            spriteContainer.sprite = peg.pegLitColor
            ballHitStartTime = activeGameBoard.gameTime

            collisionCount += 1
            if collisionCount == activeGameBoard.pegRemovalHitCount {
                activeGameBoard.addCoroutine(Coroutine(routine: fade, onCompleted: activeGameBoard.removeCoroutine))
            }
            activeGameBoard.queuePegRemoval(self)
        }
    }

    override func onCollisionStay(_ collision: Collision) {
        if collision.rbB is CannonBall {
            guard let activeGameBoard = GameWorld.activeGameBoard else {
                fatalError("No active board")
            }

            if activeGameBoard.gameTime - ballHitStartTime >= activeGameBoard.pegRemovalTimeInterval {
                activeGameBoard.addCoroutine(Coroutine(routine: fade, onCompleted: activeGameBoard.removeCoroutine))
            }
        }
    }
}
