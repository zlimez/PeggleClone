//
//  BoxPeg.swift
//  Peggle
//
//  Created by James Chiu on 26/2/23.
//

import Foundation

class BoxPeg: DesignPeg {
    init(_ peg: Peg) {
        let boxCollider = BoxCollider(halfWidth: peg.unitWidth / 2, halfHeight: peg.unitHeight / 2)
        super.init(peg: peg, collider: boxCollider)
    }
}
