//
//  PegViewModel.swift
//  Peggle
//
//  Created by James Chiu on 30/1/23.
//

import Foundation

class PegVM: Identifiable, Equatable {
    let id: Int
    var peg: Peg

    init(_ peg: Peg) {
        self.id = peg.id
        self.peg = peg
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

    static func == (lhs: PegVM, rhs: PegVM) -> Bool {
        lhs.peg == rhs.peg
    }
}
