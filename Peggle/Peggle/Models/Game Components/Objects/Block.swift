//
//  Block.swift
//  Peggle
//
//  Created by James Chiu on 26/2/23.
//

import Foundation

class Block: PegRB {
    init(_ block: Peg) {
        super.init(peg: block, collider: BoxCollider(halfWidth: block.unitWidth / 2, halfHeight: block.unitHeight / 2))
    }
}
