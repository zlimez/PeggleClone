//
//  Board.swift
//  Peggle
//
//  Created by James Chiu on 13/2/23.
//

import Foundation

struct Board: Codable {
    var allPegs: [Peg]

    mutating func addPeg(_ newPeg: Peg) {
        allPegs.append(newPeg)
    }

    mutating func removePeg(_ removedPeg: Peg) {
        allPegs = allPegs.filter { $0 != removedPeg }
    }

    mutating func removeAllPegs() {
        allPegs.removeAll()
    }

    /// Required to provide copy of pegs and not peg references
    func getCopy() -> Board {
        var allPegsCopy: [Peg] = []
        for peg in allPegs {
            allPegsCopy.append(peg.getCopy())
        }
        return Board(allPegs: allPegsCopy)
    }
}
