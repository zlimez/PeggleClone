//
//  CirclePeg.swift
//  Peggle
//
//  Created by James Chiu on 26/2/23.
//

import Foundation

class CirclePeg: DesignPeg {
    init(_ peg: Peg) {
        let circleCollider = CircleCollider(peg.unitWidth / 2)
        super.init(peg: peg, collider: circleCollider)
    }

    override func isCircle() -> Bool {
        true
    }
}
