//
//  PegRigidBody.swift
//  Peggle
//
//  Created by James Chiu on 13/2/23.
//

import Foundation

class PegRigidBody: RigidBody {
    let peg: Peg
    
    init(peg: Peg) {
        self.peg = peg
        super.init(isDynamic: false, material: Material.staticMaterial, transform: peg.transform, collider: SphereCollider(standardRadius: peg.unitRadius), isTrigger: false, mass: 1)
    }
}
