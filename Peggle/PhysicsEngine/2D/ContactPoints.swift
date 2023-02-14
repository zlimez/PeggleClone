//
//  ContactPoints.swift
//  Peggle
//
//  Created by James Chiu on 11/2/23.
//

import Foundation

struct ContactPoints {
    let pointA: Vector2
    let pointB: Vector2
    let normal: Vector2
    let depth: CGFloat
    let hasCollision: Bool
    static let noContact = ContactPoints(
        pointA: Vector2.zero,
        pointB: Vector2.zero,
        normal: Vector2.zero,
        depth: 0,
        hasCollision: false
    )

    var reverse: ContactPoints {
        ContactPoints(pointA: pointB, pointB: pointA, normal: normal, depth: depth, hasCollision: hasCollision)
    }
}
