//
//  BoxCollider.swift
//  Peggle
//
//  Created by James Chiu on 11/2/23.
//

import Foundation

struct BoxCollider: Collider {
    let halfWidth: CGFloat
    let halfHeight: CGFloat
    
    var polygonizedCollider: PolygonCollider {
        PolygonCollider(
            stdVertices: [
                Vector2(x: halfWidth, y: halfHeight),
                Vector2(x: halfWidth, y: -halfHeight),
                Vector2(x: -halfWidth, y: -halfHeight),
                Vector2(x: -halfWidth, y: halfHeight)
            ]
        )
    }
    
    func testCollision(transform: Transform, otherCollider: SphereCollider, otherTransform: Transform) -> ContactPoints {
        otherCollider.testCollision(transform: otherTransform, otherCollider: self, otherTransform: transform).reverse
    }
    
    func testCollision(transform: Transform, otherCollider: PolygonCollider, otherTransform: Transform) -> ContactPoints {
        otherCollider.testCollision(transform: otherTransform, otherCollider: self, otherTransform: transform).reverse
    }
    
    func testCollision(transform: Transform, otherCollider: BoxCollider, otherTransform: Transform) -> ContactPoints {
        polygonizedCollider.testCollision(transform: transform, otherCollider: otherCollider.polygonizedCollider, otherTransform: otherTransform)
    }

    func testCollision(transform: Transform, otherCollider: Collider, otherTransform: Transform) -> ContactPoints {
        otherCollider.testCollision(transform: otherTransform, otherCollider: self, otherTransform: transform).reverse
    }
}
