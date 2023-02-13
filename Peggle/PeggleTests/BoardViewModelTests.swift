//
//  BoardViewModelTests.swift
//  PeggleTests
//
//  Created by James Chiu on 1/2/23.
//

import XCTest
@testable import Peggle

final class BoardViewModelTests: XCTestCase {
    override class func setUp() {
        BoardViewModel.viewDim = CGSize(width: 600, height: 600)
        BoardViewModel.maxDim = Int(BoardViewModel.viewDim!.width / 30 + 1)
        BoardViewModel.dimInitialized = true
    }

    func testInitialization() {
        let peg = Peg(pegColor: "peg-orange", radius: 30, x: 0, y: 0)
        let board = DesignBoard(allPegs: [peg])
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
        var boardVM = BoardViewModel(board: DesignBoard(allPegs: Set()))
        boardVM.switchToAddPeg(BoardViewModel.palette[0])
        XCTAssertEqual(boardVM.selectedPegVariant, BoardViewModel.palette[0])
        XCTAssertEqual(boardVM.selectedAction, .add)
    }

    func testSwitchToDeletePeg() {
        var boardVM = BoardViewModel(board: DesignBoard(allPegs: Set()))
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

    func testTryAddPegAt() {
        var boardViewModel = BoardViewModel.getEmptyBoard()
        boardViewModel.switchToAddPeg(BoardViewModel.palette[0])
        XCTAssertEqual(boardViewModel.allPegVMs.count, 0)
        boardViewModel.tryAddPegAt(x: 100, y: 100)
        XCTAssertEqual(boardViewModel.grid[3][3]!.x, 100)
        XCTAssertEqual(boardViewModel.grid[3][3]!.y, 100)
        XCTAssertEqual(boardViewModel.allPegVMs.count, 1)
        boardViewModel.tryAddPegAt(x: 90, y: 90)
        XCTAssertEqual(boardViewModel.allPegVMs.count, 1)
    }

    func testTryRemovePeg() {
        let board = DesignBoard(allPegs: [Peg(pegColor: "peg-orange", radius: 30, x: 100, y: 100)])
        var boardViewModel = BoardViewModel(board: board)
        XCTAssertEqual(boardViewModel.allPegVMs.count, 1)
        boardViewModel.tryRemovePeg(isLongPress: true, targetPegVM: boardViewModel.allPegVMs[0])
        XCTAssertEqual(boardViewModel.allPegVMs.count, 0)
        XCTAssertNil(boardViewModel.grid[3][3])

        boardViewModel.switchToAddPeg(BoardViewModel.palette[0])
        boardViewModel.tryAddPegAt(x: 100, y: 100)
        boardViewModel.switchToDeletePeg()
        boardViewModel.tryRemovePeg(isLongPress: false, targetPegVM: boardViewModel.allPegVMs[0])
        XCTAssertEqual(boardViewModel.allPegVMs.count, 0)
        XCTAssertNil(boardViewModel.grid[3][3])
    }

    func testMovePeg() {
        let board = DesignBoard(allPegs: [
            Peg(pegColor: "peg-orange", radius: 30, x: 100, y: 100),
            Peg(pegColor: "peg-orange", radius: 30, x: 200, y: 200)
        ])
        var boardViewModel = BoardViewModel(board: board)

        boardViewModel.tryMovePeg(targetPegVM: boardViewModel.allPegVMs[0], destination: CGPoint(x: 30, y: 30))
        XCTAssertNil(boardViewModel.grid[3][3])
        XCTAssertEqual(boardViewModel.allPegVMs[0].x, 30)
        XCTAssertEqual(boardViewModel.allPegVMs[0].y, 30)
        XCTAssertEqual(boardViewModel.grid[1][1]!, boardViewModel.allPegVMs[0])
        boardViewModel.tryMovePeg(targetPegVM: boardViewModel.allPegVMs[0], destination: CGPoint(x: 180, y: 180))
        XCTAssertNil(boardViewModel.grid[3][3])
        XCTAssertEqual(boardViewModel.allPegVMs[0].x, 30)
        XCTAssertEqual(boardViewModel.allPegVMs[0].y, 30)
        XCTAssertEqual(boardViewModel.grid[1][1], boardViewModel.allPegVMs[0])
    }
}
