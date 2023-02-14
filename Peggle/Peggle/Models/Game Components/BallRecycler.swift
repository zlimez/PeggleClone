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
            isDynamic: false,
            material: Material.triggerMaterial,
            collider: BoxCollider(halfWidth: dim.width / 2, halfHeight: dim.height / 2),
            transform: Transform(position),
            isTrigger: true
        )
    }
    
    override func onTrigger(_ collision: Collision) {
        if collision.rbB is CannonBall {
            GameBoard.activeGameBoard?.removeCannonBall(collision.rbB)
            GameBoard.activeGameBoard?.removeCollidedPegs()
        }
        
        super.onTrigger(collision)
    }
}
