//
//  PegRB.swift
//  Peggle
//
//  Created by James Chiu on 25/2/23.
//

import Foundation

class PegRB: VisibleRigidBody {
    let peg: Peg

    init(peg: Peg, collider: Collider) {
        self.peg = peg
        let spriteContainer = SpriteContainer(
            sprite: peg.pegSprite,
            unitWidth: peg.unitWidth,
            unitHeight: peg.unitHeight
        )
        super.init(
            bodyType: BodyType.stationary,
            material: Material.staticMaterial,
            collider: collider,
            spriteContainer: spriteContainer,
            transform: peg.transform
        )
    }
}
