//
//  BondPeg.swift
//  Peggle
//
//  Created by James Chiu on 25/2/23.
//

import Foundation

class BondPeg: NormalPeg {
    var chargeGiven = false

    override func onCollisionEnter(_ collision: Collision) {
        super.onCollisionEnter(collision)
        if !chargeGiven, let cannonBall = collision.rbB as? CannonBall {
            cannonBall.spookCharge += 1
            chargeGiven = true
        }
    }
}
