//
//  WorldObjectVM.swift
//  Peggle
//
//  Created by James Chiu on 14/2/23.
//

import Foundation

// For world objects that are visible
class WorldObjectVM: Identifiable {
    let id: Int
    let visibleObject: Renderable
    let scaleFactor: CGFloat

    init(visibleObject: Renderable, scaleFactor: CGFloat) {
        self.id = visibleObject.id
        self.visibleObject = visibleObject
        self.scaleFactor = scaleFactor
    }

    var sprite: String {
        visibleObject.spriteContainer.sprite
    }

    var x: CGFloat {
        visibleObject.x * scaleFactor
    }

    var y: CGFloat {
        visibleObject.y * scaleFactor
    }

    var spriteOpacity: CGFloat {
        visibleObject.spriteOpacity
    }

    var spriteWidth: CGFloat {
        visibleObject.spriteWidth * scaleFactor
    }

    var spriteHeight: CGFloat {
        visibleObject.spriteHeight * scaleFactor
    }

    var rotation: CGFloat {
        visibleObject.rotation
    }
}
