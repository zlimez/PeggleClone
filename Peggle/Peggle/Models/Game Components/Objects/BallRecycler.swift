//
//  BallRecycler.swift
//  Peggle
//
//  Created by James Chiu on 14/2/23.
//

import Foundation

class BallRecycler: RigidBody {
    init(dim: CGSize, position: Vector2) {
        super.init(
            bodyType: BodyType.stationary,
            material: Material.triggerMaterial,
            collider: BoxCollider(halfWidth: dim.width / 2, halfHeight: dim.height / 2),
            transform: Transform(position),
            isTrigger: true
        )
    }

    override func onTriggerEnter(_ collision: Collision) {
        super.onTriggerEnter(collision)
        if let cannonBall = collision.rbB as? CannonBall {
            if cannonBall.spookCharge > 0 {
                cannonBall.transform.position = Vector2(x: cannonBall.transform.position.x, y: -50)
                cannonBall.spookCharge -= 1
                if cannonBall.spookCharge == 0 {
                    GameWorld.activeGameBoard?.openBucket()
                }
                return
            }
            GameWorld.activeGameBoard?.removeCannonBall(cannonBall)
            GameWorld.activeGameBoard?.fadeCollidedPegs()
        }

        if let loidPeg = collision.rbB as? LoidPeg, loidPeg.isDynamic {
            GameWorld.activeGameBoard?.activeBallCount -= 1
            GameWorld.activeGameBoard?.removePeg(loidPeg)
            GameWorld.activeGameBoard?.fadeCollidedPegs()
        }
    }
}
