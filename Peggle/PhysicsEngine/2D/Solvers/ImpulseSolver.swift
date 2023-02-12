//
//  ImpulseSolver.swift
//  Peggle
//
//  Created by James Chiu on 12/2/23.
//

import Foundation

class ImpulseSolver: Solver {
    func solve(_ collision: Collision) {
        let rbA = collision.rbA
        let rbB = collision.rbB
        let contact = collision.contact
        
        let velA = rbA.isDynamic ? rbA.velocity : Vector2.zero
        let velB = rbB.isDynamic ? rbB.velocity : Vector2.zero
        let rSpd = Vector2.dotProduct(a: velB - velA, b: contact.normal)
        
        let invMassA = 1 / rbA.mass
        let invMassB = 1 / rbB.mass
        
        if rSpd >= 0 {
            return
        }
        
        let e = rbA.material.restitution * rbB.material.restitution
        let impulse = contact.normal * (-(1 + e) * rSpd / (invMassA + invMassB))
        
        if rbA.isDynamic {
            rbA.applyImpulse(-impulse)
        }
        
        if rbB.isDynamic {
            rbB.applyImpulse(impulse)
        }
    }
}
