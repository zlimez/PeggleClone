//
//  DesignBoard.swift
//  Peggle
//
//  Created by James Chiu on 14/2/23.
//

import Foundation

struct DesignBoard: Codable {
    static var viewDim: CGSize?
    static var maxDim: Int = 0
    static var palette: [PegVariant] = {
        let orangePeg = PegVariant(
            pegColor: "peg-orange",
            pegLitColor: "peg-orange-glow",
            pegRadius: 30
        )
        let bluePeg = PegVariant(
            pegColor: "peg-blue",
            pegLitColor: "peg-blue-glow",
            pegRadius: 30
        )
        let purplePeg = PegVariant(
            pegColor: "peg-purple",
            pegLitColor: "peg-purple-glow",
            pegRadius: 30
        )
        let greenPeg = PegVariant(
            pegColor: "peg-green",
            pegLitColor: "peg-green-glow",
            pegRadius: 30
        )
        let yellowPeg = PegVariant(
            pegColor: "peg-yellow",
            pegLitColor: "peg-yellow-glow",
            pegRadius: 30
        )
        PegMapper.pegToPegRbTable[orangePeg] = { peg in
            NormalPeg(peg)
        }
        PegMapper.pegToPegRbTable[bluePeg] = { peg in
            NormalPeg(peg)
        }
        PegMapper.pegToPegRbTable[purplePeg] = { peg in
            BoomPeg(peg: peg)
        }
        PegMapper.pegToPegRbTable[greenPeg] = { peg in
            BondPeg(peg)
        }
        PegMapper.pegToPegRbTable[yellowPeg] = { peg in
            LoidPeg(peg: peg)
        }
        return [orangePeg, bluePeg, purplePeg, greenPeg, yellowPeg]
    }()
    static var dimInitialized = false

    var board: Board
    var allPegs: [Peg] {
        board.allPegs
    }
    /// assume all pegs have the same radius, thus each cell in grid can hold at most one peg  reference
    var pegRadius: CGFloat
    var grid: [[Peg?]]

    static func getEmptyBoard() -> DesignBoard {
        DesignBoard(board: Board(allPegs: []))
    }

    init(board: Board, pegRadius: CGFloat = 30) {
        self.board = board
        self.pegRadius = pegRadius
        if DesignBoard.dimInitialized {
            self.grid = Array(repeating: Array(repeating: nil, count: DesignBoard.maxDim), count: DesignBoard.maxDim)
            board.allPegs.forEach { peg in placePegInGrid(peg) }
        } else {
            self.grid = [[]]
            board.allPegs.forEach { peg in initPeg(peg) }
        }
    }

    mutating func tryAddPegAt(pegVariant: PegVariant, x: CGFloat, y: CGFloat) -> Peg? {
        if willCollide(pegRadius: pegVariant.pegRadius, pegX: x, pegY: y) {
            return nil
        }

        let addedCol = pointToGrid(x)
        let addedRow = pointToGrid(y)

        let addedPeg = Peg(pegVariant: pegVariant, x: x, y: y, row: addedRow, col: addedCol)
        addPeg(addedPeg)
        return addedPeg
    }

    mutating func tryMovePeg(targetPeg: Peg, destination: Vector2) {
        if willCollide(pegRadius: targetPeg.unitRadius, pegX: destination.x, pegY: destination.y, pegId: targetPeg.id) {
            return
        }

        let newRow = pointToGrid(destination.y)
        let newCol = pointToGrid(destination.x)

        grid[targetPeg.row][targetPeg.col] = nil
        grid[newRow][newCol] = targetPeg
        targetPeg.updatePositionTo(newPosition: destination, newRow: newRow, newCol: newCol)
    }

    mutating func removeAllPegs() {
        board.removeAllPegs()
        self.grid = Array(repeating: Array(repeating: nil, count: grid.count), count: grid.count)
    }

    mutating func initGrid(_ viewDim: CGSize) {
        DesignBoard.viewDim = viewDim
        DesignBoard.maxDim = Int(round(max(viewDim.width / self.pegRadius, viewDim.height / self.pegRadius)))
        print("Max dim \(DesignBoard.maxDim)")
        self.grid = Array(repeating: Array(repeating: nil, count: DesignBoard.maxDim), count: DesignBoard.maxDim)
        for initPeg in board.allPegs {
            self.grid[initPeg.row][initPeg.col] = initPeg
        }
        DesignBoard.dimInitialized = true
    }

    private mutating func initPeg(_ savedPeg: Peg) {
        savedPeg.row = pointToGrid(savedPeg.transform.position.y)
        savedPeg.col = pointToGrid(savedPeg.transform.position.x)
        board.addPeg(savedPeg)
    }

    private mutating func addPeg(_ addedPeg: Peg) {
        board.addPeg(addedPeg)
        grid[addedPeg.row][addedPeg.col] = addedPeg
    }

    private mutating func placePegInGrid(_ pegPlaced: Peg) {
        let placedRow = pointToGrid(pegPlaced.transform.position.x)
        let placedCol = pointToGrid(pegPlaced.transform.position.y)
        grid[placedRow][placedCol] = pegPlaced
    }

    mutating func removePeg(_ removedPeg: Peg) {
        board.removePeg(removedPeg)
        grid[removedPeg.row][removedPeg.col] = nil
    }

    // Pegs yet to be created will have the special id -1
    private func willCollide(pegRadius: CGFloat, pegX: CGFloat, pegY: CGFloat, pegId: Int = -1) -> Bool {
        // Collides with play area border
        if pegX < pegRadius || pegX > DesignBoard.viewDim!.width - pegRadius
            || pegY < pegRadius || pegY > DesignBoard.viewDim!.height - pegRadius {
            return true
        }

        let thisPegRow = pointToGrid(pegY)
        let thisPegCol = pointToGrid(pegX)
        let offsets: [Int] = [-2, -1, 0, 1, 2]
        for offsetX in offsets {
            for offsetY in offsets {
                let adjacentRow = max(min(thisPegRow + offsetY, grid.count - 1), 0)
                let adjacentCol = max(min(thisPegCol + offsetX, grid.count - 1), 0)
                guard let pegInCell = grid[adjacentRow][adjacentCol] else {
                    continue
                }

                if pegInCell.isCollidingWith(
                    otherPegRadius: pegRadius,
                    otherPegX: pegX,
                    otherPegY: pegY,
                    otherPegId: pegId
                ) {
                    return true
                }
            }
        }

        return false
    }

    private func pointToGrid(_ point: CGFloat) -> Int {
        Int(point / pegRadius)
    }
}

struct PegVariant: Hashable {
    let pegColor: String
    let pegLitColor: String
    let pegRadius: CGFloat

    static func == (lhs: PegVariant, rhs: PegVariant) -> Bool {
        lhs.pegColor == rhs.pegColor && lhs.pegLitColor == rhs.pegLitColor && lhs.pegRadius == rhs.pegRadius
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(pegColor)
        hasher.combine(pegLitColor)
        hasher.combine(pegRadius)
    }
}

extension PegVariant: Codable {}
