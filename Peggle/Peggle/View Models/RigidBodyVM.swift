//
//  RigidBodyVM.swift
//  Peggle
//
//  Created by James Chiu on 14/2/23.
//

import Foundation

// For rigidbodies that are visible
class RigidBodyVM: Identifiable {
    let id: Int
    let visibleBody: VisibleRigidBody

    init(_ visibleBody: VisibleRigidBody) {
        self.id = visibleBody.id
        self.visibleBody = visibleBody
    }

    var sprite: String {
        visibleBody.spriteContainer.sprite
    }

    var x: CGFloat {
        visibleBody.x
    }

    var y: CGFloat {
        visibleBody.y
    }

    var spriteWidth: CGFloat {
        visibleBody.spriteWidth
    }

    var spriteHeight: CGFloat {
        visibleBody.spriteHeight
    }

    var rotation: CGFloat {
        360 - visibleBody.rotation
    }
}
