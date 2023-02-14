//
//  Collider.swift
//  Peggle
//
//  Created by James Chiu on 11/2/23.
//

import Foundation

protocol Collider {
    func testCollision(transform: Transform, otherCollider: Collider, otherTransform: Transform) -> ContactPoints
    func testCollision(transform: Transform, otherCollider: CircleCollider, otherTransform: Transform) -> ContactPoints
    func testCollision(transform: Transform, otherCollider: PolygonCollider, otherTransform: Transform) -> ContactPoints
    func testCollision(transform: Transform, otherCollider: BoxCollider, otherTransform: Transform) -> ContactPoints
}
