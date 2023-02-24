//
//  Transform.swift
//  Peggle
//
//  Created by James Chiu on 11/2/23.
//

import Foundation

// Only rotation by the z-axis is allowed
struct Transform {
    static let standard = Transform(Vector2.zero)
    var position: Vector2
    var scale: Vector2
    // Ranges from 0 to 2pi
    var rotation: CGFloat

    init(_ position: Vector2) {
        self.position = position
        self.scale = Vector2.one
        self.rotation = 0
    }
}

extension Transform: Codable {}
