//
//  HostilePeg.swift
//  Peggle
//
//  Created by James Chiu on 25/2/23.
//

import Foundation

class HostilePeg: NormalPeg {
    var captureReward: Int
    
    init(peg: Peg, collider: Collider, captureReward: Int = 150) {
        self.captureReward = captureReward
        super.init(peg: peg, collider: collider)
    }
}
