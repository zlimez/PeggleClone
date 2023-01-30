//
//  PegViewModel.swift
//  Peggle
//
//  Created by James Chiu on 30/1/23.
//

import Foundation

struct PegViewModel: Identifiable {
    let id: Int
    let peg: Peg
    // BoardViewModel grid coordinates
    var row: Int
    var col: Int

    init(peg: Peg, row: Int, col: Int) {
        self.id = peg.id
        self.peg = peg
        self.row = row
        self.col = col
    }

    mutating func updateRowAndCol(newRow: Int, newCol: Int) {
        self.row = newRow
        self.col = newCol
    }

    func isCollidingWith(_ otherPegVM: PegViewModel) -> Bool {
        if self.peg.id == otherPegVM.peg.id {
            return false
        }

        let sqrDistance = pow(self.peg.x - otherPegVM.peg.x, 2) + pow(self.peg.y - otherPegVM.peg.y, 2)
        let isColliding = sqrDistance < pow(self.peg.radius + otherPegVM.peg.radius, 2)
        print("This peg at \(row.description),\(col.description) "
              + "and other peg at \(otherPegVM.row.description),\(otherPegVM.col.description) is colliding: " +
              "sqrDist: \(sqrDistance.description) \(isColliding.description)")
        return sqrDistance < pow(self.peg.radius + otherPegVM.peg.radius, 2)
    }

    var x: CGFloat {
        peg.x
    }

    var y: CGFloat {
        peg.y
    }

    var diameter: CGFloat {
        peg.radius * 2
    }

    var color: String {
        peg.pegColor
    }
}
