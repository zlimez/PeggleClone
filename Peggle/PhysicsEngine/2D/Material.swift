//
//  Material.swift
//  Peggle
//
//  Created by James Chiu on 11/2/23.
//

import Foundation

struct Material {
    static let staticMaterial = Material(restitution: 1)
    // Irrelevant for computation, just to increase verbosity
    static let triggerMaterial = Material(restitution: 0)
    // Value should be between 0 and 1
    let restitution: CGFloat
}
