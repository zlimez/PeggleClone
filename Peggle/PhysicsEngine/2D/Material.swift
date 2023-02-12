//
//  Material.swift
//  Peggle
//
//  Created by James Chiu on 11/2/23.
//

import Foundation

struct Material {
    static let staticMaterial = Material(restitution: 1)
    // Value should be between 0 and 1
    let restitution: CGFloat
}
