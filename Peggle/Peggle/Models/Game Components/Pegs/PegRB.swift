//
//  PegRB.swift
//  Peggle
//
//  Created by James Chiu on 25/2/23.
//

import Foundation

class PegRB: VisibleRigidBody {
    let peg: Peg

    init(_ peg: Peg) {
        self.peg = peg
        let spriteContainer = SpriteContainer(
            sprite: peg.pegColor,
            unitWidth: peg.unitRadius * 2,
            unitHeight: peg.unitRadius * 2
        )
        super.init(
            bodyType: BodyType.stationary,
            material: Material.staticMaterial,
            collider: CircleCollider(peg.unitRadius),
            spriteContainer: spriteContainer,
            transform: peg.transform
        )
    }
}
