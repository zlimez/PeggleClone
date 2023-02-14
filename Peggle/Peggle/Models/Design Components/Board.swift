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
        print("new peg added")
        allPegs.append(newPeg)
    }

    mutating func removePeg(_ removedPeg: Peg) {
        print("peg removed")
        allPegs = allPegs.filter { $0 != removedPeg }
    }

    mutating func removeAllPegs() {
        print("all pegs removed")
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
