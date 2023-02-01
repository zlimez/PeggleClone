//
//  PegViewModelTests.swift
//  PeggleTests
//
//  Created by James Chiu on 1/2/23.
//

import XCTest
@testable import Peggle

final class PegViewModelTests: XCTestCase {
    func testIsCollidingWith() {
        let peg = Peg(pegColor: "red", radius: 10, x: 0, y: 0)
        let pegViewModel = PegViewModel(peg: peg, row: 0, col: 0)

        // To prevent id collision, otherPegId is set to -1
        XCTAssertFalse(pegViewModel.isCollidingWith(
            otherPegRadius: peg.radius,
            otherPegX: peg.x,
            otherPegY: peg.y,
            otherPegId: peg.id
        ))
        XCTAssertFalse(pegViewModel.isCollidingWith(otherPegRadius: 10, otherPegX: 20, otherPegY: 20, otherPegId: -1))
        XCTAssertTrue(pegViewModel.isCollidingWith(otherPegRadius: 10, otherPegX: 5, otherPegY: 5, otherPegId: -1))
    }

    func testCompleteDrag() {
        let peg = Peg(pegColor: "red", radius: 10, x: 0, y: 0)
        let pegViewModel = PegViewModel(peg: peg, row: 0, col: 0)

        pegViewModel.isBlocked = true
        pegViewModel.completeDrag()
        XCTAssertFalse(pegViewModel.isBlocked)
    }

    func testUpdatePosition() {
        let peg = Peg(pegColor: "red", radius: 10, x: 0, y: 0)
        let pegViewModel = PegViewModel(peg: peg, row: 0, col: 0)

        pegViewModel.updatePosition(newPosition: CGPoint(x: 20, y: 20), newRow: 5, newCol: 5)
        XCTAssertEqual(pegViewModel.x, 20)
        XCTAssertEqual(pegViewModel.y, 20)
        XCTAssertEqual(pegViewModel.row, 5)
        XCTAssertEqual(pegViewModel.col, 5)
    }

    func testEquality() {
        let peg = Peg(pegColor: "red", radius: 10, x: 0, y: 0)
        let pegViewModel = PegViewModel(peg: peg, row: 0, col: 0)

        let peg2 = Peg(pegColor: "red", radius: 10, x: 0, y: 0)
        let pegViewModel2 = PegViewModel(peg: peg2, row: 0, col: 0)

        let pegViewModel3 = PegViewModel(peg: peg, row: 0, col: 0)
        XCTAssertNotEqual(pegViewModel, pegViewModel2)
        XCTAssertEqual(pegViewModel, pegViewModel3)
    }
}
