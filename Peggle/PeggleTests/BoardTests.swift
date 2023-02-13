//
//  BoardTests.swift
//  PeggleTests
//
//  Created by James Chiu on 1/2/23.
//

import XCTest
@testable import Peggle

final class BoardTests: XCTestCase {
    func testAddPeg() {
        var board = DesignBoard(allPegs: [])
        let peg = Peg(pegColor: "red", radius: 20, x: 1, y: 2)

        board.addPeg(peg)
        XCTAssertEqual(board.allPegs.count, 1)
        XCTAssertTrue(board.allPegs.contains(peg))
    }

    func testRemovePeg() {
        let peg = Peg(pegColor: "red", radius: 20, x: 1, y: 2)
        var board = DesignBoard(allPegs: [peg])

        board.removePeg(peg)
        XCTAssertEqual(board.allPegs.count, 0)
        XCTAssertFalse(board.allPegs.contains(peg))
    }

    func testRemoveAllPegs() {
        let peg = Peg(pegColor: "red", radius: 20, x: 1, y: 2)
        let peg2 = Peg(pegColor: "green", radius: 10, x: 3, y: 4)
        var board = DesignBoard(allPegs: [peg, peg2])
        board.removeAllPegs()
        XCTAssertEqual(board.allPegs.count, 0)
    }

    func testGetCopy() {
        let board = DesignBoard(allPegs: [Peg(pegColor: "red", radius: 20, x: 1, y: 2)])
        let boardCopy = board.getCopy()

        XCTAssertNotEqual(board.allPegs, boardCopy.allPegs)
    }
}
