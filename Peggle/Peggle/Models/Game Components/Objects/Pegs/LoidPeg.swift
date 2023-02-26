//
//  LoidPeg.swift
//  Peggle
//
//  Created by James Chiu on 25/2/23.
//

import Foundation

class LoidPeg: PegRB {
    // Scaled by velocity of incoming cannonball
    var baseImpulse: CGFloat

    init(peg: Peg, baseImpulse: CGFloat = 15) {
        self.baseImpulse = baseImpulse
        super.init(peg: peg, collider: CircleCollider(peg.unitWidth / 2))
    }

    override func onCollisionEnter(_ collision: Collision) {
        if bodyType == BodyType.stationary && (collision.rbB is CannonBall || collision.rbB is LoidPeg) {
            bodyType = BodyType.dynamic

            let rSpd = Vector2.dotProduct(a: collision.rbB.velocity, b: collision.contact.normal)

            if rSpd <= 0 {
                return
            }

            applyImpulse(collision.contact.normal * -rSpd * baseImpulse)
        }
    }
}
