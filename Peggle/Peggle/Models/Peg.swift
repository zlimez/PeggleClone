//
//  Peg.swift
//  Peggle
//
//  Created by James Chiu on 28/1/23.
//

import Foundation

struct Peg: Identifiable, Hashable {
    static var counter = 0
    let id: Int
    let pegColor: String
    let bounciness: Float
    let radius: CGFloat
    // Relative to center, x value increases to the right, y value increases downwards
    let x: CGFloat
    let y: CGFloat

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

    static func == (lhs: Peg, rhs: Peg) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
