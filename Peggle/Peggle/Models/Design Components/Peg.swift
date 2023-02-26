//
//  Peg.swift
//  Peggle
//
//  Created by James Chiu on 28/1/23.
//

import Foundation

// TODO: Account for Peg scaling
class Peg: Codable, Hashable {
    private static var counter = 0
    static let dummyPeg = Peg()
    let id: Int
    let pegVariant: PegVariant
    /// Relative to center, x value increases to the right, y value increases downwards
    var transform: Transform

    var pegSprite: String { pegVariant.pegSprite }
    var pegLitSprite: String { pegVariant.pegLitSprite }
    var unitWidth: CGFloat { pegVariant.size.x }
    var unitHeight: CGFloat { pegVariant.size.y }

    enum CodingKeys: String, CodingKey {
        case id
        case pegVariant
        case transform
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
        Peg.counter = max(Peg.counter, self.id + 1)
    }

    convenience init(pegVariant: PegVariant, x: CGFloat, y: CGFloat) {
        let transform = Transform(Vector2(x: x, y: y))
        self.init(pegVariant: pegVariant, transform: transform)
    }

    init(pegVariant: PegVariant, transform: Transform) {
        self.id = Peg.counter
        self.pegVariant = pegVariant
        self.transform = transform

        Peg.counter += 1
    }

    private init() {
        self.id = -1
        self.pegVariant = PegVariant(pegSprite: "", pegLitSprite: "", size: Vector2.zero)
        self.transform = Transform.standard
    }
    
    func getCopy() -> Peg {
        Peg(pegVariant: self.pegVariant, transform: self.transform)
    }
    
    static func == (lhs: Peg, rhs: Peg) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
