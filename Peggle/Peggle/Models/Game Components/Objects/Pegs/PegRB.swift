//
//  PegRB.swift
//  Peggle
//
//  Created by James Chiu on 25/2/23.
//

import Foundation

// Considers block as a peg, during design there is no behaviour difference
// hence I do not see the need to intentionally consider it separately other
// than having a different set of a behaviour as with peg variants
class PegRB: VisibleRigidBody {
    let peg: Peg
    var unitWidth: CGFloat { peg.unitWidth }
    var unitHeight: CGFloat { peg.unitHeight }

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
