//
//  Peg.swift
//  Peggle
//
//  Created by James Chiu on 28/1/23.
//

import Foundation

// TODO: Account for Peg scaling
class Peg: Identifiable, Hashable, Codable {
    private static var counter = 0
    let id: Int
    let pegColor: String
    let unitRadius: CGFloat
    // Relative to center, x value increases to the right, y value increases downwards
    var transform: Transform

    enum CodingKeys: String, CodingKey {
        case id
        case pegColor
        case unitRadius
        case transform
    }

    static func getCounter() -> Int {
        Peg.counter
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(Int.self, forKey: .id)
        self.pegColor = try values.decode(String.self, forKey: .pegColor)
        self.unitRadius = try values.decode(CGFloat.self, forKey: .unitRadius)
        self.transform = try values.decode(Transform.self, forKey: .transform)
        Peg.counter = max(Peg.counter, self.id + 1)
    }

    convenience init(pegColor: String, unitRadius: CGFloat, x: CGFloat, y: CGFloat) {
        let transform = Transform(Vector2(x: x, y: y))
        self.init(pegColor: pegColor, unitRadius: unitRadius, transform: transform)
    }

    init(pegColor: String, unitRadius: CGFloat, transform: Transform) {
        self.id = Peg.counter
        self.pegColor = pegColor
        self.transform = transform

        if unitRadius <= 0 {
            self.unitRadius = 1
        } else {
            self.unitRadius = unitRadius
        }

        Peg.counter += 1
    }

    func getCopy() -> Peg {
        Peg(pegColor: self.pegColor, unitRadius: self.unitRadius, transform: self.transform)
    }

    func updatePositionTo(_ newPosition: Vector2) {
        transform.position = newPosition
    }

    func isCollidingWith(otherPegRadius: CGFloat, otherPegX: CGFloat, otherPegY: CGFloat, otherPegId: Int) -> Bool {
        if id == otherPegId {
            return false
        }

        let otherPosition = Vector2(x: otherPegX, y: otherPegY)
        let sqrDistance = (transform.position - otherPosition).sqrMagnitude
        return sqrDistance < pow(unitRadius + otherPegRadius, 2)
    }

    static func == (lhs: Peg, rhs: Peg) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
