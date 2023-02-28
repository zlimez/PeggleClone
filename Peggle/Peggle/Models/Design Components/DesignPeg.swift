//
//  BoardPeg.swift
//  Peggle
//
//  Created by James Chiu on 26/2/23.
//

import Foundation

class DesignPeg: Identifiable, Hashable {
    static let dummyDesignPeg = DesignPeg(peg: Peg.dummyPeg)
    let id: Int
    var peg: Peg
    var collider: Collider?
    var x: CGFloat { peg.transform.position.x }
    var y: CGFloat { peg.transform.position.y }
    var width: CGFloat { peg.unitWidth * peg.transform.scale.x }
    var height: CGFloat { peg.unitHeight * peg.transform.scale.y }
    var rotation: CGFloat { peg.transform.rotation }
    var pegSprite: String { peg.pegSprite }
    var pegLitSprite: String { peg.pegLitSprite }

    init(peg: Peg, collider: Collider? = nil) {
        self.id = peg.id
        self.peg = peg
        self.collider = collider
    }

    func isCircle() -> Bool {
        false
    }

    func updatePositionTo(_ newPosition: Vector2) {
        peg.transform.position = newPosition
    }

    func rotateTo(_ newRotation: CGFloat) {
        peg.transform.rotation = newRotation
    }

    func scaleTo(_ newScale: Vector2) {
        peg.transform.scale = newScale
    }

    func isCollidingWith(_ otherBoardPeg: DesignPeg) -> Bool {
        guard let collider = collider, let otherCollider = otherBoardPeg.collider else {
            fatalError("Both pegs on board should have collider")
        }
        return collider.testCollision(
            transform: peg.transform,
            otherCollider: otherCollider,
            otherTransform: otherBoardPeg.peg.transform
        ).hasCollision
    }

    static func == (lhs: DesignPeg, rhs: DesignPeg) -> Bool {
        lhs.peg == rhs.peg
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(peg)
    }
}
