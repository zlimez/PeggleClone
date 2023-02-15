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
    let pegVariant: PegVariant
    /// Relative to center, x value increases to the right, y value increases downwards
    var transform: Transform

    /// Relevant only during level design phase
    var row: Int
    var col: Int

    var pegColor: String { pegVariant.pegColor }
    var pegLitColor: String { pegVariant.pegLitColor }
    var unitRadius: CGFloat { pegVariant.pegRadius }

    enum CodingKeys: String, CodingKey {
        case id
        case pegVariant
        case transform
    }

    static func getCounter() -> Int {
        Peg.counter
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(pegVariant, forKey: .pegVariant)
        try container.encode(transform, forKey: .transform)
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(Int.self, forKey: .id)
        self.pegVariant = try values.decode(PegVariant.self, forKey: .pegVariant)
        self.transform = try values.decode(Transform.self, forKey: .transform)
        self.row = -1
        self.col = -1
        Peg.counter = max(Peg.counter, self.id + 1)
    }

    convenience init(pegVariant: PegVariant, x: CGFloat, y: CGFloat, row: Int, col: Int) {
        let transform = Transform(Vector2(x: x, y: y))
        self.init(pegVariant: pegVariant, transform: transform, row: row, col: col)
    }

    init(pegVariant: PegVariant, transform: Transform, row: Int = -1, col: Int = -1) {
        self.id = Peg.counter
        self.pegVariant = pegVariant
        self.transform = transform
        self.row = row
        self.col = col

        Peg.counter += 1
    }

    func getCopy() -> Peg {
        Peg(pegVariant: self.pegVariant, transform: self.transform, row: self.row, col: self.col)
    }

    func updatePositionTo(newPosition: Vector2, newRow: Int, newCol: Int) {
        transform.position = newPosition
        row = newRow
        col = newCol
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
