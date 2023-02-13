//
//  Board.swift
//  Peggle
//
//  Created by James Chiu on 13/2/23.
//

import Foundation

struct Board: Codable {
    var allPegs: Set<Peg>

    mutating func addPeg(_ newPeg: Peg) {
        allPegs.insert(newPeg)
    }

    mutating func removePeg(_ removedPeg: Peg) {
        allPegs.remove(removedPeg)
    }

    mutating func removeAllPegs() {
        allPegs.removeAll()
    }

    /// Required to provide copy of pegs and not peg references
    func getCopy() -> Board {
        var allPegsCopy = Set<Peg>()
        for peg in allPegs {
            allPegsCopy.insert(peg.getCopy())
        }
        return Board(allPegs: allPegsCopy)
    }
}
