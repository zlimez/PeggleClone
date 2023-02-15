//
//  PositionSolver.swift
//  Peggle
//
//  Created by James Chiu on 15/2/23.
//

import Foundation

class PositionSolver: Solver {
    func solve(_ collision: Collision) {
        let rbA = collision.rbA
        let rbB = collision.rbB
        if rbA.isDynamic && rbB.isDynamic {
            collision.rbA.move(-collision.contact.normal * collision.contact.depth / 2)
            collision.rbB.move(collision.contact.normal * collision.contact.depth / 2)
        } else if rbA.isDynamic && !rbB.isDynamic {
            collision.rbA.move(-collision.contact.normal * collision.contact.depth)
        } else if !rbA.isDynamic && rbB.isDynamic {
            collision.rbB.move(collision.contact.normal * collision.contact.depth)
        }
    }
}
