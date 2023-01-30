//
//  Board.swift
//  Peggle
//
//  Created by James Chiu on 29/1/23.
//

import Foundation

struct Board {
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
}
