//
//  ImpulseSolver.swift
//  Peggle
//
//  Created by James Chiu on 12/2/23.
//

import Foundation

final class ImpulseSolver: Solver {
    static let noBounceThreshold: CGFloat = 25
    static func solve(_ collision: Collision) {
        let rbA = collision.rbA
        let rbB = collision.rbB
        let contact = collision.contact

        if !rbA.isDynamic && !rbB.isDynamic {
            return
        }

        if rbA.isDynamic && rbB.isDynamic {
            let rSpd = Vector2.dotProduct(a: rbB.velocity - rbA.velocity, b: contact.normal)

            let invMassA = 1 / rbA.mass
            let invMassB = 1 / rbB.mass

            if rSpd >= 0 {
                return
            }

            let e = rbA.material.restitution * rbB.material.restitution
            let impulse = contact.normal * (-(1 + e) * rSpd / (invMassA + invMassB))

            rbA.applyImpulse(-impulse)
            rbB.applyImpulse(impulse)
            return
        }

        // Special handling for collision between dynamic and static objects
        if rbA.isDynamic {
            dynamicStaticSolve(rbA: rbA, rbB: rbB, contact: contact)
        } else {
            dynamicStaticSolve(rbA: rbB, rbB: rbA, contact: contact.reverse)
        }
    }

    private static func dynamicStaticSolve(rbA: RigidBody, rbB: RigidBody, contact: ContactPoints) {
        let rSpd = Vector2.dotProduct(a: Vector2.zero - rbA.velocity, b: contact.normal)

        if rSpd >= 0 {
            return
        }

        if abs(rSpd) < ImpulseSolver.noBounceThreshold {
            let stoppageImpulse = contact.normal * Vector2.dotProduct(a: rbA.momentum, b: contact.normal)
            rbA.applyImpulse(-stoppageImpulse)
            return
        }

        let impulse = contact.normal
            * Vector2.dotProduct(a: rbA.momentum, b: contact.normal)
            * (1 + rbA.material.restitution)
        rbA.applyImpulse(-impulse)
    }
}
