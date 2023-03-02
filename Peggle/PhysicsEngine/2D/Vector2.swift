//
//  Vector2.swift
//  Peggle
//
//  Created by James Chiu on 11/2/23.
//

import Foundation

struct Vector2: Hashable {
    static let zero = Vector2(x: 0, y: 0)
    static let one = Vector2(x: 1, y: 1)
    static let up = Vector2(x: 0, y: 1)
    static let down = Vector2(x: 0, y: -1)
    static let left = Vector2(x: -1, y: 0)
    static let right = Vector2(x: 1, y: 0)
    let x: CGFloat
    let y: CGFloat

    static func dotProduct(a: Vector2, b: Vector2) -> CGFloat {
        a.x * b.x + a.y * b.y
    }

    static func crossProduct(a: Vector2, b: Vector2) -> CGFloat {
        a.x * b.y - a.y * b.x
    }

    static func angle(from: Vector2, to: Vector2) -> CGFloat {
        acos(dotProduct(a: from, b: to) / from.length / to.length) * Double(Math.sign(crossProduct(a: from, b: to)))
    }

    static func - (a: Vector2, b: Vector2) -> Vector2 {
        Vector2(x: a.x - b.x, y: a.y - b.y)
    }

    static func + (a: Vector2, b: Vector2) -> Vector2 {
        Vector2(x: a.x + b.x, y: a.y + b.y)
    }

    static func * (a: Vector2, b: CGFloat) -> Vector2 {
        Vector2(x: a.x * b, y: a.y * b)
    }

    static func / (a: Vector2, b: CGFloat) -> Vector2 {
        Vector2(x: a.x / b, y: a.y / b)
    }

    static func *= (a: inout Vector2, b: CGFloat) {
        a = a * b
    }

    static func += (a: inout Vector2, b: Vector2) {
        a = a + b
    }

    static func == (lhs: Vector2, rhs: Vector2) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }

    static func distance(a: Vector2, b: Vector2) -> CGFloat {
        let dx = a.x - b.x
        let dy = a.y - b.y
        return sqrt(dx * dx + dy * dy)
    }

    static func elementMultiply(a: Vector2, b: Vector2) -> Vector2 {
        Vector2(x: a.x * b.x, y: a.y * b.y)
    }

    static prefix func - (a: Vector2) -> Vector2 {
        Vector2(x: -a.x, y: -a.y)
    }

    func rotateBy(_ rotation: CGFloat) -> Vector2 {
        let rotatedX = cos(rotation) * x - sin(rotation) * y
        let rotatedY = sin(rotation) * x + cos(rotation) * y
        return Vector2(x: rotatedX, y: rotatedY)
    }

    func getNormal() -> Vector2 {
        Vector2(x: -y, y: x).normalize
    }

    var sqrMagnitude: CGFloat {
        x * x + y * y
    }

    var length: CGFloat {
        sqrt(sqrMagnitude)
    }

    var normalize: Vector2 {
        Vector2(x: x / length, y: y / length)
    }
}

extension Vector2: Codable {}
