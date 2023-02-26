//
//  TrianglePeg.swift
//  Peggle
//
//  Created by James Chiu on 26/2/23.
//

import Foundation

// Any triangle shape can be derived by scaling one of the axis
class TrianglePeg: DesignPeg {
    init(_ peg: Peg) {
        if peg.unitWidth != peg.unitHeight {
            fatalError("Base of the triangle must be equilateral")
        }
        let triangleCollider = PolygonCollider(
            stdVertices: [
                Vector2(x: -peg.unitWidth / 2, y: -peg.unitHeight / 3),
                Vector2(x: 0, y: peg.unitHeight / 3 * 2),
                Vector2(x: peg.unitWidth / 2, y: -peg.unitHeight / 3),
            ],
            isBox: false
        )
        super.init(peg: peg, collider: triangleCollider)
    }
}
