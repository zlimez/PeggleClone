//
//  BondPeg.swift
//  Peggle
//
//  Created by James Chiu on 25/2/23.
//

import Foundation

class BondPeg: NormalPeg, Audible {
    var chargeGiven = false
    var audioClip = "woof"

    override func onCollisionEnter(_ collision: Collision) {
        super.onCollisionEnter(collision)
        TrackPlayer.instance.playSFX(audioClip)
        if !chargeGiven, let cannonBall = collision.rbB as? CannonBall {
            cannonBall.spookCharge += 1
            chargeGiven = true
            GameWorld.activeGameBoard?.shutBucket()
        }
    }
}
