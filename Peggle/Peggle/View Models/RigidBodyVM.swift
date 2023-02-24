//
//  RigidBodyVM.swift
//  Peggle
//
//  Created by James Chiu on 14/2/23.
//

import Foundation

// For world objects that are visible
class WorldObjectVM: Identifiable {
    let id: Int
    let visibleObject: Renderable

    init(_ visibleObject: Renderable) {
        self.id = visibleObject.id
        self.visibleObject = visibleObject
    }

    var sprite: String {
        visibleObject.spriteContainer.sprite
    }

    var x: CGFloat {
        visibleObject.x
    }

    var y: CGFloat {
        visibleObject.y
    }

    var spriteOpacity: CGFloat {
        visibleObject.spriteOpacity
    }

    var spriteWidth: CGFloat {
        visibleObject.spriteWidth
    }

    var spriteHeight: CGFloat {
        visibleObject.spriteHeight
    }

    var rotation: CGFloat {
        360 - visibleObject.rotation
    }
}
