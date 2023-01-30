//
//  PegViewModel.swift
//  Peggle
//
//  Created by James Chiu on 30/1/23.
//

import Foundation

class PegViewModel: Identifiable, Equatable {
    let id: Int
    var peg: Peg
    var isBlocked = false
    // BoardViewModel grid coordinates
    var row: Int
    var col: Int

    init(peg: Peg, row: Int, col: Int) {
        self.id = peg.id
        self.peg = peg
        self.row = row
        self.col = col
    }

    func updatePosition(newPosition: CGPoint, newRow: Int, newCol: Int) {
        self.peg.updatePositionTo(newPosition)
        self.row = newRow
        self.col = newCol
    }

    func isCollidingWith(otherPegRadius: CGFloat, otherPegX: CGFloat, otherPegY: CGFloat, otherPegId: Int) -> Bool {
        if self.peg.id == otherPegId {
            return false
        }

        let sqrDistance = pow(self.peg.x - otherPegX, 2) + pow(self.peg.y - otherPegY, 2)
        return sqrDistance < pow(self.peg.radius + otherPegRadius, 2)
    }

    func completeDrag() {
        if isBlocked {
            isBlocked = false
        }
    }

    var x: CGFloat {
        peg.x
    }

    var y: CGFloat {
        peg.y
    }

    var radius: CGFloat {
        peg.radius
    }

    var diameter: CGFloat {
        peg.radius * 2
    }

    var color: String {
        peg.pegColor
    }

    static func == (lhs: PegViewModel, rhs: PegViewModel) -> Bool {
        lhs.peg == rhs.peg
    }
}
