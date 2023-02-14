//
//  PegRigidBody.swift
//  Peggle
//
//  Created by James Chiu on 13/2/23.
//

import Foundation

class PegRigidBody: RigidBody {
    let peg: Peg
    // If more than threshold number of collisions occur,
    // the pegRb is removed immediately to prevent cannon ball from being trapped
    var collisionCount = 0

    init(_ peg: Peg) {
        self.peg = peg
        super.init(
            isDynamic: false,
            material: Material.staticMaterial,
            collider: CircleCollider(peg.unitRadius),
            transform: peg.transform
        )
    }
    
    override func onCollisionEnter(_ collision: Collision) {
        if collision.rbB is CannonBall {
            collisionCount += 1
            if collisionCount == GameBoard.activeGameBoard?.pegRemovalThreshold {
                GameBoard.activeGameBoard?.removePeg(self)
            }
        }
        
        super.onCollisionEnter(collision)
    }
}
