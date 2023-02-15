//
//  VisibleRigidBody.swift
//  Peggle
//
//  Created by James Chiu on 14/2/23.
//

import Foundation

class VisibleRigidBody: RigidBody {
    var sprite: String?
    var unitWidth: CGFloat?
    var unitHeight: CGFloat?
    
    var x: CGFloat {
        transform.position.x
    }
    
    var y: CGFloat {
        transform.position.y
    }
    
    var spriteWidth: CGFloat {
        guard let unitWidth = unitWidth else {
            return 0
        }
        return transform.scale.x * unitWidth
    }
    
    var spriteHeight: CGFloat {
        guard let unitHeight = unitHeight else {
            return 0
        }
        return transform.scale.y * unitHeight
    }
    
    var rotation: CGFloat {
        transform.rotation
    }
}
