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
    var row: Int
    var col: Int

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
        self.row = 0
        self.col = 0
        Peg.counter = max(Peg.counter, self.id + 1)
    }

    convenience init(pegColor: String, unitRadius: CGFloat, x: CGFloat, y: CGFloat, row: Int, col: Int) {
        let transform = Transform(Vector2(x: x, y: y))
        self.init(pegColor: pegColor, unitRadius: unitRadius, transform: transform, row: row, col: col)
    }
    
    init(pegColor: String, unitRadius: CGFloat, transform: Transform, row: Int, col: Int) {
        self.id = Peg.counter
        self.pegColor = pegColor
        self.transform = transform
        self.row = row
        self.col = col

        if unitRadius <= 0 {
            self.unitRadius = 1
        } else {
            self.unitRadius = unitRadius
        }

        Peg.counter += 1
    }

    func getCopy() -> Peg {
        Peg(pegColor: self.pegColor, unitRadius: self.unitRadius, transform: self.transform, row: self.row, col: self.col)
    }

    func updatePositionTo(newPosition: Vector2, newRow: Int, newCol: Int) {
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
