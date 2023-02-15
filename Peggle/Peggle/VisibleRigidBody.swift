//
//  VisibleRigidBody.swift
//  Peggle
//
//  Created by James Chiu on 14/2/23.
//

import Foundation

class VisibleRigidBody: RigidBody {
    var spriteContainer: SpriteContainer
    
    init(isDynamic: Bool,
         material: Material,
         collider: Collider,
         transform: Transform = Transform.standard,
         spriteContainer: SpriteContainer,
         mass: CGFloat = 1,
         initVelocity: Vector2 = Vector2.zero,
         isTrigger: Bool = false
    ) {
        self.spriteContainer = spriteContainer
        super.init(
            isDynamic: isDynamic,
            material: material,
            collider: collider,
            transform: transform,
            mass: mass,
            initVelocity: initVelocity,
            isTrigger: isTrigger
        )
    }

    var x: CGFloat {
        transform.position.x
    }

    var y: CGFloat {
        transform.position.y
    }

    var spriteWidth: CGFloat {
        transform.scale.x * spriteContainer.unitWidth
    }

    var spriteHeight: CGFloat {
        transform.scale.y * spriteContainer.unitHeight
    }

    var rotation: CGFloat {
        transform.rotation
    }
}
