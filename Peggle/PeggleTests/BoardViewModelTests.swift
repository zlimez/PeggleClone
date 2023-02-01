//
//  BoardViewModelTests.swift
//  PeggleTests
//
//  Created by James Chiu on 1/2/23.
//

import XCTest
@testable import Peggle

final class BoardViewModelTests: XCTestCase {
    func testInitialization() {
        let peg = Peg(pegColor: "peg-orange", radius: 30, x: 0, y: 0)
        let board = Board(allPegs: [peg])
        let boardVM = BoardViewModel(board: board)

        XCTAssertEqual(boardVM.allPegVMs.count, 1)
        XCTAssertNil(boardVM.selectedAction)
        XCTAssertNil(boardVM.selectedPegVariant)
    }

    func testGetEmptyBoard() {
        let boardVM = BoardViewModel.getEmptyBoard()
        XCTAssertEqual(boardVM.board.allPegs.count, 0)
        XCTAssertEqual(boardVM.allPegVMs.count, 0)
    }

    func testSwitchToAddPeg() {
        var boardVM = BoardViewModel(board: Board(allPegs: Set()))
        boardVM.switchToAddPeg(BoardViewModel.palette[0])
        XCTAssertEqual(boardVM.selectedPegVariant, BoardViewModel.palette[0])
        XCTAssertEqual(boardVM.selectedAction, .add)
    }

    func testSwitchToDeletePeg() {
        var boardVM = BoardViewModel(board: Board(allPegs: Set()))
        boardVM.switchToDeletePeg()
        XCTAssertNil(boardVM.selectedPegVariant)
        XCTAssertEqual(boardVM.selectedAction, .delete)
    }

    func testIsVariantActive() {
        let pegVariant = PegVariant(pegColor: "peg-orange", pegRadius: 30)
        var boardVM = BoardViewModel.getEmptyBoard()

        XCTAssertFalse(boardVM.isVariantActive(pegVariant))

        boardVM.switchToAddPeg(pegVariant)
        XCTAssertTrue(boardVM.isVariantActive(pegVariant))

        boardVM.switchToDeletePeg()
        XCTAssertFalse(boardVM.isVariantActive(pegVariant))
    }
}
