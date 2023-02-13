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

    init(peg: Peg, row: Int, col: Int) {
        self.id = peg.id
        self.peg = peg
    }

    func updatePosition(newPosition: CGPoint, newRow: Int, newCol: Int) {
        self.peg.updatePositionTo(Vector2(x: newPosition.x, y: newPosition.y))
    }

    var x: CGFloat {
        peg.transform.position.x
    }

    var y: CGFloat {
        peg.transform.position.y
    }

    var radius: CGFloat {
        peg.unitRadius
    }

    var diameter: CGFloat {
        peg.unitRadius * 2
    }

    var color: String {
        peg.pegColor
    }

    static func == (lhs: PegViewModel, rhs: PegViewModel) -> Bool {
        lhs.peg == rhs.peg
    }
}
