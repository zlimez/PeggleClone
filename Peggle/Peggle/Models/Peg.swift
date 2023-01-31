//
//  Peg.swift
//  Peggle
//
//  Created by James Chiu on 28/1/23.
//

import Foundation

class Peg: Identifiable, Hashable, Codable {
    private static var counter = 0
    let id: Int
    let pegColor: String
    let bounciness: Float
    let radius: CGFloat
    // Relative to center, x value increases to the right, y value increases downwards
    var x: CGFloat
    var y: CGFloat

    enum CodingKeys: String, CodingKey {
        case id
        case pegColor
        case bounciness
        case radius
        case x
        case y
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(Int.self, forKey: .id)
        self.pegColor = try values.decode(String.self, forKey: .pegColor)
        self.bounciness = try values.decode(Float.self, forKey: .bounciness)
        self.radius = try values.decode(CGFloat.self, forKey: .radius)
        self.x = try values.decode(CGFloat.self, forKey: .x)
        self.y = try values.decode(CGFloat.self, forKey: .y)
        Peg.counter = max(Peg.counter, self.id + 1)
    }

    init(pegColor: String, radius: CGFloat, bounciness: Float, x: CGFloat, y: CGFloat) {
        self.id = Peg.counter
        self.pegColor = pegColor
        self.radius = radius
        self.bounciness = bounciness
        self.x = x
        self.y = y
        Peg.counter += 1
    }

    init(pegColor: String, radius: CGFloat, x: CGFloat, y: CGFloat) {
        self.id = Peg.counter
        self.pegColor = pegColor
        self.radius = radius
        self.bounciness = 1
        self.x = x
        self.y = y
        Peg.counter += 1
    }

    func getCopy() -> Peg {
        Peg(pegColor: self.pegColor, radius: self.radius, bounciness: self.bounciness, x: self.x, y: self.y)
    }

    func updatePositionTo(_ newPosition: CGPoint) {
        x = newPosition.x
        y = newPosition.y
    }

    static func == (lhs: Peg, rhs: Peg) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
