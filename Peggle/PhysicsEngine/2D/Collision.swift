//
//  Collision.swift
//  Peggle
//
//  Created by James Chiu on 11/2/23.
//

import Foundation

struct Collision {
    let rbA: RigidBody
    let rbB: RigidBody
    let contact: ContactPoints

    var reverse: Collision {
        Collision(rbA: rbB, rbB: rbA, contact: contact.reverse)
    }
}
